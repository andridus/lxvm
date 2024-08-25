module etf

pub const erts_max_ref_numbers = 5
pub const proc_bin_size = 6 // TODO: PROC_BIN_SIZE
pub const function_max_args = 255
pub const big_arity_max = ((1 << 17) - 1)
pub const max_atom_characters = 255
pub const max_atom_sz_from_latin1 = (2 * max_atom_characters)
pub const max_atom_sz_limit = (4 * max_atom_characters) // theoretical byte limit

pub const atom_limit = (1024 * 1024)
pub const min_atom_table_size = 8192
pub const external_thing_head_size = __offsetof(ExternalThing, data) / sizeof(u32)
pub const external_pid_data_words = (8 / sizeof(u32))
pub const external_port_heap_size = external_thing_head_size + external_pid_data_words
pub const external_pid_heap_size = external_thing_head_size + external_pid_data_words
pub const map_small_limit = 32 // for debug is 3

pub const hashmap_words_per_key = 3
pub const hashmap_words_per_node = 2
pub const double_data_words = (sizeof(f64) / sizeof(ETerm))
pub const float_size_object = double_data_words + 1
pub const onheap_binary_limit = 64
pub const onheap_bits_limit = (onheap_binary_limit * 8)
pub const refc_bits_size = ((sizeof(BinRef) / sizeof(ETerm)) + (sizeof(ErlSubBits) / sizeof(ETerm)))
pub const function_ref_size = (sizeof(FunRef) / sizeof(ETerm)) // function_size = ((sizeof(ErlFunThing)/sizeof(ETerm)))
