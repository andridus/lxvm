module main

struct IFFOTP {
	form_id int
	size    int
	data    &u64
}

struct BeamfileAtomTableOTP {
	count   int
	entries &u64 //&Eterm
}

struct BeamfileImportTableOTP {
	count   int
	entries &u64 // &BeamfileImportEntry
}

struct BeamfileExportTableOTP {
	count   int
	entries &u64 //&BeamfileExportEntry
}

struct BeamfileLambdaTableOTP {
	count   int
	entries &u64 //&BeamfileLambdaEntry
}

struct BeamfileLineTableOTP {
	instruction_count int
	flags             int
	name_count        int
	names             &u64
	location_size     int
	item_count        int
	entries           &u64
}

struct BeamfileLiteralTableOTP {
	heap_size int
	allocated int
	count     int
	entries   &u64
}

struct BeamfileTypeTableOTP {
	count    int
	fallback u8
	entries  &u64
}

struct ChunkOTP {
	data &u64
	size int
}

struct BeamCodeOTP {
	function_count int
	label_count    int
	max_opcode     int
	data           &u64
	size           int
}

@[heap]
struct BeamFileOTP {
	iff              IFFOTP
	mod              Eterm
	checksum         [16]u8
	atoms            BeamfileAtomTableOTP
	imports          BeamfileImportTableOTP
	exports          BeamfileExportTableOTP
	lambdas          BeamfileLambdaTableOTP
	lines            BeamfileLineTableOTP
	types            BeamfileTypeTableOTP
	static_literals  BeamfileLiteralTableOTP
	dynamic_literals BeamfileLiteralTableOTP
	code             BeamCodeOTP
	attributes       ChunkOTP
	compile_info     ChunkOTP
	strings          ChunkOTP
}
