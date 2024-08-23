module etf

pub struct ErlHeapBits {
	thing_word ETerm
	size       u32
	data       [1]ETerm
}

pub struct ErlSubBits {
	thing_word ETerm
	base_flags u32
	start      u32
	end        u32
	orig       ETerm
}

pub struct BinRef {
	thing_word ETerm
	val        []u8
	next       &OffHeapHeader
}
