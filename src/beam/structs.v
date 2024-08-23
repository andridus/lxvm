module beam

import etf

struct FunctionEntry {
	mod   u32
	fun   u32
	arity u32
}

struct Line {
	pos u32 // position inside the bytecode
	loc u32 // line number inside the original file
}

struct FuncInfo {
	idx  u32
	line u32
}

pub struct Lambda {
	name   u32
	arity  u32
	offset u32
	index  u32
	nfree  u32 // frozen values for closures
	ouniq  u32 // ?
}

@[aligned; heap]
struct IFF {
	id   string
	size int
	data []u8
}

@[aligned]
struct ImportEntry {
	mod      etf.ETerm
	function etf.ETerm
	arity    u32
	patches  etf.UInt
	bif      voidptr
}

pub fn (imp ImportEntry) to_mfa() etf.MFA {
	return etf.MFA{
		mod:   imp.mod
		fun:   imp.function
		arity: imp.arity
	}
}

struct LabelPatch {
	pos    etf.UInt
	offset etf.UInt
	packed int
}

struct Label {
	value            etf.UInt
	looprec_targeted etf.UInt
	patches          []LabelPatch
	num_patches      etf.UInt
	num_allocated    etf.UInt
}

@[aligned]
struct ExportEntry {
	function etf.ETerm
	arity    u32
	label    u32
}

@[aligned]
struct LambdaEntry {
	function etf.ETerm
	num_free u32
	arity    u32
	label    u32
	idx      u32
	old_uniq u32
}

@[aligned]
struct LiteralEntry {
	heap_fragments &etf.HeapFragment
	value          etf.ETerm
}

struct LiteralTable {
	heap_size int
	allocated int
	count     int
	entries   []LiteralEntry
}
