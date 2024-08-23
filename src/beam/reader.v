module beam

import errors
import etf
import bif
import atom
import compress.zlib

const chunks = {
	'utf8_atom_chunk': 'AtU8'.bytes(),
	'code_chunk': 'Code'.bytes(),
	'str_chunk': 'StrT'.bytes(),
	'imp_chunk': 'ImpT'.bytes(),
	'exp_chunk': 'ExpT'.bytes(),
	'lambda_chunk': 'FunT'.bytes(),
	'literal_chunk': 'LitT'.bytes(),
	'attr_chunk': 'Attr'.bytes(),
	'compile_chunk': 'CInf'.bytes(),
	'line_chunk': 'Line'.bytes(),
	'loc_chunk': 'LocT'.bytes(), // future versions
	'type_chunk': 'Type'.bytes(), // future versions
	'meta_chunk': 'Meta'.bytes(), // future versions
	'atom_chunk': 'Atom'.bytes() // old version
}

pub fn (mut bf BeamModule) scan_beam() ! {
	bf.do_scan_beam() or {
		return error('${bf.mod_name}[${bf.mod}a]: ${err.msg()}')
	}
	bf.clean()
}

fn (mut bf BeamModule) clean() {
	bf.bytes = DataBytes{}
}

fn (mut bf BeamModule) read_beam_chunks() !map[string]IFF {
	bf.bytes.expect_match('BEAM'.bytes())!
	mut chunks0 := map[string]IFF{}
	for {
		chunk_name := bf.bytes.get_next_bytes(4) or {
			return chunks0
		}
		chunk_size := bf.bytes.get_next_u32()!
		for k, _ in chunks {
			if chunk_name == chunks[k] {
				chunks0[k] = IFF{
					id: chunk_name.bytestr()
					size: chunk_size
					data: bf.bytes.get_next_bytes(chunk_size)!
				}
			}
		}
		bf.align_bytes(chunk_size)
	}
	return chunks0
}
pub fn (mut bf BeamModule) do_scan_beam() ! {


	bf.bytes.expect_match('FOR1'.bytes())!

	// OTP-20, Check if the module is compressed (or possibly invalid/corrupted).

	iff_size := bf.bytes.get_next_u32()!
	if iff_size != (bf.bytes.data.len - 8) {
		return error(BeamFileResult.read_corrupt_file_header.str())
	}

	chunks0 := bf.read_beam_chunks() or {
		return error(BeamFileResult.read_corrupt_file_header.str())
	 }

	//  Read the code header
	if chunks0['code_chunk'].size > 0 {
		bf.parse_code_chunk(chunks0['code_chunk'].data) or {
			return error(BeamFileResult.read_corrupt_code_chunk.str())
		}
	} else {
		return error(BeamFileResult.read_missing_code_chunk.str())
	}

	// Read the atom table
	if chunks0['utf8_atom_chunk'].size > 0 {
		bf.parse_atom_chunk(chunks0['utf8_atom_chunk'].data, .utf8) or {
			return error(BeamFileResult.read_corrupt_atom_table.str())
		}
	} else if chunks0['atom_chunk'].size > 0 {
		bf.parse_atom_chunk(chunks0['atom_chunk'].data,  .latin1) or {
			return error(BeamFileResult.read_obsolete_atom_table.str())
		}
	} else {
		return error(BeamFileResult.read_missing_atom_table.str())
	}

	// Read import table
	if chunks0['imp_chunk'].size > 0 {
		bf.parse_import_chunk(chunks0['imp_chunk'].data) or {
			return error(BeamFileResult.read_corrupt_import_table.str())
		}
	} else {
		return error(BeamFileResult.read_missing_import_table.str())
	}

	// Read export table
	if chunks0['exp_chunk'].size == 0 {
		return error(BeamFileResult.read_missing_export_table.str())
	} else {
		bf.parse_export_chunk(chunks0['exp_chunk'].data) or {
			return error(BeamFileResult.read_corrupt_export_table.str())
		}
	}

	//  $if beamasm {
	// 	if chunks0[ChunkName.loc_chunk].size == 0 {
	// 		return error(BeamFileResult.read_corrupt_locals_table.str())
	// 	} else {
	// 		// parse_import_chunk
	// 	}
	// }

	// Read lambda(anonymous fun) table
	if chunks0['lambda_chunk'].size > 0 {
		bf.parse_lambda_chunk(chunks0['lambda_chunk'].data) or {
			return error(BeamFileResult.read_corrupt_lambda_table.str())
		}
	}

	// Read the Literal table
	if chunks0['literal_chunk'].size > 0 {
		bf.parse_literal_chunk(chunks0['literal_chunk'].data) or {
			return error(BeamFileResult.read_corrupt_literal_table.str())
		}
	}

	// Read line table, if present
	if chunks0['line_chunk'].size > 0 {
		//if !parse_import_chunk
		return error(BeamFileResult.read_corrupt_line_table.str())
		// else

	}

	bf.otp_20_or_higher = chunks0['utf8_atom_chunk'].size > 0

	// if chunks0['type_chunk'].size > 0 {
	// 	//if !parse_import_chunk
	// 	return error(BeamFileResult.read_corrupt_type_table.str())
	// 	// else

	// }

	/* Compute module checksum.  Please keep aboving this section*/
	// calculate_file_checksum()

	// for {
	// 	match chunk_name {
	// 		/*
	// 		 Atom and `AtU8`, atoms table.
	// 		 --
	// 		 both tables have same format and same limitations (256 bytes) except
	// 		 that bytes in strings are treated either as latin1 or utf8
	// 		 The atoms[0] is a module name form `-module(M).` attribute
	// 		*/
	// 		'AtU8' {
	// 			if data.data.len == 0 {
	// 				return error(BeamFileResult.read_missing_atom_table.str())
	// 			}
	// 			bf.load_atoms(mut data)  or {
	// 				return error(BeamFileResult.read_corrupt_code_chunk.str())
	// 			}
	// 		}
	// 		/*
	// 		 `Code`. Compiled Bytecode
	// 		*/
	// 		'Code' {
	// 			if data.data.len == 0 {
	// 				return error(BeamFileResult.read_missing_code_chunk.str())
	// 			}
	// 			bf.load_code(mut data) or {
	// 				return error(BeamFileResult.read_corrupt_code_chunk.str())
	// 			}
	// 		}
	// 		/*
	// 		 `StrT`, Strings Table
	// 		 --
	// 		 This is a huge binary with all concatenated strings from the Erlang
	// 		 parsed AST (syntax tree). Everything {string, X} goes here.
	// 		 There are no size markers or separators between strings, so opcodes
	// 		 that need these values (e.g. bs_put_string) must provide an index and
	// 		 a string length to extract what they need out of this chunk.

	// 		 Consider compiler application in standard library, files:
	// 		 beam_asm, beam_dict (record #asm{} field strings), and beam_disasm.
	// 		*/
	// 		'StrT' {
	// 			// TODO
	// 		}
	// 		/*
	// 		 `ImpT`, Imports Table
	// 		 --
	// 		 Encodes functions from other modules invoked by the current module.
	// 		*/
	// 		'ImpT' {
	// 			bf.load_imports(mut data)!
	// 		}
	// 		/*
	// 		 `ExpT`, Export table
	// 		 --
	// 		 Encodes exported functions and arity in the -export([]). attribute.
	// 		 --
	// 		 Sanity check: atom table range
	// 		*/
	// 		'ExpT' {
	// 			bf.load_exports(mut data)!
	// 		}
	// 		/*
	// 		 `FunT`, Function Lambda Table
	// 		 --
	// 		 Contains pointers to functions in the module
	// 		 --
	// 		 Sanity check: fun_atom_index must be in atom table range
	// 		*/
	// 		'FunT' {
	// 			bf.load_literals(mut data)!
	// 		}
	// 		/*
	// 		 `LitT`, Literals Table
	// 		 --
	// 		 Contains all the constants in file which are larger than 1
	// 		 machine Word. It is compressed using zip Deflate.
	// 		 --
	// 		 Values are encoded using the external term format
	// 		*/
	// 		'LitT' {
	// 			bf.load_literals(mut data)!
	// 		}
	// 		/*
	// 		 `Attr`, Attributes
	// 		 --
	// 		 Contains two parts: a proplist of module attributes, encoded as External
	// 		 Term Format, and a compiler info (options and version) encoded similarly.
	// 		*/
	// 		'Attr' {
	// 			bf.load_attributes(mut data)!
	// 		}
	// 		/*
	// 		 `CInf`
	// 		 --

	// 		*/
	// 		'CInf' {
	// 			// TODO
	// 		}
	// 		/*
	// 		 `Line`, Line Numbers Table
	// 		 --
	// 		 Encodes line numbers mapping to give better error reporting and code navigation for the program user.
	// 		 --
	// 		 Convert string to an atom and push into file names table

	// 		*/
	// 		'Line' {
	// 			bf.load_line(mut data)!
	// 		}
	// 		/*
	// 		 `LocT`, Local Functions
	// 		 --
	// 		 Essentially same as the export table format ExpT for local functions.
	// 		*/
	// 		'LocT' {
	// 			bf.load_loct(mut data)!
	// 		}
	// 		// only V27 blocks
	// 		'Atom' {
	// 			// TODO
	// 		}
	// 		'Type' {
	// 			// TODO
	// 		}
	// 		'Meta' {
	// 			// TODO
	// 		}
	// 		// end

	// 		// Untested Blocks
	// 		/*
	// 		 `Abst`
	// 		 --
	// 		 Optional section which contains term_to_binary encoded AST tree.
	// 		*/
	// 		'Abst' {
	// 			// TODO
	// 		}
	// 		/*
	// 		 `CatT`, Catch Table
	// 		 --
	// 		 Contains catch labels nicely lined up and marking try/catch blocks.
	// 		 (Untested Block)
	// 		*/
	// 		'CatT' {
	// 			// TODO
	// 		}
	// 		else {}
	// 	}
	// }
}
fn (mut bf BeamModule) parse_code_chunk(data []u8) ! {
	mut db := DataBytes{data: data}
	bf.head_size = db.get_next_u32()!
	bf.version 	= db.get_next_u32()!
	if bf.version != bif.beam_format_number { return error('invalid version') }
	bf.max_opcode = db.get_next_u32()!
	if bf.max_opcode > bif.max_generic_opcode {
		return error('This BEAM file was compiled for a later version of the runtime system than OTP-21. To fix this, please recompile module with an OTP-21 compiler. (Use of opcode ${bf.max_opcode}; this.emulator supports only up to ${bif.max_generic_opcode})')
	}
	bf.total_labels = db.get_next_u32()!
	// add labels
	for i in 0..(bf.total_labels) {
		bf.labels1[i] = Label{}
	}
	bf.total_functions = db.get_next_u32()!
	bf.code = DataBytes{
		data: db.get_all_next_bytes()!
	}
}

