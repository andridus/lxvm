module beam

import encoding.binary
import errors
import registry
import bif
import math.big

struct FunctionEntry {
	fun   u32
	arity u32
	label u32
}

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

fn (mut b DataBytes) expect_match(list []u8) ! {
	next := b.get_next_bytes(u8(list.len))!
	if next != list {
		return errors.new_error('doesn\'t match term ${next} with ${list}')
	}
}

fn (mut b DataBytes) ignore_bytes(total int) ! {
	b.get_next_bytes(u8(total))!
}

pub fn (mut bf BeamFile) scan_beam() {
	bf.do_scan_beam() or { errors.parse_error(err) }
	bf.clean()
}

fn (mut bf BeamFile) clean() {
	bf.bytes = DataBytes{}
}

pub fn (mut bf BeamFile) do_scan_beam() ! {
	bf.bytes.expect_match('FOR1'.bytes())!
	bf.bytes.ignore_bytes(4)!
	bf.bytes.expect_match('BEAM'.bytes())!
	for {
		name := bf.bytes.get_next_bytes(4)!.bytestr()
		size := bf.bytes.get_next_u32()!
		mut data := DataBytes{
			data: bf.bytes.get_next_bytes(size)!
		}
		bf.align_bytes(size)
		match name {
			'AtU8' {
				bf.load_atoms(mut data) or {}
			}
			/*
			 Atom and `AtU8`, atoms table.
			 --
			 both tables have same format and same limitations (256 bytes) except
			 that bytes in strings are treated either as latin1 or utf8
			 The atoms[0] is a module name form `-module(M).` attribute
			*/
			'Code' {
				bf.load_code(mut data) or {}
			}
			/*
			 `Code`. Compiled Bytecode
			*/
			'Abst' {
				// TODO
			}
			/*
			 `Abst`
			 --
			 Optional section which contains term_to_binary encoded AST tree.
			*/
			'CatT' {
				// TODO
			}
			/*
			 `CatT`, Catch Table
			 --
			 Contains catch labels nicely lined up and marking try/catch blocks.
			 (Untested Block)
			*/
			'FunT' {
				// TODO
			}
			/*
			 `FunT`, Function Lambda Table
			 --
			 Contains pointers to functions in the module
			 --
			 Sanity check: fun_atom_index must be in atom table range
			*/
			'ExpT' {
				bf.load_loct(mut data) or {}
			}
			/*
			 `ExpT`, Export table
			 --
			 Encodes exported functions and arity in the -export([]). attribute.
			 --
			 Sanity check: atom table range
			*/
			'LitT' {
				// TODO
			}
			/*
			 `LitT`, Literals Table
			 --
			 Contains all the constants in file which are larger than 1
			 machine Word. It is compressed using zip Deflate.
			 --
			 Values are encoded using the external term format
			*/
			'ImpT' {
				// TODO
			}
			/*
			 `ImpT`, Imports Table
			 --
			 Encodes functions from other modules invoked by the current module.
			*/
			'LocT' {
				bf.load_loct(mut data) or {}
			}
			/*
			 `LocT`, Local Functions
			 --
			 Essentially same as the export table format ExpT for local functions.
			*/
			'StrT' {
				// TODO
			}
			/*
			 `StrT`, Strings Table
			 --
			 This is a huge binary with all concatenated strings from the Erlang
			 parsed AST (syntax tree). Everything {string, X} goes here.
			 There are no size markers or separators between strings, so opcodes
			 that need these values (e.g. bs_put_string) must provide an index and
			 a string length to extract what they need out of this chunk.

			 Consider compiler application in standard library, files:
			 beam_asm, beam_dict (record #asm{} field strings), and beam_disasm.
			*/
			'Attr' {
				// TODO
			}
			/*
			 `Attr`, Attributes
			 --
			 Contains two parts: a proplist of module attributes, encoded as External
			 Term Format, and a compiler info (options and version) encoded similarly.
			*/
			'Line' {
				// TODO
			}
			/*
			 `Line`, Line Numbers Table
			 --
			 Encodes line numbers mapping to give better error reporting and code navigation for the program user.
			 --
			 Convert string to an atom and push into file names table

			*/
			else {}
		}
	}
}

fn (mut bf BeamFile) load_atoms(mut data DataBytes) ! {
	bf.total_atoms = data.get_next_u32()!
	for _ in 0 .. bf.total_atoms {
		size0 := data.get_next_byte()!
		atom_str := data.get_next_bytes(size0)!.bytestr()
		gidx := bf.atom_table.insert(atom_str)
		bf.atoms << atom_str
		bf.atoms_map[u32(bf.atoms.len - 1)] = gidx
	}
}

