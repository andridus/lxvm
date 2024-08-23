module main

import arrays

struct IFF {
	form_id int
	size    int
	data    []u8
}

struct BeamfileAtomTable {
	count   int
	entries []Eterm
}

struct BeamfileImportTable {
	count   int
	entries []BeamfileImportEntry
}

struct BeamfileExportTable {
	count   int
	entries []BeamfileExportEntry
}

struct BeamfileLambdaTable {
	count   int
	entries []BeamfileLambdaEntry
}

struct BeamfileLineTable {
	instruction_count int
	flags             int
	name_count        int
	names             []string
	location_size     int
	item_count        int
	entries           []BeamfileLineEntry
}

struct BeamfileLiteralTable {
	heap_size int
	allocated int
	count     int
	entries   []BeamfileLiteralEntry
}

struct BeamfileTypeTable {
	count    int
	fallback u8
	entries  []BeamType
}

struct Chunk {
	data []u8
	size int
}

struct BeamCode {
	function_count int
	label_count    int
	max_opcode     int
	data           []u8
	size           int
}

@[heap]
struct LxamFile {
	iff              IFF
	mod              Eterm
	checksum         [16]u8
	atoms            BeamfileAtomTable
	imports          BeamfileImportTable
	exports          BeamfileExportTable
	lambdas          BeamfileLambdaTable
	lines            BeamfileLineTable
	types            BeamfileTypeTable
	static_literals  BeamfileLiteralTable
	dynamic_literals BeamfileLiteralTable
	code             BeamCode
	attributes       Chunk
	compile_info     Chunk
	strings          Chunk
}

fn beam_to_lxam(beam &BeamFileOTP) LxamFile {
	return LxamFile{
		iff: IFF{
			size:    beam.iff.size
			form_id: beam.iff.form_id
			data:    unsafe { arrays.carray_to_varray[u8](beam.iff.data, beam.iff.size) }
		}
		mod:      beam.mod
		checksum: beam.checksum
		atoms:    BeamfileAtomTable{
			count:   beam.atoms.count
			entries: unsafe { arrays.carray_to_varray[Eterm](beam.atoms.entries, beam.atoms.count) }
		}
		imports: BeamfileImportTable{
			count:   beam.imports.count
			entries: unsafe {
				arrays.carray_to_varray[BeamfileImportEntry](beam.imports.entries, beam.imports.count)
			}
		}
		exports: BeamfileExportTable{
			count:   beam.exports.count
			entries: unsafe {
				arrays.carray_to_varray[BeamfileExportEntry](beam.exports.entries, beam.exports.count)
			}
		}
		lambdas: BeamfileLambdaTable{
			count:   beam.lambdas.count
			entries: unsafe {
				arrays.carray_to_varray[BeamfileLambdaEntry](beam.lambdas.entries, beam.lambdas.count)
			}
		}
		lines: BeamfileLineTable{
			instruction_count: beam.lines.instruction_count
			flags:             beam.lines.flags
			name_count:        beam.lines.name_count
			names:             unsafe {
				arrays.carray_to_varray[string](beam.lines.names, beam.lines.name_count)
			}
			location_size: beam.lines.location_size
			item_count:    beam.lines.item_count
			entries:       unsafe {
				arrays.carray_to_varray[BeamfileLineEntry](beam.lines.entries, beam.lines.item_count)
			}
		}
		types: BeamfileTypeTable{
			count:    beam.types.count
			fallback: beam.types.fallback
			entries:  unsafe { arrays.carray_to_varray[BeamType](beam.types.entries, beam.types.count) }
		}
		static_literals: BeamfileLiteralTable{
			heap_size: beam.static_literals.heap_size
			allocated: beam.static_literals.allocated
			count:     beam.static_literals.count
			entries:   unsafe {
				arrays.carray_to_varray[BeamfileLiteralEntry](beam.static_literals.entries,
					beam.static_literals.count)
			}
		}
		dynamic_literals: BeamfileLiteralTable{
			heap_size: beam.dynamic_literals.heap_size
			allocated: beam.dynamic_literals.allocated
			count:     beam.dynamic_literals.count
			entries:   unsafe {
				arrays.carray_to_varray[BeamfileLiteralEntry](beam.dynamic_literals.entries,
					beam.dynamic_literals.count)
			}
		}
		code: BeamCode{
			function_count: beam.code.function_count
			label_count:    beam.code.label_count
			max_opcode:     beam.code.max_opcode
			size:           beam.code.size
			data:           unsafe { arrays.carray_to_varray[u8](beam.code.data, beam.code.size) }
		}
		attributes: Chunk{
			size: beam.attributes.size
			data: unsafe { arrays.carray_to_varray[u8](beam.attributes.data, beam.attributes.size) }
		}
		compile_info: Chunk{
			size: beam.compile_info.size
			data: unsafe { arrays.carray_to_varray[u8](beam.compile_info.data, beam.compile_info.size) }
		}
		strings: Chunk{
			size: beam.strings.size
			data: unsafe { arrays.carray_to_varray[u8](&beam.strings.data, beam.strings.size) }
		}
	}
}
