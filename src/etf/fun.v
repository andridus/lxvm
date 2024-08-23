module etf

pub struct ErtsDispatchable {
	addresses [3]voidptr
}

pub struct ErlFunEntry {
	dispatch           ErtsDispatchable
	mod                ETerm
	arity              UInt
	index              int
	uniq               [16]u8
	old_uniq           int
	old_index          int
	refc               int
	pend_purge_address voidptr
}

pub struct FunRef {
	thing_word ETerm
	entry      &ErlFunEntry
	next       &OffHeapHeader
}
