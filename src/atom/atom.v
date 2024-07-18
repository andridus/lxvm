module atom

import terms
import encoding.binary

pub struct AtomInternal {
	name  string
	len   u16
	order u32
}

pub fn new(s string) AtomInternal {
	mut order := u32(0)
	bytes := s.bytes()
	if bytes.len > 0 {
		order = binary.big_endian_u32(bytes[0..4])
	}
	return AtomInternal{
		len: u16(s.len)
		order: order
		name: s
	}
}

pub struct AtomTable {
mut:
	idxs  map[string]u32
	atoms []string
}

pub fn (mut at AtomTable) register_atom(s string) u32 {
	at.atoms << s
	at.idxs[s] = u32(at.atoms.len)
	return u32(at.atoms.len)
}

pub fn (mut at AtomTable) from_str(s string) terms.Atom {
	if s in at.idxs {
		return terms.Atom{
			name: s
			value: at.idxs[s]
		}
	}
	at.atoms << s
	pos := u32(at.atoms.len)
	at.idxs[s] = pos
	return terms.Atom{
		name: s
		value: pos
	}
}

pub fn (at AtomTable) to_str(t terms.Term) !terms.Atom {
	if t.is_atom() {
		return at.lookup(t) or { return error('nor found') }
	}
	return error('notfound')
}

pub fn (at AtomTable) lookup(t terms.Term) ?terms.Atom {
	if t.is_atom() {
		atom := t as terms.Atom
		if atom.name in at.idxs {
			return terms.Atom{
				name: atom.name
				value: at.idxs[atom.name]
			}
		}
	}
	return none
}
