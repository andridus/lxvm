module registry

pub struct TermInternal {
pub:
	kind  Kind
	value u8
}

pub enum Kind {
	literal
	integer
	atom
	x
	y
	label
	character
	extended
	float
	list
	float_reg
	alloc_list
	extended_literal
}
