module atom

fn (mut at AtomTable) load_default_atoms() ! {
	atoms := [
		'false',
		'true',
		'_',
		'nonode@nohost',
		'\$end_of_table',
		'',
		'infinity',
		'timeout',
		'normal',
		'call',
		'return',
		'throw',
		'error',
		'exit',
		'undefined',
		'nocatch',
		'undefined_function',
		'undefined_lambda',
		'nil',
		'no',
		'none',
		'DOWN',
		'UP',
		'EXIT',
		'abandoned',
		'abort',
		'abs_path',
		'absoluteURI',
		'ac',
		'access',
		'active',
		'active_tasks',
		'active_tasks_all',
		'alias',
		'alive',
		'all',
		'all_but_first',
		'all_names',
		'alloc_info',
		'alloc_sizes',
		'allocated',
		'allocated_areas',
		'allocator',
		'allocator_sizes',
		'alloc_util_allocators',
		'allow_passive_connect',
		'already_exists',
		'already_loaded',
		'amd64',
		'anchored',
		'and',
		'andalso',
		'andthen',
		'any',
		'anycrlf',
		'apply',
		'args',
		'arg0',
		'arity',
		'asn1',
		'async',
		'async_dist',
		'asynchronous',
		'atom',
		'atom_used',
		'attributes',
		'auto_connect',
		'await_exit',
		'await_microstate_accounting_modifications',
		'await_port_send_result',
		'await_proc_exit',
		'await_result',
		'await_sched_wall_time_modifications',
		'awaiting_load',
		'awaiting_unload',
		'backtrace',
		'backtrace_depth',
		'badarg',
		'badarith',
		'badarity',
		'badfile',
		'badfun',
		'badkey',
		'badmap',
		'badmatch',
		'badrecord',
		'badsig',
		'badopt',
		'badtype',
		'bad_map_iterator',
		'bag',
		'band',
		'big',
		'bif_handle_signals_return',
		'bif_return_trap',
		'binary',
		'binary_copy_trap',
		'binary_find_trap',
		'binary_longest_prefix_trap',
		'binary_longest_suffix_trap',
		'binary_to_list_continue',
		'binary_to_term_trap',
		'block',
		'block_normal',
		'blocked',
		'blocked_normal',
		'bm',
		'bnot',
		'bor',
		'bxor',
		'break_ignored',
		'breakpoint',
		'bsl',
		'bsr',
		'bsr_anycrlf',
		'bsr_unicode',
		'build_flavor',
		'build_type',
		'busy',
		'busy_dist_port',
		'busy_limits_port',
		'busy_limits_msgq',
		'busy_port',
		'call_count',
		'call_error_handler',
		'call_memory',
		'call_time',
		'call_trace_return',
		'caller',
		'caller_line',
		'capture',
		'case_clause',
		'caseless',
		'catchlevel',
		'cause',
		'cd',
		'cdr',
		'cflags',
		'CHANGE',
		'characters_to_binary_int',
		'characters_to_list_int',
		'check_gc',
		'clear',
		'clock_service',
		'close',
		'closed',
		'code',
		'command',
		'commandv',
		'compact',
		'compat_rel',
		'compile',
		'complete',
		'compressed',
		'config_h',
		'convert_time_unit',
		'connect',
		'connected',
		'connection_closed',
		'connection_id',
		'const',
		'context_switches',
		'continue_exit',
		'control',
		'copy',
		'copy_literals',
		'counters',
		'count',
		'cpu',
		'cpu_timestamp',
		'cr',
		'crlf',
		'creation',
		'current_function',
		'current_location',
		'current_stacktrace',
		'data',
		'debug_flags',
		'decentralized_counters',
		'decimals',
		'default',
		'delay_trap',
		'demonitor',
		'deterministic',
		'dictionary',
		'dirty_bif_exception',
		'dirty_bif_result',
		'dirty_bif_trap',
		'dirty_cpu',
		'dirty_cpu_schedulers_online',
		'dirty_execution',
		'dirty_io',
		'dirty_nif_exception',
		'dirty_nif_finalizer',
		'disable_trace',
		'disabled',
		'discard',
		'dist',
		'dist_cmd',
		'dist_ctrl_put_data',
		'dist_ctrlr',
		'dist_data',
		'dist_spawn_init',
		'/',
		'div',
		'dmonitor_node',
		'\$\$',
		'\$_',
		'dollar_endonly',
		'dotall',
		'driver',
		'driver_options',
		'dsend_continue_trap',
		'duplicate_bag',
		'duplicated',
		'dupnames',
		'dynamic_node_name',
		'einval',
		'emu_flavor',
		'emu_type',
		'emulator',
		'enable_trace',
		'enabled',
		'endian',
		'env',
		'ensure_at_least',
		'ensure_exactly',
		'eof',
		'eol',
		'=:=',
		'==',
		'erl_erts_errors',
		'erl_init',
		'erl_kernel_errors',
		'erl_stdlib_errors',
		'erl_tracer',
		'erlang',
		'erl_signal_server',
		'error_handler',
		'error_info',
		'error_logger',
		'error_only',
		'erts_code_purger',
		'erts_debug',
		'erts_dflags',
		'erts_internal',
		'ets',
		'ets_info_binary',
		'ETS-TRANSFER',
		'exact_reductions',
		'exception_from',
		'exception_trace',
		'exclusive',
		'exit_status',
		'exited',
		'existing',
		'existing_processes',
		'existing_ports',
		'exiting',
		'exports',
		'extended',
		'external',
		'extra',
		'fcgi',
		'fd',
		'first',
		'firstline',
		'flags',
		'flush',
		'flush_monitor_messages',
		'flush_timeout',
		'force',
		'format_bs_fail',
		'format_cpu_topology',
		'free',
		'fullsweep_after',
		'function',
		'function_counters',
		'functions',
		'function_clause',
		'garbage_collect',
		'garbage_collecting',
		'garbage_collection',
		'garbage_collection_info',
		'gc_major_end',
		'gc_major_start',
		'gc_max_heap_size',
		'gc_minor_end',
		'gc_minor_start',
		'>=',
		'generational',
		'get_all_trap',
		'get_internal_state_blocked',
		'get_seq_token',
		'get_size',
		'get_tail',
		'get_tcw',
		'gather_gc_info_result',
		'gather_io_bytes',
		'gather_microstate_accounting_result',
		'gather_sched_wall_time_result',
		'gather_system_check_result',
		'getting_linked',
		'getting_unlinked',
		'global',
		'>',
		'grun',
		'group_leader',
		'handle',
		'have_dt_utag',
		'heap_block_size',
		'heap_size',
		'heap_sizes',
		'heap_type',
		'heart_port',
		'heir',
		'hidden',
		'hide',
		'high',
		'http',
		'httph',
		'https',
		'http_response',
		'http_request',
		'http_header',
		'http_eoh',
		'http_error',
		'http_bin',
		'httph_bin',
		'id',
		'if_clause',
		'ignore',
		'in',
		'in_exiting',
		'inactive',
		'include_shared_binaries',
		'incomplete',
		'inconsistent',
		'index',
		'info',
		'info_msg',
		'info_trap',
		'inherit',
		'init',
		'initial_call',
		'inplace',
		'input',
		'integer',
		'internal',
		'internal_error',
		'instruction_counts',
		'invalid',
		'is_constant',
		'is_seq_trace',
		'iterator',
		'io',
		'iolist_size_continue',
		'iolist_to_iovec_continue',
		'iodata',
		'iovec',
		'keypos',
		'kill',
		'killed',
		'kill_ports',
		'known',
		'label',
		'large_heap',
		'last_calls',
		'latin1',
		'ldflags',
		'=<',
		'legacy',
		'lf',
		'line',
		'line_counters',
		'line_delimiter',
		'line_length',
		'linked_in_driver',
		'links',
		'list',
		'list_to_bitstring_continue',
		'little',
		'loaded',
		'load_cancelled',
		'load_failure',
		'local',
		'logger',
		'long_gc',
		'long_message_queue',
		'long_schedule',
		'low',
		'<',
		'machine',
		'magic_ref',
		'major',
		'match',
		'match_limit',
		'match_limit_recursion',
		'match_spec',
		'match_spec_result',
		'max',
		'maximum',
		'max_heap_size',
		'mbuf_size',
		'md5',
		'memory',
		'memory_internal',
		'memory_types',
		'message',
		'message_queue_data',
		'message_queue_len',
		'messages',
		'merge_trap',
		'meta',
		'meta_match_spec',
		'micro_seconds',
		'microsecond',
		'microstate_accounting',
		'milli_seconds',
		'millisecond',
		'min',
		'min_heap_size',
		'min_bin_vheap_size',
		'minor',
		'minor_version',
		'-',
		'--',
		'module',
		'module_info',
		'monitored_by',
		'monitor',
		'monitor_nodes',
		'monitors',
		'monotonic',
		'monotonic_timestamp',
		'more',
		'multi_scheduling',
		'multiline',
		'nano_seconds',
		'nanosecond',
		'name',
		'named_table',
		'namelist',
		'native',
		'native_addresses',
		'need_gc',
		'=/=',
		'/=',
		'net_kernel',
		'net_kernel_terminated',
		'never_utf',
		'new',
		'new_index',
		'new_processes',
		'new_ports',
		'new_uniq',
		'newline',
		'nomatch',
		'no_auto_capture',
		'noconnect',
		'noconnection',
		'node',
		'node_type',
		'nodedown',
		'nodedown_reason',
		'nodeup',
		'noeol',
		'noproc',
		'normal_exit',
		'nosuspend',
		'no_fail',
		'no_float',
		'no_integer',
		'no_network',
		'no_start_optimize',
		'not_suspended',
		'not',
		'not_a_list',
		'not_loaded',
		'not_loaded_by_this_process',
		'not_pending',
		'not_owner',
		'not_purged',
		'notalive',
		'notbol',
		'noteol',
		'notempty',
		'notempty_atstart',
		'notify',
		'notsup',
		'nouse_stdio',
		'off_heap',
		'offset',
		'ok',
		'old_heap_block_size',
		'old_heap_size',
		'on_heap',
		'on_load',
		'open',
		'open_error',
		'opt',
		'or',
		'ordered_set',
		'orelse',
		'os_pid',
		'os_type',
		'os_version',
		'out',
		'out_exited',
		'out_exiting',
		'output',
		'outstanding_system_requests_limit',
		'overlapped_io',
		'owner',
		'packet',
		'packet_size',
		'parallelism',
		'parent',
		'+',
		'++',
		'pause',
		'pending',
		'pending_driver',
		'pending_process',
		'pending_purge_lambda',
		'pending_reload',
		'permanent',
		'pid',
		'port',
		'ports',
		'port_count',
		'port_limit',
		'port_op',
		'positive',
		'position',
		'prepare',
		'prepare_on_load',
		'print',
		'priority',
		'private',
		'private_append',
		'process',
		'processes',
		'processes_used',
		'process_count',
		'process_display',
		'process_limit',
		'process_dump',
		'procs',
		'proc_sig',
		'profile',
		'protected',
		'protection',
		'ptab_list_continue',
		'public',
		'queue_size',
		'raw',
		're',
		're_pattern',
		're_run_trap',
		'read_concurrency',
		'ready_error',
		'ready_input',
		'ready_output',
		'reason',
		'receive',
		'recent_size',
		'reductions',
		'refc',
		'register',
		'registered_name',
		'reload',
		'rem',
		'reply',
		'reply_demonitor',
		'reply_tag',
		'report_errors',
		'reset',
		'reset_seq_trace',
		'restart',
		'resume',
		'return_from',
		'return_to',
		'return_to_trace',
		'return_trace',
		'reuse',
		'run_process',
		'run_queue',
		'run_queue_lengths',
		'run_queue_lengths_all',
		'runnable',
		'runnable_ports',
		'runnable_procs',
		'running',
		'running_ports',
		'running_procs',
		'runtime',
		'safe',
		'save_calls',
		'sbct',
		'scheduler',
		'scheduler_id',
		'scheduler_wall_time',
		'scheduler_wall_time_all',
		'schedulers_online',
		'scheme',
		'scientific',
		'scope',
		'second',
		'seconds',
		'send',
		'send_to_non_existing_process',
		'sensitive',
		'sequential_tracer',
		'sequential_trace_token',
		'serial',
		'session',
		'set',
		'set_cpu_topology',
		'set_on_first_link',
		'set_on_first_spawn',
		'set_on_link',
		'set_on_spawn',
		'set_seq_token',
		'set_tcw',
		'set_tcw_fake',
		'short',
		'shutdown',
		'sighup',
		'signed',
		'sigterm',
		'sigusr1',
		'sigusr2',
		'sigill',
		'sigchld',
		'sigabrt',
		'sigalrm',
		'sigstop',
		'sigint',
		'sigsegv',
		'sigtstp',
		'sigquit',
		'silent',
		'size',
		'skip',
		'spawn_executable',
		'spawn_driver',
		'spawn_init',
		'spawn_reply',
		'spawn_request',
		'spawn_request_yield',
		'spawn_service',
		'spawned',
		'ssl_tls',
		'stack_size',
		'start',
		'status',
		'stderr_to_stdout',
		'stop',
		'stream',
		'strict_monotonic',
		'strict_monotonic_timestamp',
		'success_only',
		'sunrm',
		'suspend',
		'suspended',
		'suspending',
		'system',
		'system_flag_scheduler_wall_time',
		'system_limit',
		'system_version',
		'system_architecture',
		'table',
		'table_type',
		'tag',
		'term_to_binary_trap',
		'this',
		'thread_pool_size',
		'threads',
		'time_offset',
		'timeout_value',
		'*',
		'timestamp',
		'total',
		'total_active_tasks',
		'total_active_tasks_all',
		'total_heap_size',
		'total_run_queue_lengths',
		'total_run_queue_lengths_all',
		'tpkt',
		'trace',
		'traced',
		'trace_control_word',
		'trace_status',
		'tracer',
		'trap_exit',
		'trim',
		'trim_all',
		'try_clause',
		'type',
		'ucompile',
		'ucp',
		'explicit_unalias',
		'undef',
		'ungreedy',
		'unicode',
		'unregister',
		'urun',
		'use_stdio',
		'used',
		'utf8',
		'utf16',
		'utf32',
		'unblock',
		'unblock_normal',
		'uniq',
		'unit',
		'unless_suspending',
		'unloaded',
		'unloaded_only',
		'unload_cancelled',
		'unsafe',
		'value',
		'version',
		'visible',
		'wait_release_literal_area_switch',
		'waiting',
		'wall_clock',
		'warning',
		'warning_msg',
		'wordsize',
		'write_concurrency',
		'xor',
		'x86',
		'yes',
		'yield',
		'nifs',
		'auto',
		'debug_hash_fixed_number_of_locks',
		'abs',
		'adler32',
		'adler32_combine',
		'atom_to_list',
		'binary_to_list',
		'binary_to_term',
		'crc32',
		'crc32_combine',
		'date',
		'delete_module',
		'display',
		'display_string',
		'element',
		'erase',
		'exit_signal',
		'external_size',
		'float',
		'float_to_list',
		'fun_info',
		'get',
		'get_keys',
		'halt',
		'phash',
		'phash2',
		'hd',
		'integer_to_list',
		'length',
		'link',
		'list_to_atom',
		'list_to_binary',
		'list_to_float',
		'list_to_pid',
		'list_to_port',
		'list_to_ref',
		'list_to_tuple',
		'localtime',
		'localtime_to_universaltime',
		'make_ref',
		'unique_integer',
		'md5_init',
		'md5_update',
		'md5_final',
		'module_loaded',
		'function_exported',
		'monitor_node',
		'nodes',
		'now',
		'monotonic_time',
		'system_time',
		'open_port',
		'pid_to_list',
		'pre_loaded',
		'process_flag',
		'process_info',
		'put',
		'registered',
		'round',
		'self',
		'setelement',
		'spawn',
		'spawn_link',
		'split_binary',
		'statistics',
		'term_to_binary',
		'term_to_iovec',
		'time',
		'tl',
		'trunc',
		'tuple_to_list',
		'universaltime',
		'universaltime_to_localtime',
		'unlink',
		'whereis',
		'spawn_opt',
		'setnode',
		'dist_get_stat',
		'dist_ctrl_input_handler',
		'dist_ctrl_get_data',
		'dist_ctrl_get_data_notification',
		'dist_ctrl_get_opt',
		'dist_ctrl_set_opt',
		'port_info',
		'port_call',
		'port_command',
		'port_control',
		'port_close',
		'port_connect',
		'request_system_task',
		'check_process_code',
		'map_to_tuple_keys',
		'term_type',
		'map_hashmap_children',
		'time_unit',
		'perf_counter_unit',
		'is_system_process',
		'system_check',
		'dirty_process_handle_signals',
		'create_dist_channel',
		'ets_super_user',
		'dist_spawn_request',
		'no_aux_work_threads',
		'spawn_request_abandon',
		'erts_literal_area_collector',
		'release_area_switch',
		'send_copy_request',
		'port_set_data',
		'port_get_data',
		'trace_pattern',
		'trace_info',
		'trace_delivered',
		'seq_trace',
		'seq_trace_info',
		'seq_trace_print',
		'suspend_process',
		'resume_process',
		'bump_reductions',
		'math',
		'cos',
		'cosh',
		'sin',
		'sinh',
		'tan',
		'tanh',
		'acos',
		'acosh',
		'asin',
		'asinh',
		'atan',
		'atanh',
		'erf',
		'erfc',
		'exp',
		'log',
		'log2',
		'log10',
		'sqrt',
		'atan2',
		'pow',
		'start_timer',
		'send_after',
		'cancel_timer',
		'read_timer',
		'make_tuple',
		'append_element',
		'system_flag',
		'system_info',
		'system_monitor',
		'system_profile',
		'ref_to_list',
		'port_to_list',
		'fun_to_list',
		'is_process_alive',
		'raise',
		'is_builtin',
		'!',
		'append',
		'subtract',
		'is_atom',
		'is_list',
		'is_tuple',
		'is_float',
		'is_integer',
		'is_number',
		'is_pid',
		'is_port',
		'is_reference',
		'is_binary',
		'is_function',
		'is_record',
		'match_spec_test',
		'internal_request_all',
		'delete',
		'delete_object',
		'first_lookup',
		'is_compiled_ms',
		'lookup',
		'lookup_element',
		'last',
		'last_lookup',
		'match_object',
		'member',
		'next',
		'next_lookup',
		'prev',
		'prev_lookup',
		'insert',
		'insert_new',
		'rename',
		'safe_fixtable',
		'slot',
		'update_counter',
		'select',
		'select_count',
		'select_reverse',
		'select_replace',
		'match_spec_compile',
		'match_spec_run_r',
		'os',
		'getenv',
		'putenv',
		'unsetenv',
		'getpid',
		'perf_counter',
		'erl_ddll',
		'try_load',
		'try_unload',
		'loaded_drivers',
		'format_error_int',
		'run',
		'internal_run',
		'lists',
		'reverse',
		'keymember',
		'keysearch',
		'keyfind',
		'disassemble',
		'same',
		'flat_size',
		'get_internal_state',
		'set_internal_state',
		'dist_ext_to_term',
		'instructions',
		'interpreter_size',
		'dirty',
		'lcnt_control',
		'lcnt_collect',
		'lcnt_clear',
		'hibernate',
		'warning_map',
		'get_module_info',
		'is_boolean',
		'string',
		'make_fun',
		'iolist_size',
		'iolist_to_binary',
		'list_to_existing_atom',
		'is_bitstring',
		'tuple_size',
		'byte_size',
		'bit_size',
		'list_to_bitstring',
		'bitstring_to_list',
		'update_element',
		'decode_packet',
		'characters_to_binary',
		'characters_to_list',
		'bin_is_7bit',
		'atom_to_binary',
		'binary_to_atom',
		'binary_to_existing_atom',
		'dflag_unicode_io',
		'give_away',
		'setopts',
		'load_nif',
		'call_on_load_function',
		'finish_after_on_load',
		'binary_part',
		'compile_pattern',
		'matches',
		'longest_common_prefix',
		'longest_common_suffix',
		'at',
		'part',
		'list_to_bin',
		'referenced_byte_size',
		'encode_unsigned',
		'decode_unsigned',
		'nif_error',
		'prim_file',
		'internal_name2native',
		'internal_native2name',
		'internal_normalize_utf8',
		'is_translatable',
		'file',
		'native_name_encoding',
		'check_old_code',
		'universaltime_to_posixtime',
		'posixtime_to_universaltime',
		'dt_put_tag',
		'dt_get_tag',
		'dt_get_tag_data',
		'dt_spread_tag',
		'dt_restore_tag',
		'dt_prepend_vm_tag_data',
		'dt_append_vm_tag_data',
		'finish_loading',
		'insert_element',
		'delete_element',
		'integer_to_binary',
		'float_to_binary',
		'binary_to_float',
		'printable_range',
		'inspect',
		'is_map',
		'map_size',
		'maps',
		'find',
		'from_list',
		'is_key',
		'keys',
		'merge',
		'remove',
		'update',
		'values',
		'cmp_term',
		'take',
		'fun_info_mfa',
		'map_info',
		'is_process_executing_dirty',
		'check_dirty_process_code',
		'purge_module',
		'split',
		'size_shared',
		'copy_shared',
		'has_prepared_code_on_load',
		'floor',
		'ceil',
		'fmod',
		'set_signal',
		'iolist_to_iovec',
		'get_dflags',
		'new_connection',
		'map_next',
		'gather_alloc_histograms',
		'gather_carrier_info',
		'map_get',
		'is_map_key',
		'internal_delete_all',
		'internal_select_delete',
		'persistent_term',
		'erase_persistent_terms',
		'atomics_new',
		'atomics',
		'add',
		'add_get',
		'exchange',
		'compare_exchange',
		'counters_new',
		'counters_get',
		'counters_add',
		'counters_put',
		'counters_info',
		'spawn_system_process',
		'ets_lookup_binary_info',
		'ets_raw_first',
		'ets_raw_next',
		'abort_pending_connection',
		'get_creation',
		'prepare_loading',
		'beamfile_chunk',
		'beamfile_module_md5',
		'unalias',
		'from_keys',
		'binary_to_integer',
		'list_to_integer',
		'term_to_string',
		'coverage_support',
		'get_coverage_mode',
		'get_coverage',
		'reset_coverage',
		'set_coverage_mode',
		'trace_session_create',
		'trace_session_destroy',
		'erts_trace_cleaner',
		'check',
		'send_trace_clean_signal',
	]
	for a in atoms {
		at.insert(a, .utf8)!
	}
}
