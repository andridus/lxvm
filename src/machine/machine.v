module machine

import beam
import atom
import etf

pub struct VM {
mut:
	atom_table &atom.AtomTable
	modules    []beam.BeamFile
	reg_x      [16]etf.Value
	reg_y      [16]etf.Value
	cp         int = -1
	ip         u32
}

pub fn VM.init() VM {
	atom_table := atom.AtomTable.new()
	return VM{
		atom_table: &atom_table
	}
}

pub fn (mut vm VM) load_beam(path string) {
	mut b := beam.BeamFile.init(vm.atom_table)
	loaded_module := b.load_file(path)
	vm.modules << loaded_module
}