fn (mut bf BeamModule) parse_atom_chunk(data []u8, enc atom.Encoding) ! {
	mut db := DataBytes{data: data}
	bf.total_atoms = db.get_next_u32()!
	for i in 0 .. bf.total_atoms {
		size0 := db.get_next_byte()!
		atom_str := db.get_next_bytes(size0)!.bytestr()

		bf.atoms_core << bf.atom_table.insert(atom_str, enc)!
		if i == 0 {
			bf.mod = bf.atoms_core[1]
			bf.mod_name = atom_str

		}
	}
}

fn (mut bf BeamModule) parse_export_chunk(data []u8) ! {
	mut db := DataBytes{data: data}
	total := db.get_next_u32()!

	if total > bf.total_functions {
		 return error("${total} functions are exported; only ${bf.total_functions} function defined")
	}
	if !check_item_count(total, 0, sizeof(ExportEntry)) { return error("exceed limit 1GB") }
	for i in 0..total {
		atom_idx := db.get_next_u32()!
		arity := db.get_next_u32()!
		label := db.get_next_u32()!
		if arity > etf.function_max_args { return error("function exceed `etf.function_max_args` limit") }
		if label > bf.total_labels {
			return error("export table entry ${i}: invalid label ${label}. (highest defined label is ${bf.total_labels})")
		}
		_ := bf.labels1[label] or {
			return error("export table entry ${i}: label ${label} not resolved")
		}

		// TODO: Find out if there is a BIF with the same name.
		// TODO: This is a stub for a BIF.


	 	exp := ExportEntry{
				function: bf.atoms_core[atom_idx]
				arity: arity
				label: label
			}

		bf.exports << exp
	}
}

