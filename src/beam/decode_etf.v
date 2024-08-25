module beam

import etf
import errors
import math.big

pub fn (mut bf BeamModule) decode_ext_size(data []u8) !u64 {
	mut data0 := DataBytes{
		data: data
	}
	version := data0.get_next_byte()!
	if version != 131 {
		return errors.new_error('invalid version')
	}
	return bf.decode_size(mut data0)!
}

fn add_terms(term u32, n u32) !u32 {
	if (max_u32 - term) > n {
		return term + n
	}
	return error('max value for terms')
}

fn (mut bf BeamModule) decode_size(mut data DataBytes) !u64 { // it's should be UInt ?
	mut heap_size := u64(0)
	mut atom_extra_skip := 0
	mut terms := u32(1)

	// reds := u32(0)
	for terms > 0 {
		tag := etf.Tag.from(data.get_next_byte()!)!
		println('${tag}[${int(tag)}]')
		match tag {
			.integer_ext {
				data.ignore_bytes(4)!
				// NOTE: there are if for non x64
			}
			.small_integer_ext {
				data.ignore_bytes(1)!
			}
			.small_big_ext {
				n := data.get_next_byte()!
				data.ignore_bytes(2)!
				heap_size += 1 + (n + sizeof(etf.ETerm) - 1 / sizeof(etf.ETerm))
			}
			.large_big_ext {
				n := data.get_next_u32()!
				if n > etf.big_arity_max * sizeof(u64) {
					return error('exceed max big size')
				}
				data.ignore_bytes(5)!
				heap_size += 2 + (n + sizeof(etf.ETerm) - 1 / sizeof(etf.ETerm))
			}
			.atom_ext {
				n := data.get_next_u16()!
				if n > etf.max_atom_characters {
					return error('max atom characters')
				}
				data.ignore_bytes(n + atom_extra_skip)!
				atom_extra_skip = 0
			}
			.small_atom_ext {
				n := data.get_next_byte()!
				if n > etf.max_atom_characters {
					return error('max atom characters')
				}
				data.ignore_bytes(1 + atom_extra_skip)!
				atom_extra_skip = 0
			}
			.small_atom_utf8_ext {
				n := data.get_next_byte()!
				if n > etf.max_atom_sz_limit {
					return error('max atom characters')
				}
				data.ignore_bytes(1 + atom_extra_skip)!
				atom_extra_skip = 0
			}
			.atom_cache_ref {
				data.ignore_bytes(1 + atom_extra_skip)!
				atom_extra_skip = 0
			}
			.new_pid_ext {
				atom_extra_skip = 12
				heap_size += etf.external_pid_heap_size + 1
				terms = add_terms(terms, 1)!
			}
			.pid_ext {
				atom_extra_skip = 9
				heap_size += etf.external_pid_heap_size + 1
				terms = add_terms(terms, 1)!
			}
			.new_port_ext {
				atom_extra_skip = 8
				heap_size += etf.external_port_heap_size + 1
				terms = add_terms(terms, 1)!
			}
			.port_ext {
				atom_extra_skip = 5
				heap_size += etf.external_port_heap_size + 1
				terms = add_terms(terms, 1)!
			}
			.v4_port_ext {
				atom_extra_skip = 12
				heap_size += etf.external_port_heap_size + 1
				terms = add_terms(terms, 1)!
			}
			.newer_reference_ext {
				atom_extra_skip = 4
				n := data.get_next_u16()!
				if n > etf.erts_max_ref_numbers {
					return error('exceed max ref numbers')
				}
				data.ignore_bytes(2)!
				atom_extra_skip += 4 * n
				$if x64 {
					heap_size += etf.external_thing_head_size + n / 2 + 1
				} $else {
					heap_size += etf.external_thing_head_size + n
				}
				terms = add_terms(terms, 1)!
			}
			.reference_ext {
				heap_size += etf.external_thing_head_size + 1
				atom_extra_skip = 5
				terms += 1
			}
			.nil_ext {
				// if atom_extra_skip {
				// 	 /*
				// 		* atom_extra_skip != 0 should only appear due to local encoding,
				// 		* or compressed ets encoding, of a node name in internal
				// 		* pids/ports/refs. If not currently inside a local encoding,
				// 		* this is an error...
				// 		*/
				// }
			}
			.list_ext {
				n := data.get_next_u32()!
				terms = add_terms(terms, n + 1)!
				heap_size += 2 * n
			}
			.small_tuple_ext {
				n := data.get_next_byte()!
				terms = add_terms(terms, n)!
				if n > 0 {
					heap_size += n + 1
				}
			}
			.large_tuple_ext {
				n := data.get_next_u32()!
				data.ignore_bytes(n)!
				terms = add_terms(terms, n)!
				if n > 0 {
					heap_size += n + 1
				}
			}
			.map_ext {
				n := data.get_next_u32()!
				terms = add_terms(terms, n * 2)!
				if n <= etf.map_small_limit {
					heap_size += n + 3 + 1 + n

					// if n > 0 { // latest version
					// 	heap_size += 1 + n
					// }
				}
				// $if x64 {
				// 	else if (n >> 31) != 0 {
				// 		return error('Avoid overflow by limiting the number of elements in * a map to 2^31-1 (about 2 billions).')
				// 	}
				// } $else {
				else if (n >> 30) != 0 {
					return error("Can't possibly fit in memory on 32-bit machine.")
				}
				// }
				else {
					// data.ignore_bytes(2 * n)!
					heap_size += etf.hashmap_estimated_heap_size(n)
				}
			}
			.string_ext {
				n := data.get_next_u16()!
				data.ignore_bytes(n)!
				heap_size += 2 * n
			}
			.float_ext {
				data.ignore_bytes(31)!
				heap_size += etf.float_size_object
			}
			.new_float_ext {
				data.ignore_bytes(8)!
				heap_size += etf.float_size_object
			}
			.binary_ext {
				n := data.get_next_u32()!
				data.ignore_bytes(n)!

				if n < etf.onheap_binary_limit {
					heap_size += etf.heap_bin_size(n)
				} else {
					heap_size += etf.proc_bin_size
				}
				// exit(0)
			}
			.bit_binary_ext {
				n := data.get_next_u32()!
				// $if x32 {

				// }
				data.ignore_bytes(3)!
				if n < etf.onheap_binary_limit {
					heap_size += etf.heap_bits_size(etf.nbits(u64(n)))
				}
				heap_size += etf.refc_bits_size
			}
			.export_ext {
				terms = add_terms(terms, 3)!
				heap_size += 2
			}
			.new_fun_ext {
				data.ignore_bytes(1 + 16 + 4 + 4)!
				num_free := data.get_next_u32()!
				if num_free > etf.function_max_args {
					return error('exceed max args')
				}
				terms = add_terms(terms, 4 + num_free)!
				heap_size += etf.function_ref_size + num_free
			}
			.fun_ext {
				num_free := data.get_next_u32()!
				if num_free > etf.function_max_args {
					return error('exceed max args')
				}
				terms = add_terms(terms, 4 + num_free)!
				heap_size += etf.function_ref_size + num_free
			}
			.atom_internal_ref2 {
				data.ignore_bytes(2 + atom_extra_skip)!
				atom_extra_skip = 0
			}
			.atom_internal_ref3 {
				data.ignore_bytes(3 + atom_extra_skip)!
				atom_extra_skip = 0
			}
			// TODO: .binary_internal_ref {
			// 	if(!internal_tags) { error('there are not internal tags') }
			// }
			// TODO: .bit_binary_internal_ref {
			// 	if(!internal_tags) { error('there are not internal tags') }
			// }
			else {
				return error('tag `${tag}` is not defined')
			}
		}
		terms--
	}

	// AQUI
	return heap_size
}

