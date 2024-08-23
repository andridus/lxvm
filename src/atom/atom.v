module atom

import etf

pub enum Encoding {
	ascii_7bit
	latin1
	utf8
}

pub struct Atom {
pub:
	idx etf.ETerm
	str string
}

@[heap]
pub struct AtomTable {
mut:
	idxs  map[string]u32
	atoms []string
}

pub fn AtomTable.init() !&AtomTable {
	mut at := AtomTable{}
	at.load_default_atoms()!
	return &at
}

pub fn make_atom(aix u32) etf.ETerm {
	val := (aix << 6) + ((0x0 << 4) | ((0x2 << 2) | 0x3))
	return etf.ETerm(val)
}

pub fn (mut at AtomTable) insert(name string, enc Encoding) !etf.ETerm {
	match enc {
		.ascii_7bit {
			if name.len > 255 {
				return error('max characters for atom reached')
			}
		}
		.latin1 {
			if name.len > 255 {
				return error('max characters for atom reached')
			}
			// NOTE: convert latin1 to utf8
		}
		.utf8 {
			if name.len > 4 * 255 {
				return error('max characters for atom reached')
			}
		}
	}
	// NOTE: add concurrency locks
	if idx := at.idxs[name] {
		return make_atom(idx)
	} else {
		at.atoms << name
		idx := u32(at.atoms.len - 1)
		at.idxs[name] = idx
		return make_atom(idx)
	}
}

pub fn (mut at AtomTable) from(str string) !Atom {
	return Atom{
		idx: at.insert(str, .utf8)!
		str: str
	}
}

pub fn (at AtomTable) lookup(s string) ?Atom {
	if idx := at.idxs[s] {
		return Atom{
			idx: etf.ETerm(idx)
			str: s
		}
	}
	return none
}

pub fn (mut at AtomTable) idx_lookup(idx etf.UInt) ?Atom {
	if str := at.atoms[idx] {
		return Atom{
			idx: idx.to_eterm()
			str: str
		}
	}
	return none
}

pub fn (at AtomTable) eq(idx u32, idx2 u32) bool {
	if idx < at.atoms.len && idx2 < at.atoms.len {
		atom1 := at.atoms[idx]
		atom2 := at.atoms[idx2]
		return atom1 == atom2
	}
	return false
}
