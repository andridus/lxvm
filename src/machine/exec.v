module machine

import etf
import beam

pub fn (mut vm VM) exec(fun string) {
	vm.ip = vm.modules[0].funs[fun] or {
		println("the function `${fun}` doesn't exists!")
		exit(0)
	}
	for {
		instruction := vm.modules[0].instructions[vm.ip]

		vm.ip++
		match instruction.op {
			.func_info {
				mod0 := instruction.args[0]
				fun0 := instruction.args[1]
				arity := instruction.args[2]
				arity0 := arity as etf.Literal
				println('Running a function {${mod0}, ${fun0}, ${arity0}}')
			}
			.move {
				arg_a := instruction.args[0]
				arg_b := instruction.args[1]
				val := vm.load_arg(vm.modules[0], arg_a)
				match arg_b {
					etf.RegX {
						a := arg_b as etf.RegX
						vm.reg_x[a] = val
					}
					etf.RegY {
						a := arg_b as etf.RegY
						vm.reg_y[a] = val
					}
					else {
						println('unhandled register type ${arg_b}')
						exit(1)
					}
				}
			}
			.call_ext_only {
				println('CALL EXT ${instruction.args}')
			}
			.return_ {
				if vm.cp == -1 {
					println('Process exited with normal')
					println('x: ${vm.reg_x}')
					println('y: ${vm.reg_y}')
					break
				}
				vm.ip = u32(vm.cp)
				vm.cp = -1
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

fn (mut vm VM) load_arg(mod beam.BeamFile, arg etf.Value) etf.Value {
	return match arg {
		etf.Atom {
			atom_ := arg as etf.Atom
			if atom_.idx == 0 {
				etf.Nil(0)
			} else {
				atom := vm.atom_table.idx_lookup(u32(atom_.idx)) or {
					println(err.msg())
					exit(1)
				}
				etf.Atom{
					idx: atom.idx
					name: atom.str
				}
			}
		}
		etf.ExtendedLiteral {
			idx := arg as etf.ExtendedLiteral
			mod.literals[idx]
		}
		etf.RegX {
			println('regx')
			etf.Nil(0)
		}
		etf.RegY {
			println('regy')
			etf.Nil(0)
		}
		else {
			arg
		}
	}
}
