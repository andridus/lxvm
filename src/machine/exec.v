module machine

pub fn (mut vm VM) exec(fun string) {
	mut instr_pos := vm.modules[0].funs[fun] or {
		println("the function `${fun}` doesn't exists!")
		exit(0)
		}
	println(vm.modules[0].instructions)
	mut cp := 0
	for {
		println(instr_pos)
		instruction := vm.modules[0].instructions[instr_pos]
		println('ip: ${instr_pos}, instruction: ${instruction}')
		instr_pos++
		match instruction.op {
			.line {
				println('SKIP LINE')
			}
			.func_info {
				println('Running a function ${instruction.args}')
			}
			.move {
				println('MOVE ${instruction.args}')
			}
			.call_ext_only {
				println('CALL EXT ${instruction.args}')
			}
			.return_ {
				if cp == -1 {
					println("Process exited with normal")
					break
				}
				cp = -1
				println('RETURN ${instruction.args}')
			}
			.int_code_end {
				println('Finished processing instructions')
			}
			else {
				println('TODO ${instruction.op}')
				break
			}
		}


	}
}