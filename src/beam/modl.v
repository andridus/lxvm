module beam

import encoding.binary
import errors

struct DataBytes {
pub mut:
	data        []u8
	current_pos u32
}

pub struct ModuleInternal {
mut:
	bytes          DataBytes
	total_atoms    u32
	atoms          []string
	version        u32
	opcode_max     u32
	labels         u32
	functions      u32
	code           DataBytes
	function_table []FunctionEntry
}

fn new(data []u8) ModuleInternal {
	return ModuleInternal{
		bytes: DataBytes{
			data: data
		}
	}
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

pub fn (mut m ModuleInternal) scan_beam() {
	m.do_scan_beam() or { errors.parse_error(err) }
	m.clean()
}

fn (mut m ModuleInternal) clean() {
	m.bytes = DataBytes{}
}

pub fn (mut m ModuleInternal) do_scan_beam() ! {
	m.bytes.expect_match('FOR1'.bytes())!
	m.bytes.ignore_bytes(4)!
	m.bytes.expect_match('BEAM'.bytes())!
	for {
		name := m.bytes.get_next_bytes(4)!.bytestr()
		size := m.bytes.get_next_u32()!
		mut data := DataBytes{
			data: m.bytes.get_next_bytes(size)!
		}
		m.align_bytes(size)
		match name {
			'AtU8' {
				m.load_atu8(mut data) or {}
			}
			/*
			 Atom and `AtU8`, atoms table.
			 --
			 both tables have same format and same limitations (256 bytes) except
			 that bytes in strings are treated either as latin1 or utf8
			 The atoms[0] is a module name form `-module(M).` attribute
			*/
			'Code' {
				m.load_code(mut data) or {}
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
				m.load_loct(mut data) or {}
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
				m.load_loct(mut data) or {}
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

fn (mut m ModuleInternal) load_atu8(mut data DataBytes) ! {
	m.total_atoms = data.get_next_u32()!
	for _ in 0 .. m.total_atoms {
		size0 := data.get_next_byte()!
		m.atoms << data.get_next_bytes(size0)!.bytestr()
	}
}

fn (mut m ModuleInternal) load_code(mut data DataBytes) ! {
	sub_size := data.get_next_u32()!
	m.version = data.get_next_u32()!
	m.opcode_max = data.get_next_u32()!
	m.labels = data.get_next_u32()!
	m.functions = data.get_next_u32()!
	data.ignore_bytes(sub_size)!
	m.code = DataBytes{
		data: data.get_all_next_bytes()!
}
}

fn (mut m ModuleInternal) load_loct(mut data DataBytes) ! {
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

pub fn (mut m ModuleInternal) align_bytes(size u64) {
	rem := size % 4
	value := if rem == 0 { 0 } else { 4 - u32(rem) }
	m.bytes.current_pos += u32(value)
}
