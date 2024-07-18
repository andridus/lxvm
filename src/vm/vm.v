module vm

import atom

pub struct VM {
	atom_table atom.AtomTable
}

pub fn new_vm() VM {
	return VM{}
}
