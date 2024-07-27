module etf

pub enum Tag {
	version             = 131
	compressed_zlib     = 80
	new_float_ext       = 70
	bit_binary_ext      = 77
	atom_cache_ref      = 78
	new_pid_ext         = 88
	new_port_ext        = 89
	newer_reference_ext = 90
	small_integer_ext   = 97
	integer_ext         = 98
	float_ext           = 99
	atom_ext            = 100
	reference_ext       = 101
	port_ext            = 102
	pid_ext             = 103
	small_tuple_ext     = 104
	large_tuple_ext     = 105
	nil_ext             = 106
	string_ext          = 107
	list_ext            = 108
	binary_ext          = 109
	small_big_ext       = 110
	large_big_ext       = 111
	new_fun_ext         = 112
	export_ext          = 113
	new_reference_ext   = 114
	small_atom_ext      = 115
	map_ext             = 116
	fun_ext             = 117
	atom_utf8_ext       = 118
	small_atom_utf8_ext = 119
	v4_port_ext         = 120
	local_ext           = 121
}