fn (mut bf BeamModule) parse_import_chunk(data []u8) ! {
	mut db := DataBytes{data: data}
	total := db.get_next_u32()!
	if !check_item_count(total, 0, sizeof(ImportEntry)) { return error("exceed limit 1GB") }

	for _ in 0..total {
		mod_atom_idx := db.get_next_u32()!
		function_atom_idx := db.get_next_u32()!
		arity := db.get_next_u32()!
		bf.imports << ImportEntry{
			mod: bf.atoms_core[mod_atom_idx]
			function: bf.atoms_core[function_atom_idx]
			arity: arity
		}

		/*
		* If the export entry refers to a BIF, get the pointer to
		* the BIF function.
		TODO
		*/


	}
}

fn (mut bf BeamModule) parse_lambda_chunk(data []u8) ! {
	mut db := DataBytes{data: data}
	total := db.get_next_u32()!
	if !check_item_count(total, 0, sizeof(LambdaEntry)) { return error("exceed limit 1GB") }

	for _ in 0..total {
		atom_idx := db.get_next_u32()!
		arity := db.get_next_u32()!
		label := db.get_next_u32()!
		fun_idx := db.get_next_u32()!
		num_free := db.get_next_u32()!
		old_uniq := db.get_next_u32()!

		bf.lambdas << LambdaEntry{
			function: bf.atoms_core[atom_idx]
			num_free: num_free
			arity: arity
			label: label
			idx: fun_idx
			old_uniq: old_uniq
		}
	}
}

