module beam

import errors
import etf
import compress.zlib
// import bif

struct FunctionEntry {
	fun   u32
	arity u32
	label u32
}

struct Line {
	pos u32 // position inside the bytecode
	loc u32 // line number inside the original file
}

struct FuncInfo {
	idx  u32
	line u32
}

pub fn (mut bf BeamFile) scan_beam() {
	bf.do_scan_beam() or {
		// hide is not an error
		errors.parse_error(err)
	}
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
				bf.load_atoms(mut data)!
			}
			/*
			 Atom and `AtU8`, atoms table.
			 --
			 both tables have same format and same limitations (256 bytes) except
			 that bytes in strings are treated either as latin1 or utf8
			 The atoms[0] is a module name form `-module(M).` attribute
			*/
			'Code' {
				bf.load_code(mut data)!
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
				bf.load_literals(mut data)!
			}
			/*
			 `FunT`, Function Lambda Table
			 --
			 Contains pointers to functions in the module
			 --
			 Sanity check: fun_atom_index must be in atom table range
			*/
			'ExpT' {
				bf.load_exports(mut data)!
			}
			/*
			 `ExpT`, Export table
			 --
			 Encodes exported functions and arity in the -export([]). attribute.
			 --
			 Sanity check: atom table range
			*/
			'LitT' {
				bf.load_literals(mut data)!
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
				bf.load_imports(mut data)!
			}
			/*
			 `ImpT`, Imports Table
			 --
			 Encodes functions from other modules invoked by the current module.
			*/
			'LocT' {
				bf.load_loct(mut data)!
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
				bf.load_attributes(mut data)!
			}
			/*
			 `Attr`, Attributes
			 --
			 Contains two parts: a proplist of module attributes, encoded as External
			 Term Format, and a compiler info (options and version) encoded similarly.
			*/
			'Line' {
				bf.load_line(mut data)!
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

fn (mut bf BeamFile) load_line(mut data DataBytes) ! {
	bf.version = data.get_next_u32()!

	if bf.version == 0 {
		data.ignore_bytes(4)! // flags
		data.ignore_bytes(4)! // num_line_instructions
		num_line_items := data.get_next_u32()!
		num_fnames := data.get_next_u32()!
		mut idx := u32(0)

		bf.line_items << FuncInfo{
			idx: 0
			line: 0
		} // push origin

		for _ in 0 .. num_line_items {
			term := data.compact_term_encoding()!
			match term {
				etf.Integer {
					bf.line_items << FuncInfo{
						idx: idx
						line: u32(term)
					}
				}
				etf.Atom {
					idx = u32(term.idx)
				}
				else {
					errors.new_error('unracheable value\n')
					return error('unreachable')
				}
			}
		}
		for _ in 0 .. num_fnames {
			bytes := data.get_next_bytes(2)!
			bf.file_names << bytes.bytestr()
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

fn (mut bf BeamFile) load_literals(mut data DataBytes) ! {
	total_bytes := data.get_next_u32()!
	decoded_bytes := zlib.decompress(data.get_all_next_bytes()!)!
	if total_bytes != decoded_bytes.len {
		return errors.new_error('length bytes incompatible')
	}
	mut decompressed_data := DataBytes{
		data: decoded_bytes
	}
	total_terms := decompressed_data.get_next_u32()! // ignore size
	for _ in 0 .. total_terms {
		size := decompressed_data.get_next_u32()! // ignore size
		value := bf.decode_etf(decompressed_data.get_next_bytes(size)!)!
		bf.literals << value
	}
}

fn (mut bf BeamFile) load_attributes(mut data DataBytes) ! {
	value := bf.decode_etf(data.get_all_next_bytes()!)!
	bf.attributes = value
}

fn (mut bf BeamFile) load_exports(mut data DataBytes) ! {
	entries := bf.chunk_loct(mut data)!
	for e in entries {
		if atom_idx := bf.atoms_map[e.fun] {
			if function := bf.atom_table.idx_lookup(atom_idx) {
				bf.exports << MFA{
					function: function
					arity: e.arity
					label: e.label
				}
			}
		}
	}
}

fn (mut bf BeamFile) load_imports(mut data DataBytes) ! {
	entries := bf.chunk_loct(mut data)!
	for e in entries {
		if atom_idx := bf.atoms_map[e.fun] {
			if function := bf.atom_table.idx_lookup(atom_idx) {
				bf.imports << MFA{
					function: function
					arity: e.arity
					label: e.label
				}
			}
		}
	}
}

fn (mut bf BeamFile) load_loct(mut data DataBytes) ! {
	_ := bf.chunk_loct(mut data)!
}

fn (bf BeamFile) chunk_loct(mut data DataBytes) ![]FunctionEntry {
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
	return entries
}

pub fn (mut bf BeamFile) align_bytes(size u64) {
	rem := size % 4
	value := if rem == 0 { 0 } else { 4 - u32(rem) }
	bf.bytes.current_pos += u32(value)
}
