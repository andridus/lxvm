module beam

import os
import encoding.binary
import registry
import bif
// import vm

struct FunctionEntry {
	fun   u32
	arity u32
	label u32
}

pub fn load_file(path string) ModuleInternal {
	println('LOAD module ${path}')
	data := os.read_bytes(path) or { exit(1) }
	mut modl := new(data)
	modl.scan_beam()
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