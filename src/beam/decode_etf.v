module beam

import etf
import errors
import math.big

pub fn (mut bf BeamFile) decode_etf(data []u8) !etf.Value {
	mut data0 := DataBytes{
		data: data
	}
	version := data0.get_next_byte()!
	if version != 131 {
		return errors.new_error('invalid version')
	}
	return bf.decode_term(mut data0)!
}

pub fn (mut bf BeamFile) decode_term(mut data DataBytes) !etf.Value {
	tag := etf.Tag.from(data.get_next_byte()!)!
	return match tag {
		.atom_ext {
			bf.decode_atom_ext(mut data)!
		}
		.small_atom_utf8_ext {
			bf.decode_atom(mut data)!
		}
		.string_ext {
			bf.decode_string(mut data)!
		}
		.list_ext {
			bf.decode_list(mut data)!
		}
		.small_tuple_ext {
			bf.decode_tuple(1, mut data)!
		}
		.large_tuple_ext {
			bf.decode_tuple(4, mut data)!
		}
		.small_big_ext {
			bf.decode_bignum(1, mut data)!
		}
		.large_big_ext {
			bf.decode_bignum(4, mut data)!
		}
		else {
			errors.new_error('invalid tag ${tag}')
		}
	}
}

fn (mut bf BeamFile) decode_atom(mut data DataBytes) !etf.Value {
	//		small_atom_utf8_ext
	//    length: 1-bytes
	//		atom_name: length-bytes
	size := data.get_next_byte()!
	str := data.get_next_bytes(size)!
	atom := bf.atom_table.from(str.bytestr())
	return etf.Atom{
		idx: atom.idx
		name: atom.str
	}
}

fn (mut bf BeamFile) decode_atom_ext(mut data DataBytes) !etf.Value {
	//		small_atom_utf8_ext
	//    length: 1-bytes
	//		atom_name: length-bytes
	size := data.get_next_u16()!
	str := data.get_next_bytes(size)!
	atom := bf.atom_table.from(str.bytestr())
	return etf.Atom{
		idx: atom.idx
		name: atom.str
	}
}

fn (bf BeamFile) decode_string(mut data DataBytes) !etf.Value {
	//		string_ext
	//    length: 2-bytes
	//		characters: length-bytes
	data.ignore_bytes(2)!
	str := data.get_all_next_bytes()!
	return etf.String(str.bytestr())
}

fn (bf BeamFile) decode_bignum(n u8, mut data DataBytes) !etf.Value {
	//    small_big_ext
	//    n: 1-byte
	//	  sign: 1-byte
	//		rest: calculate with big-endian
	size := if n == 4 { data.get_next_u32()! } else { data.get_next_byte()! }
	sign := if data.get_next_byte()! == 1 { -1 } else { 0 }
	rest := data.get_next_bytes(size)!
	if size != rest.len {
		return errors.new_error('invalid bytes for bignum')
	}
	r := big.integer_from_bytes(rest.reverse(), big.IntegerConfig{ signum: sign })
	if r.bit_len() < 60 {
		return etf.Integer(r.int())
	} else {
		return etf.BigInt(r)
	}
}

fn (mut bf BeamFile) decode_tuple(n u8, mut data DataBytes) !etf.Value {
	//    small_tuple_ext
	//    arity: 1-byte
	//		n: elements
	arity := if n == 4 { data.get_next_u32()! } else { data.get_next_byte()! }
	mut terms := []etf.Value{}
	for _ in 0 .. arity {
		terms << bf.decode_term(mut data)!
	}
	return etf.Tuple(terms)
}

fn (mut bf BeamFile) decode_list(mut data DataBytes) !etf.Value {
	size := data.get_next_u32()!
	mut terms := []etf.Value{}
	for _ in 0 .. size {
		terms << bf.decode_term(mut data)!
	}
	return etf.List(terms)
}
