module bif

pub enum Opcode {
	label                = 1
	func_info
	int_code_end
	call
	call_last
	call_only
	call_ext
	call_ext_last
	bif0
	bif1
	bif2
	allocate
	allocate_heap
	allocate_zero
	allocate_heap_zero
	test_heap
	init
	deallocate
	return_
	send
	remove_message
	timeout
	loop_rec
	loop_rec_end
	wait
	wait_timeout
	// Arithmetic opcodes.
	//
	// -M_PLUS = 27,
	// -M_MINUS = 28,
	// -M_TIMES = 29,
	// -M_DIV = 30,
	// -INT_DIV = 31,
	// -INT_REM = 32,
	// -INT_BAND = 33,
	// -INT_BOR = 34,
	// -INT_BXOR = 35,
	// -INT_BSL = 36,
	// -INT_BSR = 37,
	// -INT_BNOT = 38,
	is_l                 = 39
	is_ge
	is_eq
	is_ne
	is_eq_exact
	is_ne_exact
	is_integer
	is_float
	is_number
	is_atom
	is_pid
	is_reference
	is_port
	is_nil
	is_binary
	// is_constant = 54
	is_list              = 55
	is_non_empty_list
	is_tuple
	test_arity
	select_val
	select_tuple_arity
	jump
	catch
	catch_end
	move
	get_list
	get_tuple_element
	set_tuple_element
	// put_string = 68
	put_list             = 69
	put_tuple
	put
	badmatch
	if_end
	case_end
	call_fun
	// make_fun = 76
	is_function          = 77
	call_ext_only
	//
	// Binary matching (R7).
	//
	// -BS_START_MATCH = 79,
	// -BS_GET_INTEGER = 80,
	// -BS_GET_FLOAT = 81,
	// -BS_GET_BINARY = 82,
	// -BS_SKIP_BITS = 83,
	// -BS_TEST_TAIL = 84,
	// -BS_SAVE = 85,
	// -BS_RESTORE = 86,
	//
	// Binary construction (R7A).
	//
	// -BS_INIT = 87,
	// -BS_FINAL = 88,
	bs_put_integer       = 89
	bs_put_binary
	bs_put_float
	bs_put_string
	//
	// Binary construction (R7B).
	//
	// -BS_NEED_BUF = 93,
	//
	// Floating point arithmetic (R8).
	//
	f_clear_error        = 94
	f_check_error
	f_move
	f_conv
	f_add
	f_sub
	f_mul
	f_div
	f_negate
	make_fun_2
	try
	try_end
	try_case
	try_case_end
	raise
	bs_init_2
	// bs_bits_to_bytes//
	bs_add               = 111
	apply
	apply_last
	is_boolean
	is_function_2
	bs_start_match_2
	bs_get_integer_2
	bs_get_float_2
	bs_get_binary_2
	bs_skip_bits_2
	bs_test_tail_2
	bs_save_2
	bs_restore_2
	gc_bif_1
	gc_bif_2
	// bs_final_2 //
	// bs_bits_to_byte_2 //
	// put_literal //
	is_bitstr            = 129
	bs_context_to_bianry
	bs_test_unit
	bs_match_string
	bs_init_writable
	bs_append
	bs_private_append
	trim
	bs_init_bits
	bs_get_utf8
	bs_skip_utf8
	bs_get_utf16
	bf_skip_utf16
	bs_get_utf32
	bg_skip_utf32
	bs_utf8_size
	bs_put_utf8
	bs_utf16_size
	bs_put_utf16
	bs_put_utf32
	on_load
	recv_mark
	recv_set
	gc_bif_3
	line
	put_map_assoc
	put_map_exact
	is_map
	has_map_fields
	get_map_elements
	is_tagged_tuple
	build_stack_trace
	raw_raise
	get_hd
	get_tl
	put_tuple_2
	bs_get_tail
	bs_start_match_3
	bs_get_position
	bs_set_position
}