pub fn (mut bf BeamModule) decode_etf(data []u8) !etf.Value {
	mut data0 := DataBytes{
		data: data
	}
	version := data0.get_next_byte()!
	if version != 131 {
		return errors.new_error('invalid version')
	}
	return bf.decode_ext(mut data0)!
}

fn (mut bf BeamModule) decode_ext(mut data DataBytes) !etf.Value { // it's should be UInt ?
	tag := etf.Tag.from(data.get_next_byte()!)!
	value := match tag {
		.integer_ext {
			bf.decode_integer(mut data)!
		}
		.small_integer_ext {
			bf.decode_small_integer(mut data)!
		}
		.small_big_ext {
			bf.decode_bignum(1, mut data)!
		}
		.large_big_ext {
			bf.decode_bignum(4, mut data)!
		}
		.atom_ext {
			bf.decode_atom_ext(mut data)!
		}
		.small_atom_ext {
			bf.decode_small_atom_ext(mut data)!
		}
		.atom_utf8_ext {
			bf.decode_atom_ext(mut data)!
		}
		.small_atom_utf8_ext {
			bf.decode_small_atom_ext(mut data)!
		}
		.atom_cache_ref {
			// Used for distribution
			etf.Value(etf.Nil(0))
		}
		.pid_ext {
			bf.decode_pid(mut data)!
		}
		.new_pid_ext {
			bf.decode_pid(mut data)!
		}
		.port_ext {
			bf.decode_port(mut data)!
		}
		.new_port_ext {
			bf.decode_port(mut data)!
		}
		.v4_port_ext {
			etf.Value(etf.Nil(0))
		}
		.reference_ext {
			bf.decode_reference(mut data)!
		}
		.newer_reference_ext {
			bf.decode_new_reference(mut data)!
		}
		.nil_ext {
			etf.Value(etf.Nil(0))
		}
		.list_ext {
			bf.decode_list(mut data)!
		}
		.small_tuple_ext {
			bf.decode_tuple(1, mut data)!
		}
		.large_tuple_ext {
			bf.decode_tuple(4, mut data)!
		}
		.map_ext {
			bf.decode_map(mut data)!
		}
		.string_ext {
			bf.decode_string(mut data)!
		}
		.float_ext {
			bf.decode_float(mut data)!
		}
		.new_float_ext {
			bf.decode_new_float(mut data)!
		}
		.binary_ext {
			bf.decode_binary(mut data)!
		}
		.bit_binary_ext {
			bf.decode_bit_binary(mut data)!
		}
		.export_ext {
			bf.decode_export(mut data)!
		}
		.fun_ext {
			bf.decode_fun(mut data)!
		}
		.new_fun_ext {
			bf.decode_new_fun(mut data)!
		}
		.atom_internal_ref2 {
			etf.Value(etf.Nil(0))
		}
		.atom_internal_ref3 {
			etf.Value(etf.Nil(0))
		}
		// TODO: .binary_internal_ref {
		// 	if(!internal_tags) { error('there are not internal tags') }
		// }
		// TODO: .bit_binary_internal_ref {
		// 	if(!internal_tags) { error('there are not internal tags') }
		// }
		else {
			return error('tag `${tag}` is not defined')
		}
	}

	return value
}

