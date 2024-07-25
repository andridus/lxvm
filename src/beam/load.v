module beam

import atom
import os

pub struct MFA {
	mod      atom.Atom
	function atom.Atom
	arity    u32
}

pub struct BeamFile {
mut:
	atom_table     &atom.AtomTable
	bytes          DataBytes
	total_atoms    u32
	atoms          []string
	atoms_map      map[u32]u32
	sub_size       u32
	version        u32
	opcode_max     u32
	labels         u32
	mod_labels     map[u32]u32
	functions      u32
	lines          []Line
	line_items     []FuncInfo
	file_names     []string
	funs           map[string]u32
	imports        []MFA
	code           DataBytes
	function_table []FunctionEntry
}

pub fn BeamFile.init(at &atom.AtomTable) BeamFile {
	return BeamFile{
		atom_table: at
	}
}

pub fn (mut b BeamFile) load_file(path string) BeamFile {
	println('LOAD module ${path}')
	data := os.read_bytes(path) or { exit(1) }
	b.bytes = DataBytes{
		data: data
	}
	b.scan_beam()
	b.post_process()

	return b
}
