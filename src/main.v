module main

import os
import encoding.binary

struct Module {
mut:
	total_atoms u32
	atoms       []string
	version     u32
	opcode_max  u32
	labels      u32
	functions   u32
	code        []u8
}

struct Chunk {
	name string
	data []u8
	size int
}

fn main() {
	path := './hello.beam'
	file := os.open(path)!
	res := scan_beam(file)
	println(res)
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
				modl.total_atoms = binary.big_endian_u32(data[0..5])
				mut num := u8(4)
				for _ in 0 .. modl.total_atoms {
					size0 := data[num] + 1
					modl.atoms << data[num..num + size0].bytestr().trim_space()
					num += size0
				}
			}
			'Code' {
				println(data[0..4])
				sub_size := binary.big_endian_u32(data[0..4])
				modl.version = binary.big_endian_u32(data[4..8])
				modl.opcode_max = binary.big_endian_u32(data[8..12])
				modl.labels = binary.big_endian_u32(data[12..16])
				modl.functions = binary.big_endian_u32(data[16..20])
				modl.code = data[(20 + sub_size)..]
			}
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

fn align_bytes(size u64) int {
	rem := size % 4
	if rem == 0 {
		return 0
	} else {
		return 4 - int(rem)
	}
}
