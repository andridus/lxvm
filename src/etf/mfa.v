module etf

pub struct MFA {
pub:
	mod   ETerm
	fun   ETerm
	arity u32
}

pub fn (mfa MFA) str() string {
	return '${mfa.mod.str()}:${mfa.fun.str()}/${mfa.arity}'
}
