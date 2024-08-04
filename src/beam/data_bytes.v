module beam

import etf
import encoding.binary
import math.big
import errors

struct DataBytes {
pub mut:
	data        []u8
	current_pos u32
}

fn (mut b DataBytes) get_next_byte() !u8 {
	bytes := b.get_next_bytes(1)!
	if bytes.len == 1 {
		return bytes[0]
	}
	return errors.new('EOF')
}

fn (mut b DataBytes) get_next_bytes(bytes u32) ![]u8 {
	from := b.current_pos
	to := b.current_pos + bytes
	if to <= b.data.len {
		b.current_pos = to
		return b.data[from..to]
	} else {
		return errors.new('EOF')
	}
}

fn (mut b DataBytes) get_all_next_bytes() ![]u8 {
	from := b.current_pos
	if from < b.data.len {
		return b.data[from..]
	}
	return errors.new('EOF')
}

fn (mut b DataBytes) get_next_u32() !u32 {
	t := b.get_next_bytes(4)!
	return binary.big_endian_u32(t)
}
fn (mut b DataBytes) get_next_u16() !u16 {
	t := b.get_next_bytes(2)!
	return binary.big_endian_u16(t)
}

fn (mut b DataBytes) expect_match(list []u8) ! {
	next := b.get_next_bytes(u8(list.len))!
	if next != list {
		return errors.new_error('doesn\'t match term ${next} with ${list}')
	}
}

fn (mut b DataBytes) ignore_bytes(total int) ! {
	b.get_next_bytes(u8(total))!
}

pub fn (mut db DataBytes) compact_term_encoding() !etf.Value {
	b := db.get_next_byte()!
	tag := b & 0b111 // it uses only three first bytes
	if tag < 0b111 {
		value := db.read_int(b)!
		if value is etf.Integer {
			return match tag {
				0 {
					etf.Value(etf.Literal(u32(value)))
				}
				1 {
					etf.Value(etf.Integer(value))
				}
				2 {
					etf.Value(etf.Atom{
						idx: u32(value)
					})
				}
				3 {
					etf.Value(etf.RegX(u32(value)))
				}
				4 {
					etf.Value(etf.RegY(u32(value)))
				}
				5 {
					etf.Value(etf.Label(u32(value)))
				}
				6 {
					etf.Value(etf.Character(u8(value)))
				}
				else {
					return errors.new_error('unracheable value\n')
				}
			}
		} else {
			return errors.new_error('unracheable value\n')
		}
	}
	return db.parse_extended_term(b)
}

fn (mut db DataBytes) parse_extended_term(b u8) !etf.Value {
	return match b {
		0b0001_0111 {
			db.parse_float()!
		}
		0b0010_0111 {
			db.parse_list()!
		}
		0b0011_0111 {
			db.parse_float_reg()!
		}
		0b0100_0111 {
			db.parse_alloc_list()!
		}
		0b0101_0111 {
			db.parse_extended_literal()!
		}
		else {
			errors.new_error('unracheable value\n')
		}
	}
}

fn (mut db DataBytes) parse_list() !etf.Value {
	return etf.ExtendedList([]etf.Value{})
}

fn (mut db DataBytes) parse_float() !etf.Value {
	return etf.Float(0.0)
}

fn (mut db DataBytes) parse_float_reg() !etf.Value {
	return etf.FloatReg(0)
}

fn (mut db DataBytes) parse_alloc_list() !etf.Value {
	return etf.AllocList([u32(0)])
}

fn (mut db DataBytes) parse_extended_literal() !etf.Value {
	b := db.get_next_byte()!
	val := db.read_int(b)!
	if val is etf.Integer {
		return etf.ExtendedLiteral(u32(val))
	} else {
		return error('not an integer')
	}
}

fn (mut db DataBytes) read_smallint(b u8) !int {
	val := db.read_int(b)!
	if val is etf.Integer {
		return val
	} else {
		errors.new_error('unracheable value\n')
		return 0
	}
}

fn (mut db DataBytes) read_int(b u8) !etf.Value {
	// it's not extended
	if 0 == (b & 0b1000) {
		// the bit 3 == 0, then value is placed in bit 4,5,6,7
		return etf.Integer(b >> 4)
	}

	// Bit 3 is 1, but...
	if 0 == (b & 0b1_0000) {
		/*
					Bit 4 is 0, For values under 16#800 (2048) bit 3 is set to 1,
				 	marks that 1 continuation byte will be used and 3 most significant
				 	bits of the value will extend into this byte's bits 5-6-7
				 */
		continuation_byte := db.get_next_byte()! // continuation byte
		return etf.Integer((b & 0b1110_0000) << 3 | continuation_byte)
	} else {
		/*
					Larger and negative values are first converted to bytes.
					Then, if the value takes 2..8 bytes, bits 3-4 will be set to 1,
					and bits 5-6-7 will contain the (Bytes-2) size for the value
				*/
		mut n_bytes := (b >> 5) + 2
		if n_bytes == 9 {
			/*
					If the following value is greater than 8 bytes,
					then all bits 3-4-5-6-7 will be set to 1, followed by
					a nested encoded unsigned ?tag_u value of (Bytes-9):8
					*/
			len := db.get_next_byte()!
			size0 := db.read_smallint(len)!
			n_bytes = u8(size0) + 9 // TODO: enforce unsigned
		}

		bytes := db.get_next_bytes(n_bytes)!

		r := big.integer_from_bytes(bytes.reverse())
		return etf.BigInt(r)
	}
}