fn (mut bf BeamModule) parse_literal_chunk(data []u8) ! {

	mut db := DataBytes{data: data}
	total_bytes := db.get_next_u32()!
	decoded_bytes := zlib.decompress(db.get_all_next_bytes()!)!
	if total_bytes != decoded_bytes.len {
		return errors.new_error('length bytes incompatible')
	}
	mut decompressed_data := DataBytes{
		data: decoded_bytes
	}
	total_literals := decompressed_data.get_next_u32()!
	if !check_item_count(total_literals, 0, sizeof(LiteralEntry)) { return error("exceed limit 1GB") }

	// mut literals := []LiteralEntry{}
	mut all_heap_size := u64(0)
	for _ in 0 .. total_literals {

		ext_size := decompressed_data.get_next_u32()!
		ext_data := decompressed_data.get_next_bytes(ext_size)!
		heap_size := bf.decode_ext_size(ext_data)!
		all_heap_size += heap_size

		if heap_size > 0 {

			// factory := etf.HeapFactory.init(heap_size, .prepared_code)
			bf.literals << bf.decode_etf(ext_data)!
		}
	}
	// bf.literals << LiteralTable{
	// 	allocated: heap_size
	// 	count: total_terms
	// 	entries: literals
	// }


}

fn (mut bf BeamModule) load_attributes(mut data DataBytes) ! {
	value := bf.decode_etf(data.get_all_next_bytes()!)!
	bf.attributes = value
}

fn (mut bf BeamModule) load_line(mut data DataBytes) ! {
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
					idx = term.idx
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




fn check_item_count(count u32, minimum u32, item_size u32) bool {
	/* Quick sanity check for item counts; if the resulting array can't fit into
 * 1GB it's most likely wonky. */
	return count >= minimum && (count < (1 << 30) / item_size)
}
fn (mut bf BeamModule) get_atom_from_idx(idx u32) !atom.Atom {
	if loc_idx := bf.atoms_map[idx] {
		if atom := bf.atom_table.idx_lookup(loc_idx) {
			return atom
		}
	}
	return error('not found atom')
}

fn (mut bf BeamModule) load_loct(mut data DataBytes) ! {
	_ := bf.chunk_loct(mut data)!
}

fn (bf BeamModule) chunk_loct(mut data DataBytes) ![]FunctionEntry {
	fun_total := data.get_next_u32()!
	mut entries := []FunctionEntry{}
	for _ in 0 .. fun_total {
		mod := data.get_next_u32()!
		fun := data.get_next_u32()!
		arity := data.get_next_u32()!
		entries << FunctionEntry{
			mod: mod
			fun: fun
			arity: arity
		}
	}
	return entries
}

pub fn (mut bf BeamModule) align_bytes(size u64) {
	rem := size % 4
	value := if rem == 0 { 0 } else { 4 - u32(rem) }
	bf.bytes.current_pos += u32(value)
}
