module main

fn test_compact_arg() {
	assert u8(9) == compact_arg(u8(0b10010000))
	assert u8(15) == compact_arg(u8(0b11110000))
}
