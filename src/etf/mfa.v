module etf

import atom

pub struct MFA {
pub:
	mod   atom.Atom
	fun   atom.Atom
	arity u32
}

pub fn (mfa MFA) str() string {
	return '${mfa.mod.str}:${mfa.fun.str}/${mfa.arity}'
}
