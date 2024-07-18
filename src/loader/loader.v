module loader

import os
import encoding.binary
import registry
import bif
import vm

struct Module {
mut:
	total_atoms    u32
	atoms          []string
	version        u32
	opcode_max     u32
	labels         u32
	functions      u32
	code           []u8
	function_table []FunctionEntry
}

struct FunctionEntry {
	fun   u32
	arity u32
	label u32
}

struct Chunk {
	name string
	data []u8
	size int
}

pub fn start() {
	machine := vm.new_vm()
	path := './hello.beam'
	file := os.open(path) or { exit(1) }
	modl := scan_beam(file)
	instructions := scan_instructions(modl.code)
	for _, instruction in instructions {
		opcode := instruction.op
		match opcode {
			.line {
				break
			}
			else {
				println('TODO implement opcode ${opcode}')
			}
		}
	}
}

pub fn scan_beam(file os.File) Module {
	mut count := 12
	mut chunks := []Chunk{}
	mut modl := Module{}
	for !file.eof() {
		name := file.read_bytes_at(4, u64(count)).bytestr()
		size := binary.big_endian_u32(file.read_bytes_at(4, u64(count + 4)))
		data := file.read_bytes_at(size, u64(count + 8))
		match name {
			'AtU8' {
				modl.total_atoms = binary.big_endian_u32(data[0..4])
				mut num := u8(4)
				for _ in 0 .. modl.total_atoms {
					size0 := data[num] + 1
					modl.atoms << data[num..num + size0].bytestr().trim_space()
					num += size0
				}
			}
			'Code' {
				sub_size := binary.big_endian_u32(data[0..4])
				modl.version = binary.big_endian_u32(data[4..8])
				modl.opcode_max = binary.big_endian_u32(data[8..12])
				modl.labels = binary.big_endian_u32(data[12..16])
				modl.functions = binary.big_endian_u32(data[16..20])
				modl.code = data[(20 + sub_size)..]
			}
			// 'LocT' { println(map_loct(data))}
			// 'ImpT' { println(map_loct(data))}
			// 'ExpT' { println(map_loct(data))}
			else {}
		}
		chunks << Chunk{
			name: name
			size: size
			data: data
		}
		count += 8 + size + align_bytes(size)
	}
	return modl
}

pub struct OpcodeArgs {
	op   bif.Opcode
	args []registry.TermInternal
}

pub fn scan_instructions(data []u8) []OpcodeArgs {
	mut op_args := []OpcodeArgs{}
	mut i := 0
	for i < data.len {
		op := data[i]
		i++
		if opcode := bif.Opcode.from(op) {
			mut args := []registry.TermInternal{}
			if opcode.arity() > 0 {
				for _ in 0 .. opcode.arity() {
					args << compact_term(data[i])
					i++
				}
			} else {
				i++
			}
			op_args << OpcodeArgs{
				op: opcode
				args: args
			}
		}
	}
	return op_args
}

pub fn compact_term(b u8) registry.TermInternal {
	tag := b & 0b111
	if tag < 0b111 {
		mut value := u8(0)
		if 0 == (b & 0b1000) {
			value = b >> 4
		} else {
			value = 44
		}
		kind := match tag {
			0 {
				registry.Kind.literal
			}
			1 {
				registry.Kind.integer
			}
			2 {
				registry.Kind.atom
			}
			3 {
				registry.Kind.x
			}
			4 {
				registry.Kind.y
			}
			5 {
				registry.Kind.label
			}
			6 {
				registry.Kind.character
			}
			else {
				println('cant happen')
				exit(1)
			}
		}
		return registry.TermInternal{
			kind: kind
			value: value
		}
	}
	return registry.TermInternal{
		kind: .integer
		value: b
	}
}

pub fn map_loct(data []u8) []FunctionEntry {
	fun_total := binary.big_endian_u32(data[0..4])
	mut num := u8(4)
	mut entries := []FunctionEntry{}
	for _ in 0 .. fun_total {
		fun := binary.big_endian_u32(data[num..(num + 4)])
		arity := binary.big_endian_u32(data[(num + 4)..(num + 8)])
		label := binary.big_endian_u32(data[(num + 8)..(num + 12)])
		num += 12
		entries << FunctionEntry{
			fun: fun
			arity: arity
			label: label
		}
	}
	return entries
}

pub fn align_bytes(size u64) int {
	rem := size % 4
	if rem == 0 {
		return 0
	} else {
		return 4 - int(rem)
	}
}
