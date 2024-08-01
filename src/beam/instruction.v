module beam

import etf
import errors
import bif
import instruction

fn (mut bf BeamFile) scan_instructions() []instruction.Instruction {
	mut instructions := []instruction.Instruction{}
	for {
		op := bf.code.get_next_byte() or { break }
		opcode := bif.Opcode.from(op) or {
			errors.new_error('invalid opcode ${op}')
			break
		}
		mut args := []etf.Value{}
		if opcode.arity() > 0 {
			for _ in 0 .. opcode.arity() {
				mut arg := bf.code.compact_term_encoding() or {
					errors.new_error('invalid term encoding ${err.msg()}')
					break
				}
				if arg is etf.Atom {
					a := arg as etf.Atom
					if atom := bf.atoms[a.idx] {
						arg = etf.Atom{
							idx: a.idx
							name: atom
						}
					}
				}
				args << arg
			}
		}
		instructions << instruction.Instruction{
			op: opcode
			args: args
		}
	}
	return instructions
}

fn (mut bf BeamFile) post_process() {
	bf.process_bif() or { println(err.msg()) }
}

fn (mut bf BeamFile) process_bif() ! {
	instructions := bf.scan_instructions()
	bf.lines << Line{}
	mut last_func_start := u32(0)
	mut pos := u32(0)
	mut instructions_len := u32(0)
	for instruction in instructions {
		mut add_instruction := true
		mut instruction0 := instruction

		match instruction.op {
			.label {
				num := instruction.get_literal(0)!
				bf.labels[num] = instructions_len
				add_instruction = false
			}
			.func_info {
				// instruction.Instruction args: [_module :: atom, function :: atom, arity:: literal]
				last_func_start = pos
				atom0 := instruction.get_value(1)! as etf.Atom
				arity := instruction.get_literal(2)!
				if atom := bf.atoms_map[atom0.idx] {
					if fun_name := bf.atom_table.idx_lookup(atom) {
						fun_atom := '${fun_name.str}/${arity}'
						bf.funs[fun_atom] = instructions_len
					}
				} else {
					return errors.new_error('Not found atom ${instruction.op}')
				}
			}
			.int_code_end {
				bf.funs['nil/0'] = instructions_len
			}
			// .call { return errors.new_error('`call` not implemented') }
			// .call_last { return errors.new_error('`call_last` not implemented') }
			// .call_only { return errors.new_error('`call_only` not implemented') }
			// .call_ext { return errors.new_error('`call_ext` not implemented') }
			// .call_ext_last { return errors.new_error('`call_ext_last` not implemented') }
			.bif0 {
				// dest := instruction.get_literal(0)!
				// mfa := bf.imports[dest]
				// fun := bif.get(mfa)!
				// dest :=
			}
			.bif1 {
				// return errors.new_error('`bif1` not implemented')
			}
			.bif2 {
				// return errors.new_error('`bif2` not implemented')
			}
			// .allocate { return errors.new_error('`allocate` not implemented') }
			// .allocate_heap { return errors.new_error('`allocate_heap` not implemented') }
			// .allocate_zero { return errors.new_error('`allocate_zero` not implemented') }
			// .allocate_heap_zero { return errors.new_error('`allocate_heap_zero` not implemented') }
			// .test_heap { return errors.new_error('`test_heap` not implemented') }
			// .init { return errors.new_error('`init` not implemented') }
			// .deallocate { return errors.new_error('`deallocate` not implemented') }
			// .return_ { return errors.new_error('`return_` not implemented') }
			// .send { return errors.new_error('`send` not implemented') }
			// .remove_message { return errors.new_error('`remove_message` not implemented') }
			// .timeout { return errors.new_error('`timeout` not implemented') }
			// .loop_rec { return errors.new_error('`loop_rec` not implemented') }
			// .loop_rec_end { return errors.new_error('`loop_rec_end` not implemented') }
			// .wait { return errors.new_error('`wait` not implemented') }
			// .wait_timeout { return errors.new_error('`wait_timeout` not implemented') }
			// .m_plus { return errors.new_error('`m_plus` not implemented') }
			// .m_minus { return errors.new_error('`m_minus` not implemented') }
			// .m_times { return errors.new_error('`m_times` not implemented') }
			// .m_div { return errors.new_error('`m_div` not implemented') }
			// .int_div { return errors.new_error('`int_div` not implemented') }
			// .int_rem { return errors.new_error('`int_rem` not implemented') }
			// .int_band { return errors.new_error('`int_band` not implemented') }
			// .int_bor { return errors.new_error('`int_bor` not implemented') }
			// .int_bxor { return errors.new_error('`int_bxor` not implemented') }
			// .int_bsl { return errors.new_error('`int_bsl` not implemented') }
			// .int_bsr { return errors.new_error('`int_bsr` not implemented') }
			// .int_bnot { return errors.new_error('`int_bnot` not implemented') }
			// .is_lt { return errors.new_error('`is_lt` not implemented') }
			// .is_ge { return errors.new_error('`is_ge` not implemented') }
			// .is_eq { return errors.new_error('`is_eq` not implemented') }
			// .is_ne { return errors.new_error('`is_ne` not implemented') }
			// .is_eq_exact { return errors.new_error('`is_eq_exact` not implemented') }
			// .is_ne_exact { return errors.new_error('`is_ne_exact` not implemented') }
			// .is_integer { return errors.new_error('`is_integer` not implemented') }
			// .is_float { return errors.new_error('`is_float` not implemented') }
			// .is_number { return errors.new_error('`is_number` not implemented') }
			// .is_atom { return errors.new_error('`is_atom` not implemented') }
			// .is_pid { return errors.new_error('`is_pid` not implemented') }
			// .is_reference { return errors.new_error('`is_reference` not implemented') }
			// .is_port { return errors.new_error('`is_port` not implemented') }
			// .is_nil { return errors.new_error('`is_nil` not implemented') }
			// .is_binary { return errors.new_error('`is_binary` not implemented') }
			// .is_constant { return errors.new_error('`is_constant` not implemented') }
			// .is_list { return errors.new_error('`is_list` not implemented') }
			// .is_nonempty_list { return errors.new_error('`is_nonempty_list` not implemented') }
			// .is_tuple { return errors.new_error('`is_tuple` not implemented') }
			// .test_arity { return errors.new_error('`test_arity` not implemented') }
			// .select_val { return errors.new_error('select`_val` not implemented') }
			// .select_tuple_arity { return errors.new_error('`select_tuple_arity` not implemented') }
			// .jump { return errors.new_error('`jump` not implemented') }
			// .catch { return errors.new_error('`catch` not implemented') }
			// .catch_end { return errors.new_error('`catch_end` not implemented') }
			// .move { return errors.new_error('`move` not implemented') }
			// .get_list { return errors.new_error('`get_list` not implemented') }
			// .get_tuple_element { return errors.new_error('`get_tuple_element` not implemented') }
			// .set_tuple_element { return errors.new_error('`set_tuple_element` not implemented') }
			// .put_string { return errors.new_error('`put_string` not implemented') }
			// .put_list { return errors.new_error('`put_list` not implemented') }
			.put_tuple {
				// return errors.new_error('`put_tuple` not implemented')
			}
			.put {
				// return errors.new_error('`put` should be implemented by put_tuple2')
			}
			// .badmatch { return errors.new_error('`badmatch` not implemented') }
			// .if_end { return errors.new_error('`if_end` not implemented') }
			// .case_end { return errors.new_error('`case_end` not implemented') }
			// .call_fun { return errors.new_error('`call_fun` not implemented') }
			// .make_fun { return errors.new_error('`make_fun` not implemented') }
			// .is_function { return errors.new_error('`is_function` not implemented') }
			// .call_ext_only { return errors.new_error('`call_ext_only` not implemented') }
			// .bs_start_match { return errors.new_error('`bs_start_match` not implemented') }
			// .bs_get_integer { return errors.new_error('`bs_get_integer` not implemented') }
			// .bs_get_float { return errors.new_error('bs_get_float` not implemented') }
			// .bs_get_binary { return errors.new_error('`bs_get_binary` not implemented') }
			// .bs_skip_bits { return errors.new_error('`bs_skip_bits` not implemented') }
			// .bs_test_tail { return errors.new_error('`bs_test_tail` not implemented') }
			// .bs_save { return errors.new_error('`bs_save` not implemented') }
			// .bs_restore { return errors.new_error('`bs_restore` not implemented') }
			// .bs_init { return errors.new_error('`bs_init` not implemented') }
			// .bs_final { return errors.new_error('`bs_final` not implemented') }
			// .bs_put_integer { return errors.new_error('`bs_put_integer` not implemented') }
			// .bs_put_binary { return errors.new_error('`bs_put_binary` not implemented') }
			// .bs_put_float { return errors.new_error('`bs_put_float` not implemented') }
			.bs_put_string {
				// return errors.new_error('`bs_put_string` not implemented')
			}
			// .bs_need_buf { return errors.new_error('`bs_need_buf` not implemented') }
			// .f_clear_error { return errors.new_error('`f_clear_error` not implemented') }
			// .f_check_error { return errors.new_error('`f_check_error` not implemented') }
			// .f_move { return errors.new_error('`f_move` not implemented') }
			// .f_conv { return errors.new_error('`f_conv` not implemented') }
			// .f_add { return errors.new_error('`f_add` not implemented') }
			// .f_sub { return errors.new_error('`f_sub` not implemented') }
			// .f_mul { return errors.new_error('`f_mul` not implemented') }
			// .f_div { return errors.new_error('`f_div` not implemented') }
			// .f_negate { return errors.new_error('`f_negate` not implemented') }
			// .make_fun2 { return errors.new_error('`make_fun2` not implemented') }
			// .try { return errors.new_error('`try` not implemented') }
			// .try_end { return errors.new_error('`try_end` not implemented') }
			// .try_case { return errors.new_error('`try_case` not implemented') }
			// .try_case_end { return errors.new_error('`try_case`_end` not implemented') }
			// .raise { return errors.new_error('`raise` not implemented') }
			// .bs_init2 { return errors.new_error('`bs_init2` not implemented') }
			// .bs_bits_to_bytes { return errors.new_error('`bs_bits_to_bytes` not implemented') }
			// .bs_add { return errors.new_error('`bs_add` not implemented') }
			// .apply { return errors.new_error('`apply` not implemented') }
			// .apply_last { return errors.new_error('`apply_last` not implemented') }
			// .is_boolean { return errors.new_error('`is_boolean` not implemented') }
			// .is_function2 { return errors.new_error('`is_function2` not implemented') }
			// .bs_start_match2 { return errors.new_error('`bs_start_match2` not implemented') }
			// .bs_get_integer2 { return errors.new_error('`bs_get_integer2` not implemented') }
			// .bs_get_float2 { return errors.new_error('`bs_get_float2` not implemented') }
			// .bs_get_binary2 { return errors.new_error('`bs_get_binary2` not implemented') }
			// .bs_skip_bits2 { return errors.new_error('`bs_skip_bits2` not implemented') }
			// .bs_test_tail2 { return errors.new_error('`bs_test_tail2` not implemented') }
			// .bs_save2 { return errors.new_error('`bs_save2` not implemented') }
			// .bs_restore2 { return errors.new_error('`bs_restore2` not implemented') }
			.gc_bif1 {
				// return errors.new_error('`gc_bif1` not implemented')
			}
			.gc_bif2 {
				// return errors.new_error('`gc_bif2` not implemented')
			}
			// .bs_final2 { return errors.new_error('`bs_final2` not implemented') }
			// .bs_bits_to_bytes2 { return errors.new_error('`bs_bits_to_bytes2` not implemented') }
			// .put_literal { return errors.new_error('`put_literal` not implemented') }
			// .is_bitstr { return errors.new_error('`is_bitstr` not implemented') }
			// .bs_context_to_binary { return errors.new_error('`bs_context_to_binary` not implemented') }
			// .bs_test_unit { return errors.new_error('`bs_test_unit` not implemented') }
			.bs_match_string {
				// return errors.new_error('`bs_match_string` not implemented')
			}
			// .bs_init_writable { return errors.new_error('`bs_init_writable` not implemented') }
			// .bs_append { return errors.new_error('`bs_append` not implemented') }
			// .bs_private_append { return errors.new_error('`bs_private_append` not implemented') }
			// .trim { return errors.new_error('`trim` not implemented') }
			// .bs_init_bits { return errors.new_error('`bs_init_bits` not implemented') }
			// .bs_get_utf8 { return errors.new_error('`bs_get_utf8` not implemented') }
			// .bs_skip_utf8 { return errors.new_error('`bs_skip_utf8` not implemented') }
			// .bs_get_utf16 { return errors.new_error('`bs_get_utf16` not implemented') }
			// .bs_skip_utf16 { return errors.new_error('`bs_skip_utf16` not implemented') }
			// .bs_get_utf32 { return errors.new_error('`bs_get_utf32` not implemented') }
			// .bs_skip_utf32 { return errors.new_error('`bs_skip_utf32` not implemented') }
			// .bs_utf8_size { return errors.new_error('`bs_utf8_size` not implemented') }
			// .bs_put_utf8 { return errors.new_error('`bs_put_utf8` not implemented') }
			// .bs_utf16_size { return errors.new_error('`bs_utf16_size` not implemented') }
			// .bs_put_utf16 { return errors.new_error('`bs_put_utf16` not implemented') }
			// .bs_put_utf32 { return errors.new_error('`bs_put_utf32` not implemented') }
			.on_load {
				// return errors.new_error('`on_load` not implemented')
			}
			// .recv_mark { return errors.new_error('`recv_mark` not implemented') }
			// .recv_set { return errors.new_error('`recv_set` not implemented') }
			.gc_bif3 {
				// return errors.new_error('`gc_bif3` not implemented')
			}
			.line {
				add_instruction = false
				if bf.line_items.len > 0 {
					num := instruction.get_literal(0)!
					loc := bf.line_items[int(num)]
					if pos > 0 && pos - 1 == last_func_start {
						bf.lines << Line{
							pos: last_func_start
							loc: u32(loc.line)
						}
					} else {
						bf.lines << Line{
							pos: pos
							loc: u32(loc.line)
						}
					}
				} else {
					return errors.new_error('unreachable')
				}
			}
			// .put_map_assoc { return errors.new_error('`put_map_assoc` not implemented') }
			// .put_map_exact { return errors.new_error('`put_map_exact` not implemented') }
			// .is_map { return errors.new_error('`is_map` not implemented') }
			// .has_map_fields { return errors.new_error('`has_map_fields` not implemented') }
			// .get_map_elements { return errors.new_error('`get_map_elements` not implemented') }
			// .is_tagged_tuple { return errors.new_error('`is_tagged_tuple` not implemented') }
			// .build_stack_trace{ return errors.new_error('`build_stack_trace` not implemented') }
			// .raw_raise{ return errors.new_error('`raw_raise` not implemented') }
			// .get_hd{ return errors.new_error('`get_hd` not implemented') }
			// .get_tl{ return errors.new_error('`get_tl` not implemented') }
			// .put_tuple_2{ return errors.new_error('`put_tuple_2` not implemented') }
			.bs_get_tail {
				// return errors.new_error('`bs_get_tail` not implemented')
			}
			.bs_start_match3 {
				// return errors.new_error('`bs_start_match3` not implemented')
			}
			.bs_get_position {
				// return errors.new_error('`bs_get_position` not implemented')
			}
			.bs_set_position {
				// return errors.new_error('`bs_set_position` not implemented')
			}
			else {}
		}
		pos++
		if add_instruction {
			instructions_len++
			bf.instructions << instruction0
		}
	}
}
