module beam

import atom
import os
import instruction
import etf

pub struct Lambda {
	name   u32
	arity  u32
	offset u32
	index  u32
	nfree  u32 // frozen values for closures
	ouniq  u32 // ?
}

pub struct BeamFile {
pub mut:
	bytes      DataBytes
	atom_table &atom.AtomTable
	name       atom.Atom
	sub_size   u32
	version    u32
	opcode_max u32

	functions  u32
	lines      []Line
	line_items []FuncInfo
	file_names []string

	funs           map[string]u32
	code           DataBytes
	function_table []FunctionEntry

	imports      []etf.MFA
	exports      []etf.MFA
	literals     []etf.Value
	attributes   etf.Value
	lambdas      []Lambda
	total_labels u32
	labels       map[u32]u32
	total_atoms  u32
	atoms        []string    = ['nil']
	atoms_map    map[u32]u32 = {
		u32(0): u32(0)
	}
	instructions []instruction.Instruction = []
}

pub fn BeamFile.init(at &atom.AtomTable) BeamFile {
	return BeamFile{
		atom_table: at
	}
}

pub fn (mut b BeamFile) drop_code() {
	b.code = DataBytes{}
}

pub fn (mut b BeamFile) load_file(path string) BeamFile {
	println('LOAD module ${path}')
	data := os.read_bytes(path) or { exit(1) }
	b.bytes = DataBytes{
		data: data
	}
	b.scan_beam()
	b.post_process()
	b.drop_code()

	return b
}
