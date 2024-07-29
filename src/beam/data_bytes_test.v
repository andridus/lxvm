module beam

fn test_get_next_bytes() {
	mut db := DataBytes{
		data: [u8(1), 2, 3, 4, 5, 6, 7, 8, 9, 0]
	}
	assert db.get_next_byte()! == u8(1)
	assert db.get_next_bytes(4)! == [u8(2), 3, 4, 5]
	assert db.get_next_byte()! == u8(6)
	assert db.get_next_byte()! == u8(7)
	assert db.get_next_bytes(3)! == [u8(8), 9, 0]
	mut received_message1 := ''
	db.get_next_byte() or { received_message1 = err.msg() }
	assert received_message1 == 'hide: EOF'

	mut received_message2 := ''
	db.get_next_bytes(3) or { received_message2 = err.msg() }
	assert received_message2 == 'hide: EOF'
}

fn test_get_next_u32() {
	mut db := DataBytes{
		data: [u8(0), 0, 0, 5, 0, 0, 71, 2, 1, 0]
	}
	assert db.get_next_u32()! == u32(5)
	assert db.get_next_u32()! == u32(18178)
	mut received_message2 := ''
	db.get_next_u32() or { received_message2 = err.msg() }
	assert received_message2 == 'hide: EOF'
}

fn test_expect_match() {
	mut db := DataBytes{
		data: [u8(1), 2, 3, 4, 5, 6, 7, 8, 9, 0]
	}
	mut err1 := 0
	db.expect_match([u8(1), 2]) or { err1 = 1 }
	assert err1 == 0
}

fn test_doesnt_expect_match() {
	mut db := DataBytes{
		data: [u8(1), 2, 3, 4, 5, 6, 7, 8, 9, 0]
	}
	mut err2 := ''
	db.expect_match([u8(1), 4]) or { err2 = err.msg() }
	assert err2 == "error: doesn't match term [1, 2] with [1, 4]"
}