const arities = {
	'label':                u8(1)
	'func_info':            3
	'int_code_end':         0
	'call':                 2
	'call_last':            3
	'call_only':            2
	'call_ext':             2
	'call_ext_last':        3
	'bif0':                 2
	'bif1':                 4
	'bif2':                 5
	'allocate':             2
	'allocate_heap':        3
	'allocate_zero':        2
	'allocate_heap_zero':   3
	'test_heap':            2
	'init':                 1
	'deallocate':           1
	'return_':              0
	'send':                 0
	'remove_message':       0
	'timeout':              0
	'loop_rec':             2
	'loop_rec_end':         1
	'wait':                 1
	'wait_timeout':         2
	'm_plus':               4
	'm_minus':              4
	'm_times':              4
	'm_div':                4
	'int_div':              4
	'int_rem':              4
	'int_band':             4
	'int_bor':              4
	'int_bxor':             4
	'int_bsl':              4
	'int_bsr':              4
	'int_bnot':             3
	'is_lt':                3
	'is_ge':                3
	'is_eq':                3
	'is_ne':                3
	'is_eq_exact':          3
	'is_ne_exact':          3
	'is_integer':           2
	'is_float':             2
	'is_number':            2
	'is_atom':              2
	'is_pid':               2
	'is_reference':         2
	'is_port':              2
	'is_nil':               2
	'is_binary':            2
	'is_constant':          2
	'is_list':              2
	'is_nonempty_list':     2
	'is_tuple':             2
	'test_arity':           3
	'select_val':           3
	'select_tuple_arity':   3
	'jump':                 1
	'catch':                2
	'catch_end':            1
	'move':                 2
	'get_list':             3
	'get_tuple_element':    3
	'set_tuple_element':    3
	'put_string':           3
	'put_list':             3
	'put_tuple':            2
	'put':                  1
	'badmatch':             1
	'if_end':               0
	'case_end':             1
	'call_fun':             1
	'make_fun':             3
	'is_function':          2
	'call_ext_only':        2
	'bs_start_match':       2
	'bs_get_integer':       5
	'bs_get_float':         5
	'bs_get_binary':        5
	'bs_skip_bits':         4
	'bs_test_tail':         2
	'bs_save':              1
	'bs_restore':           1
	'bs_init':              2
	'bs_final':             2
	'bs_put_integer':       5
	'bs_put_binary':        5
	'bs_put_float':         5
	'bs_put_string':        2
	'bs_need_buf':          1
	'fclearerror':          0
	'fcheckerror':          1
	'fmove':                2
	'fconv':                2
	'fadd':                 4
	'fsub':                 4
	'fmul':                 4
	'fdiv':                 4
	'fnegate':              3
	'make_fun2':            1
	'try':                  2
	'try_end':              1
	'try_case':             1
	'try_case_end':         1
	'raise':                2
	'bs_init2':             6
	'bs_bits_to_bytes':     3
	'bs_add':               5
	'apply':                1
	'apply_last':           2
	'is_boolean':           2
	'is_function2':         3
	'bs_start_match2':      5
	'bs_get_integer2':      7
	'bs_get_float2':        7
	'bs_get_binary2':       7
	'bs_skip_bits2':        5
	'bs_test_tail2':        3
	'bs_save2':             2
	'bs_restore2':          2
	'gc_bif1':              5
	'gc_bif2':              6
	'bs_final2':            2
	'bs_bits_to_bytes2':    2
	'put_literal':          2
	'is_bitstr':            2
	'bs_context_to_binary': 1
	'bs_test_unit':         3
	'bs_match_string':      4
	'bs_init_writable':     0
	'bs_append':            8
	'bs_private_append':    6
	'trim':                 2
	'bs_init_bits':         6
	'bs_get_utf8':          5
	'bs_skip_utf8':         4
	'bs_get_utf16':         5
	'bs_skip_utf16':        4
	'bs_get_utf32':         5
	'bs_skip_utf32':        4
	'bs_utf8_size':         3
	'bs_put_utf8':          3
	'bs_utf16_size':        3
	'bs_put_utf16':         3
	'bs_put_utf32':         3
	'on_load':              0
	'recv_mark':            1
	'recv_set':             1
	'gc_bif3':              7
	'line':                 1
	'put_map_assoc':        5
	'put_map_exact':        5
	'is_map':               2
	'has_map_fields':       3
	'get_map_elements':     3
	'is_tagged_tuple':      4
}

pub fn (o Opcode) arity() u8 {
	return bif.arities[o.str()] or { u8(0) }
}
