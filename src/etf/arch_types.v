module etf

pub type UInt = u64
pub type SInt = i64
pub type ETerm = u64

pub fn (e ETerm) to_uint() UInt {
	return UInt(e)
}

pub fn (u UInt) to_eterm() ETerm {
	return ETerm(u)
}

pub fn (s SInt) to_eterm() ETerm {
	return ETerm(u64(s))
}
