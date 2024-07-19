module machine

import beam
import atom

pub struct Machine {
	atom_table atom.AtomTable
}

pub fn new() Machine {
	return Machine{}
}

pub fn (m Machine) add_module(modl beam.ModuleInternal) {
	println('TODO add module into machine')
}

pub fn (m Machine) loop() {
	for {
		println('machiine loop')
		break
	}
}
