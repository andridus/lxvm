module beam

import atom
import os
import instruction
import etf

pub struct BeamModule {
pub mut:
	bytes            DataBytes
	atom_table       &atom.AtomTable
	mod              etf.ETerm
	mod_name				string
	name             atom.Atom
	otp_20_or_higher bool
	head_size        u32
	version          u32
	max_opcode       u32

	total_functions u32
	lines           []Line
	line_items      []FuncInfo
	file_names      []string

	funs           map[string]u32
	code           DataBytes
	function_table []FunctionEntry

	imports         []ImportEntry
	exports         []ExportEntry
	lambdas         []LambdaEntry
	static_literals LiteralTable
	literals        []etf.Value
	attributes      etf.Value
	total_labels    u32
	labels          map[u32]u32
	labels1         map[u32]Label
	total_atoms     u32
	atoms_core      []etf.ETerm
	atoms           []string
	atoms_map       map[u32]u32 = {
		u32(0): u32(0)
	}
	instructions []instruction.Instruction = []
}

pub fn BeamModule.init(at &atom.AtomTable) BeamModule {
	return BeamModule{
		atom_table: at
		atoms_core: $if x64 { [etf.ETerm(u64(0))] } $else { [etf.ETerm(u32(0))] }
		atoms:      ['nil']
	}
}

pub fn (mut b BeamModule) drop_code() {
	b.code = DataBytes{}
}

pub fn (mut b BeamModule) load_file(path string) !BeamModule {
	bytes := os.read_bytes(path)!
	return b.load_from_bytes(bytes)!
}

pub fn (mut b BeamModule) load_from_bytes(bytes []u8) !BeamModule {
	b.bytes = DataBytes{
		data: bytes
	}
	b.scan_beam()!
	// b.post_process()
	// b.drop_code()
	return b
}