fn (mut bf BeamFile) load_code(mut data DataBytes) ! {
	bf.sub_size = data.get_next_u32()!
	bf.version = data.get_next_u32()!
	bf.opcode_max = data.get_next_u32()!
	bf.labels = data.get_next_u32()!
	bf.functions = data.get_next_u32()!
	// data.ignore_bytes(sub_size)!
	bf.code = DataBytes{
		data: data.get_all_next_bytes()!
	}
}

fn (mut bf BeamFile) load_loct(mut data DataBytes) ! {
	fun_total := data.get_next_u32()!
	mut entries := []FunctionEntry{}
	for _ in 0 .. fun_total {
		fun := data.get_next_u32()!
		arity := data.get_next_u32()!
		label := data.get_next_u32()!
		entries << FunctionEntry{
			fun: fun
			arity: arity
			label: label
		}
	}
}

pub fn (mut bf BeamFile) align_bytes(size u64) {
	rem := size % 4
	value := if rem == 0 { 0 } else { 4 - u32(rem) }
	bf.bytes.current_pos += u32(value)
}

struct Instruction {
	op   bif.Opcode
	args []registry.Value
}

fn (mut bf BeamFile) scan_instructions() []Instruction {
	mut op_args := []Instruction{}
	for {
		op := bf.code.get_next_byte() or { break }
		opcode := bif.Opcode.from(op) or {
			errors.new_error('invalid opcode ${op}')
			break
		}
		mut args := []registry.Value{}
		if opcode.arity() > 0 {
			for _ in 0 .. opcode.arity() {
				arg := bf.code.compact_term_encoding() or {
					errors.new_error('invalid term encoding ${err.msg()}')
					break
				}
				args << arg
			}
		}
		op_args << Instruction{
			op: opcode
			args: args
		}
	}
	return op_args
}

pub fn (mut db DataBytes) compact_term_encoding() !registry.Value {
	b := db.get_next_byte()!
	tag := b & 0b111 // it uses only three first bytes
	if tag < 0b111 {
		value := db.read_int(b)!
		if value is registry.Integer {
			return match tag {
				0 {
					registry.Value(registry.Literal(u32(value)))
				}
				1 {
					registry.Value(registry.Integer(value))
				}
				2 {
					registry.Value(registry.Atom(u32(value)))
				}
				3 {
					registry.Value(registry.RegX(u32(value)))
				}
				4 {
					registry.Value(registry.RegY(u32(value)))
				}
				5 {
					registry.Value(registry.Label(u32(value)))
				}
				6 {
					registry.Value(registry.Character(u8(value)))
				}
				else {
					errors.new_error('unracheable value\n')
					registry.Value(registry.Integer(0))
				}
			}
		} else {
			errors.new_error('unracheable value\n')
			return registry.Integer(0)
		}
	}
	return db.parse_extended_term(b)
}

fn (mut db DataBytes) parse_extended_term(b u8) !registry.Value {
	return match b {
		0b0001_0111 {
			db.parse_list()!
		}
		0b0010_0111 {
			db.parse_float_reg()!
		}
		0b0011_0111 {
			db.parse_alloc_list()!
		}
		0b0100_0111 {
			db.parse_extended_literal()!
		}
		else {
			errors.new_error('unracheable value\n')
			error('unreachable')
		}
	}
}

fn (mut db DataBytes) parse_list() !registry.Value {
	return registry.ExtendedList([]registry.Value{})
}

fn (mut db DataBytes) parse_float_reg() !registry.Value {
	return registry.FloatReg(0)
}

fn (mut db DataBytes) parse_alloc_list() !registry.Value {
	return registry.AllocList([u32(0)])
}

fn (mut db DataBytes) parse_extended_literal() !registry.Value {
	return registry.ExtendedLiteral(0)
}

fn (mut db DataBytes) read_smallint(b u8) !int {
	val := db.read_int(b)!
	if val is registry.Integer {
		return val
	} else {
		errors.new_error('unracheable value\n')
		return 0
	}
}

fn (mut db DataBytes) read_int(b u8) !registry.Value {
	// it's not extended
	if 0 == (b & 0b1000) {
		// the bit 3 == 0, then value is placed in bit 4,5,6,7
		return registry.Integer(b >> 4)
	}

	// Bit 3 is 1, but...
	if 0 == (b & 0b1_0000) {
		/*
					Bit 4 is 0, For values under 16#800 (2048) bit 3 is set to 1,
				 	marks that 1 continuation byte will be used and 3 most significant
				 	bits of the value will extend into this byte's bits 5-6-7
				 */
		continuation_byte := db.get_next_byte()! // continuation byte
		return registry.Integer((b & 0b1110_0000) << 3 | continuation_byte)
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

		r := big.integer_from_bytes(bytes)
		return registry.BigInt(r)
	}
}
