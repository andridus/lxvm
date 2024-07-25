module atom

const max_atom_chars = u8(255)

pub struct Atom {
pub:
	idx u32
	str string
}

@[heap]
pub struct AtomTable {
mut:
	idxs  map[string]u32
	atoms []string
}

pub fn AtomTable.new() AtomTable {
	mut at := AtomTable{}
	at.load_default_atoms()
	return at
}

pub fn (mut at AtomTable) insert(str string) u32 {
	if idx := at.idxs[str] {
		return idx
	} else {
		at.atoms << str
		idx := u32(at.atoms.len - 1)
		at.idxs[str] = idx
		return idx
	}
}

pub fn (mut at AtomTable) from(str string) Atom {
	return Atom{
		idx: at.insert(str)
		str: str
	}
}

pub fn (at AtomTable) lookup(s string) ?Atom {
	if idx := at.idxs[s] {
		return Atom{
			idx: idx
			str: s
		}
	}
	return none
}

pub fn (mut at AtomTable) idx_lookup(idx u32) ?Atom {
	if str := at.atoms[idx] {
		return Atom{
			idx: idx
			str: str
		}
	}
	return none
}

pub fn (at AtomTable) eq(idx u32, idx2 u32) bool {
	if idx < at.atoms.len && idx2 < at.atoms.len {
		atom1 := at.atoms[idx]
		atom2 := at.atoms[idx2]
		return atom1 == atom2
	}
	return false
}

enum Atoms {
	a_nil
	a_true
	a_false
	a_undefined
	a_value
	a_all
	a_normal
	a_internal_error
	a_badarg
	a_badarith
	a_badmatch
	a_function_clause
	a_case_clause
	a_if_clause
	a_undef
	a_badfun
	a_badarity
	a_timeout_value
	a_no_proc
	a_not_alive
	a_system_limit
	a_try_clause
	a_not_sup
	a_badmap
	a_badkey
	a_nocatch
	a_exit
	a_error
	a_throw
	a_file
	a_line
	a_ok
	a_erlang
	a_apply
	a_trap_exit
	a_start
	a_kill
	a_killed
	a_not_loaded
	a_noproc
	a_file_info
	a_device
	a_directory
	a_regular
	a_symlink
	a_other
	a_read
	a_write
	a_read_write
	a_none
	a_down
	a_process
	a_link
	a_monitor
	a_current_function
	a_current_location
	a_current_stacktrace
	a_initial_call
	a_status
	a_messages
	a_message_queue_len
	a_message_queue_data
	a_links
	a_monitored_by
	a_dictionary
	a_error_handler
	a_heap_size
	a_stack_size
	a_memory
	a_garbage_collection
	a_garbage_collection_info
	a_group_leader
	a_reductions
	a_priority
	a_trace
	a_binary
	a_sequential_trace_token
	a_catch_level
	a_backtrace
	a_last_calls
	a_total_heap_size
	a_suspending
	a_min_heap_size
	a_min_bin_vheap_size
	a_max_heap_size
	a_magic_ref
	a_fullsweep_after
	a_registered_name
	a_enoent
	a_badfile
	a_max
	a_high
	a_medium
	a_low
	a_nonode
	a_port
	a_time_offset
	a_bag
	a_duplicate_bag
	a_set
	a_ordered_set
	a_keypos
	a_write_concurrency
	a_read_concurrency
	a_heir
	a_public
	a_private
	a_protected
	a_named_table
	a_compressed
	a_undefined_function
	a_os_type
	a_win32
	a_unix
	a_info
	a_flush
	a_erts_internal
	a_flush_monitor_messages
	a_dollar_underscore
	a_dollar_dollar
	a_underscore
	a_const
	a_and
	a_or
	a_andalso
	a_andthen
	a_orelse
	a_self
	a_is_seq_trace
	a_set_seq_token
	a_get_seq_token
	a_return_trace
	a_exception_trace
	a_display
	a_process_dump
	a_enable_trace
	a_disable_trace
	a_caller
	a_silent
	a_set_tcw
	a_set_tcw_fake
	a_is_atom
	a_is_float
	a_is_integer
	a_is_list
	a_is_number
	a_is_pid
	a_is_port
	a_is_reference
	a_is_tuple
	a_is_map
	a_is_binary
	a_is_function
	a_is_record
	a_abs
	a_element
	a_hd
	a_length
	a_node
	a_round
	a_size
	a_map_size
	a_map_get
	a_is_map_key
	a_bit_size
	a_tl
	a_trunc
	a_float
	a_plus
	a_minus
	a_mult
	a_div
	a_intdiv
	a_rem
	a_band
	a_bor
	a_bxor
	a_bnot
	a_bsl
	a_bsr
	a_gt_signal
	a_egt_signal
	a_lt_signal
	a_elt_signal
	a_strict_eq_signal
	a_eq_signal
	a_neq_signal
	a_div_eq_signal
	a_not
	a_xor
	a_native
	a_second
	a_millisecond
	a_microsecond
	a_perf_counter
	a_exiting
	a_garbage_collecting
	a_waiting
	a_running
	a_runnable
	a_suspended
	a_module
	a_md5
	a_exports
	a_functions
	a_nifs
	a_attributes
	a_compile
	a_native_addresses
	a_hipe_architecture
	a_new
	a_infinity
	a_enotdir
	a_spawn
	a_tty_sl
	a_fd
	a_system_version
	a_unicode
	a_utf8
	a_latin1
	a_command
	a_data
	a_down_upcase
	a_up_upcase
	a_exit_upcase
	a_on_heap
	a_off_heap
	a_system_logger
	a_end_of_table
	a_iterator
	a_match
	a_nomatch
	a_exclusive
	a_append
	a_sync
	a_skip_type_check
	a_purify
	a_acquired
	a_busy
	a_lock_order_violation
	a_eof
	a_beam_lib
	a_version
	a_type
	a_pid
	a_new_index
	a_new_uniq
	a_index
	a_uniq
	a_env
	a_refc
	a_arity
	a_name
	a_local
	a_external
	a_machine
	a_otp_release
	a_bof
	a_cur
	a_no_integer
	a_endian
	a_little
	a_big
	a_protection
	a_trim
	a_trim_all
	a_global
	a_scope
	a_caseless
	a_ungreedy
	a_multiline
	a_dotall
	a_re_pattern
}

