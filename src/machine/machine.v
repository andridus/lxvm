module machine

import beam
import atom

pub struct VM {
	atom_table &atom.AtomTable
mut:
	modules []beam.BeamFile
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
