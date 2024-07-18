module main

import os
import encoding.binary

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

struct Term {
	kind  Kind
	value u8
}

enum Kind {
	literal
	integer
	atom
	x
	y
	label
	character
	extended
	float
	list
	float_reg
	alloc_list
	extended_literal
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

fn main() {
	path := './hello.beam'
	file := os.open(path)!
	scan_beam(file)
	// println(res)
}

fn scan_beam(file os.File) Module {
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
	return modl
}

struct OpcodeArgs {
	op   Opcode
	args []Term
}

fn scan_instructions(data []u8) []OpcodeArgs {
	mut op_args := []OpcodeArgs{}
	mut i := 0
	for i < data.len {
		op := data[i]
		i++
		if opcode := Opcode.from(op) {
			mut args := []Term{}
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

fn compact_term(b u8) Term {
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
				Kind.literal
			}
			1 {
				Kind.integer
			}
			2 {
				Kind.atom
			}
			3 {
				Kind.x
			}
			4 {
				Kind.y
			}
			5 {
				Kind.label
			}
			6 {
				Kind.character
			}
			else {
				println('cant happen')
				exit(1)
			}
		}
		return Term{
			kind: kind
			value: value
		}
	}
	return Term{
		kind: .integer
		value: b
	}
}

fn map_loct(data []u8) []FunctionEntry {
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

fn align_bytes(size u64) int {
	rem := size % 4
	if rem == 0 {
		return 0
	} else {
		return 4 - int(rem)
	}
}