fn (mut at AtomTable) load_default_atoms() {
	atoms := ['nil', 'true', 'false', 'undefined', 'value', 'all', 'normal', 'internal_error',
		'badarg', 'badarith', 'badmatch', 'function_clause', 'case_clause', 'if_clause', 'undef',
		'badfun', 'badarity', 'timeout_value', 'no_proc', 'not_alive', 'system_limit', 'try_clause',
		'not_sup', 'badmap', 'badkey', 'nocatch', 'exit', 'error', 'throw', 'file', 'line', 'ok',
		'erlang', 'apply', 'trap_exit', 'start', 'kill', 'killed', 'not_loaded', 'noproc',
		'file_info', 'device', 'directory', 'regular', 'symlink', 'other', 'read', 'write',
		'read_write', 'none', 'down', 'process', 'link', 'monitor', 'current_function',
		'current_location', 'current_stacktrace', 'initial_call', 'status', 'messages',
		'message_queue_len', 'message_queue_data', 'links', 'monitored_by', 'dictionary',
		'error_handler', 'heap_size', 'stack_size', 'memory', 'garbage_collection',
		'garbage_collection_info', 'group_leader', 'reductions', 'priority', 'trace', 'binary',
		'sequential_trace_token', 'catch_level', 'backtrace', 'last_calls', 'total_heap_size',
		'suspending', 'min_heap_size', 'min_bin_vheap_size', 'max_heap_size', 'magic_ref',
		'fullsweep_after', 'registered_name', 'enoent', 'badfile', 'max', 'high', 'medium', 'low',
		'nonode@', 'port', 'time_offset', 'bag', 'duplicate_bag', 'set', 'ordered_set', 'keypos',
		'write_concurrency', 'read_concurrency', 'heir', 'public', 'private', 'protected',
		'named_table', 'compressed', 'undefined_function', 'os_type', 'win32', 'unix', 'info',
		'flush', 'erts_internal', 'flush_monitor_messages', '\$_', '\$\$', '_', 'const', 'and',
		'or', 'andalso', 'andthen', 'orelse', 'self', 'is_seq_trace', 'set_seq_token',
		'get_seq_token', 'return_trace', 'exception_trace', 'display', 'process_dump', 'enable_trace',
		'disable_trace', 'caller', 'silent', 'set_tcw', 'set_tcw_fake', 'is_atom', 'is_float',
		'is_integer', 'is_list', 'is_number', 'is_pid', 'is_port', 'is_reference', 'is_tuple',
		'is_map', 'is_binary', 'is_function', 'is_record', 'abs', 'element', 'hd', 'length', 'node',
		'round', 'size', 'map_size', 'map_get', 'is_map_key', 'bit_size', 'tl', 'trunc', 'float',
		'+', '-', '*', '/', 'div', 'rem', 'band', 'bor', 'bxor', 'bnot', 'bsl', 'bsr', '>', '>=',
		'<', '<=', '=:=', '==', '=/=', '/=', 'not', 'xor', 'native', 'second', 'millisecond',
		'microsecond', 'perf_counter', 'exiting', 'garbage_collecting', 'waiting', 'running',
		'runnable', 'suspended', 'module', 'md5', 'exports', 'functions', 'nifs', 'attributes',
		'compile', 'native_addresses', 'hipe_architecture', 'new', 'infinity', 'enotdir', 'spawn',
		'tty_sl -c -e', 'fd', 'system_version', 'unicode', 'utf8', 'latin1', 'command', 'data',
		'DOWN', 'UP', 'EXIT', 'on_heap', 'off_heap', 'system_logger', '\$end_of_table', 'iterator',
		'match', 'nomatch', 'exclusive', 'append', 'sync', 'skip_type_check', 'purify', 'acquired',
		'busy', 'lock_order_violation', 'eof', 'beam_lib', 'version', 'type', 'pid', 'new_index',
		'new_uniq', 'index', 'uniq', 'env', 'refc', 'arity', 'name', 'local', 'external', 'machine',
		'otp_release', 'bof', 'cur', 'no_integer', 'endian', 'little', 'big', 'protection', 'trim',
		'trim_all', 'global', 'scope', 'caseless', 'ungreedy', 'multiline', 'dotall', 're_pattern']
	for a in atoms {
		at.insert(a)
	}
}
