module machine

import beam
import atom
import etf

pub struct VM {
mut:
	atom_table &atom.AtomTable
	modules    []beam.BeamModule
	reg_x      [16]etf.Value
	stack      &Stack
	cp         int = -1
	ip         u32
}

pub fn VM.init() !VM {
	atom_table := atom.AtomTable.init()!
	stack := Stack{}
	return VM{
		atom_table: atom_table
		stack:      &stack
	}
}

pub fn (mut vm VM) load_beam_from_bytes(bytes []u8) {
	mut b := beam.BeamModule.init(vm.atom_table)
	loaded_module := b.load_from_bytes(bytes) or { exit(0) }
	vm.modules << loaded_module
}

pub fn (mut vm VM) load_beam(path string) {
	mut b := beam.BeamModule.init(vm.atom_table)
	loaded_module := b.load_file(path) or { exit(0) }
	vm.modules << loaded_module
}
