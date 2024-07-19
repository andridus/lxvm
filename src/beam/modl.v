module beam

import encoding.binary
import errors

struct DataBytes {
pub mut:
	data        []u8
	current_pos u32
}

pub struct ModuleInternal {
mut:
	bytes          DataBytes
	total_atoms    u32
	atoms          []string
	version        u32
	opcode_max     u32
	labels         u32
	functions      u32
	code           []u8
	function_table []FunctionEntry
}

fn new(data []u8) ModuleInternal {
	return ModuleInternal{
		bytes: DataBytes{
			data: data
		}
	}
}

fn (mut b DataBytes) get_next_byte() !u8 {
	bytes := b.get_next_bytes(1)!
	if bytes.len == 1 {
		return bytes[0]
	}
	return errors.new('EOF')
}

fn (mut b DataBytes) get_next_bytes(bytes u32) ![]u8 {
	from := b.current_pos
	to := b.current_pos + bytes
	if to <= b.data.len {
		b.current_pos = to
		return b.data[from..to]
	} else {
		return errors.new('EOF')
	}
}

fn (mut b DataBytes) get_all_next_bytes() ![]u8 {
	from := b.current_pos
	if from < b.data.len {
		return b.data[from..]
	}
	return errors.new('EOF')
}

fn (mut b DataBytes) get_next_to_u32() !u32 {
	t := b.get_next_bytes(4)!
	return binary.big_endian_u32(t)
}

fn (mut b DataBytes) expect_match(list []u8) ! {
	next := b.get_next_bytes(u8(list.len))!
	if next != list {
		return errors.new_error('doesn\'t match term ${next} with ${list}')
	}
}

fn (mut b DataBytes) ignore_bytes(total int) ! {
	b.get_next_bytes(u8(total))!
}

pub fn (mut m ModuleInternal) scan_beam() {
	m.do_scan_beam() or { errors.parse_error(err) }
	m.clean()
}

fn (mut m ModuleInternal) clean() {
	m.bytes = DataBytes{}
}

pub fn (mut m ModuleInternal) do_scan_beam() ! {
	m.bytes.expect_match('FOR1'.bytes())!
	m.bytes.ignore_bytes(4)!
	m.bytes.expect_match('BEAM'.bytes())!
	for {
		name := m.bytes.get_next_bytes(4)!.bytestr()
		size := m.bytes.get_next_to_u32()!
		mut data := DataBytes{
			data: m.bytes.get_next_bytes(size)!
		}
		m.align_bytes(size)
		match name {
			'AtU8' { m.load_atu8(mut data) or {} }
			'Code' { m.load_code(mut data) or {} }
			// 'LocT' { println(map_loct(data))}
			// 'ImpT' { println(map_loct(data))}
			// 'ExpT' { println(map_loct(data))}
			else {}
		}
	}
}

fn (mut m ModuleInternal) load_atu8(mut data DataBytes) ! {
	m.total_atoms = data.get_next_to_u32()!
	for _ in 0 .. m.total_atoms {
		size0 := data.get_next_byte()!
		m.atoms << data.get_next_bytes(size0)!.bytestr()
	}
}

fn (mut m ModuleInternal) load_code(mut data DataBytes) ! {
	sub_size := data.get_next_to_u32()!
	m.version = data.get_next_to_u32()!
	m.opcode_max = data.get_next_to_u32()!
	m.labels = data.get_next_to_u32()!
	m.functions = data.get_next_to_u32()!
	data.ignore_bytes(sub_size)!
	m.code = data.get_all_next_bytes()!
}

// pub fn map_loct(data []u8) []FunctionEntry {
// 	fun_total := binary.big_endian_u32(data[0..4])
// 	mut num := u8(4)
// 	mut entries := []FunctionEntry{}
// 	for _ in 0 .. fun_total {
// 		fun := binary.big_endian_u32(data[num..(num + 4)])
// 		arity := binary.big_endian_u32(data[(num + 4)..(num + 8)])
// 		label := binary.big_endian_u32(data[(num + 8)..(num + 12)])
// 		num += 12
// 		entries << FunctionEntry{
// 			fun: fun
// 			arity: arity
// 			label: label
// 		}
// 	}
// 	return entries
// }

pub fn (mut m ModuleInternal) align_bytes(size u64) {
	rem := size % 4
	value := if rem == 0 { 0 } else { 4 - u32(rem) }
	m.bytes.current_pos += u32(value)
}
