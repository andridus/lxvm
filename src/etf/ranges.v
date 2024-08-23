module etf

pub struct Range {
	start &u8
	end u64 //atomic
}
pub struct Ranges {
	modules []Range
	n int
	allocated int
	search u64 //atomic
}

pub fn Ranges.init() [3]Ranges {
	mut ranges := [3]Ranges{}
	return ranges
}