fn (mut bf BeamModule) decode_atom_ext(mut data DataBytes) !etf.Value {
	//		atom_utf8_ext
	//    length: 2-bytes
	//		atom_name: length-bytes
	size := data.get_next_u16()!
	str := data.get_next_bytes(size)!
	atom := bf.atom_table.from(str.bytestr())!
	return etf.Atom{
		idx:  atom.idx
		name: atom.str
	}
}

fn (mut bf BeamModule) decode_small_atom_ext(mut data DataBytes) !etf.Value {
	//		small_atom_utf8_ext
	//    length: 1-bytes
	//		atom_name: length-bytes
	size := data.get_next_byte()!
	str := data.get_next_bytes(size)!
	atom := bf.atom_table.from(str.bytestr())!
	return etf.Atom{
		idx:  atom.idx
		name: atom.str
	}
}

fn (bf BeamModule) decode_string(mut data DataBytes) !etf.Value {
	//		string_ext
	//    length: 2-bytes
	//		characters: length-bytes
	data.ignore_bytes(2)!
	str := data.get_all_next_bytes()!
	return etf.String(str.bytestr())
}

fn (bf BeamModule) decode_integer(mut data DataBytes) !etf.Value {
	//		integer_ext
	//    value: 4-bytes
	return etf.Integer(data.get_next_u32()!)
}

fn (bf BeamModule) decode_small_integer(mut data DataBytes) !etf.Value {
	//		small_integer_ext
	//    value: 1-byte
	return etf.Integer(data.get_next_byte()!)
}

fn (bf BeamModule) decode_bignum(n u8, mut data DataBytes) !etf.Value {
	//    small_big_ext
	//    n: 1-byte
	//	  sign: 1-byte
	//		rest: calculate with big-endian
	size := if n == 4 { data.get_next_u32()! } else { data.get_next_byte()! }
	sign := if data.get_next_byte()! == 1 { -1 } else { 0 }
	rest := data.get_next_bytes(size)!
	if size != rest.len {
		return errors.new_error('invalid bytes for bignum')
	}
	r := big.integer_from_bytes(rest.reverse(), big.IntegerConfig{ signum: sign })
	if r.bit_len() < 60 {
		return etf.Integer(r.int())
	} else {
		return etf.BigInt(r)
	}
}

fn (bf BeamModule) decode_float(mut data DataBytes) !etf.Value {
	//		float_ext
	//    value: 31-bytes
	// data.get_next_bytes(31)!.bytestr()
	return etf.Float(0.0)
}

fn (bf BeamModule) decode_new_float(mut data DataBytes) !etf.Value {
	//		new_float_ext
	//    value: 8-bytes
	// float := data.get_bytes(8)!
	return etf.Float(0.0)
}

fn (mut bf BeamModule) decode_tuple(n u8, mut data DataBytes) !etf.Value {
	//    small_tuple_ext
	//    arity: 1-byte
	//		n: elements
	arity := if n == 4 { data.get_next_u32()! } else { data.get_next_byte()! }
	mut terms := []etf.Value{}
	for _ in 0 .. arity {
		terms << bf.decode_ext(mut data)!
	}
	return etf.Tuple(terms)
}

fn (mut bf BeamModule) decode_list(mut data DataBytes) !etf.Value {
	size := data.get_next_u32()!
	mut terms := []etf.Value{}
	for _ in 0 .. size {
		terms << bf.decode_ext(mut data)!
	}
	return etf.List(terms)
}

fn (mut bf BeamModule) decode_pid(mut data DataBytes) !etf.Value {
	//    pid_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_port(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_reference(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_new_reference(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_map(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_binary(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_bit_binary(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_export(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_fun(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}

fn (mut bf BeamModule) decode_new_fun(mut data DataBytes) !etf.Value {
	//    port_ext
	//    arity: 1-byte
	//		n: elements
	// TODO
	return etf.Nil(0)
}
