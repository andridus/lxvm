module machine

import etf
import beam
import bif
import errors

pub fn (mut vm VM) exec_args(fun string, args []etf.Value) ! {
	for i, arg in args {
		vm.reg_x[i] = arg
	}
	vm.exec(fun)!
}

pub fn (mut vm VM) exec(fun string) ! {
	vm.ip = vm.modules[0].funs[fun] or {
		errors.panic("the function `${fun}` doesn't exists!")
		exit(0)
	}
	mut i := 0
	for {
		i++
		instruction := vm.modules[0].instructions[vm.ip]
		vm.ip++
		match instruction.op {
			.func_info {}
			.move {
				arg_a := instruction.args[0]
				arg_b := instruction.args[1]
				val := vm.get_arg_value(vm.modules[0], arg_a)

				match arg_b {
					etf.RegX {
						a := arg_b as etf.RegX
						vm.reg_x[a] = val
					}
					etf.RegY {
						vm.stack.update(vm.stack.total() - (arg_b + 2), val)
					}
					else {
						errors.panic('unhandled register type ${arg_b}')
						exit(1)
					}
				}
			}
			.call {
				// [arity, jmp]
				jmp := instruction.args[1]
				if jmp is etf.Label {
					vm.cp = vm.ip
					vm.ip = vm.modules[0].labels[jmp] - 1
				}
			}
			.call_only {
				// [arity, jmp]
				jmp := instruction.args[1]
				if jmp is etf.Label {
					vm.ip = vm.modules[0].labels[jmp] - 1
				}
			}
			.call_ext_only {}
			.return_ {
				if vm.cp == -1 {
					println('Process exited with normal')
					println('x: ${vm.reg_x}')
					println('stack: ${vm.stack}')
					break
				}
				vm.ip = u32(vm.cp)
				vm.cp = -1
			}
			.int_code_end {}
			.gc_bif2 {
				if instruction.args.len != 6 {
					return error('not args')
				}
				// [fail, live, bif_fun, arg1, arg2, dest]

				// fail := instruction.args[0]
				// live := instruction.args[1]
				if instruction.args[2] is etf.Literal {
					bif_fun := instruction.args[2] as etf.Literal
					arg1 := vm.get_arg_value(vm.modules[0], instruction.args[3])
					arg2 := vm.get_arg_value(vm.modules[0], instruction.args[4])
					ret := instruction.args[5]
					mfa0 := vm.modules[0].imports[bif_fun].to_mfa()
					val := bif.apply(mfa0, [arg1, arg2])!
					// val := etf.Nil(0)
					// save in register
					match ret {
						etf.RegX {
							vm.reg_x[ret] = val
						}
						etf.RegY {
							vm.stack.update(vm.stack.total() - (ret + 2), val)
						}
						else {}
					}

					// println(vm.modules[0].imports)
				} else {
					errors.panic('error')
					exit(1)
				}
			}
			.allocate_zero {
				if instruction.args[0] is etf.Literal && instruction.args[1] is etf.Literal {
					need := instruction.args[0] as etf.Literal
					for _ in 0 .. u32(need) {
						vm.stack.put(etf.Nil(0))
					}
					vm.stack.put(etf.CP(vm.cp))
				} else {
					errors.panic('Bad Argument!')
					exit(1)
				}
			}
			.deallocate {
				arg_a := instruction.args[0]
				cp := vm.stack.pop()
				if arg_a is etf.Literal {
					vm.stack.trim(vm.stack.total() - arg_a)
					if cp is etf.CP {
						vm.cp = cp
					} else {
						errors.panic('Bad CP value! ${cp}')
					}
				} else {
					errors.panic('bad argument')
				}
			}
			.is_eq {
				if instruction.args.len == 3 {
					fail := vm.get_label(vm.modules[0], instruction.args[0])!
					arg1 := vm.get_arg_value(vm.modules[0], instruction.args[1])
					arg2 := vm.get_arg_value(vm.modules[0], instruction.args[2])
					if arg1 != arg2 {
						vm.ip = fail
					}
				} else {
					errors.panic('Bad Argument!')
				}
			}
			else {
				errors.panic('TODO ${instruction.op}')
				break
			}
		}
	}
}

fn (mut vm VM) get_label(mod beam.BeamModule, arg etf.Value) !u32 {
	if arg is etf.Label {
		a := arg as etf.Label
		if vm.modules[0].labels.len > a {
			return mod.labels[u32(a)]
		}
	}
	return error('not found')
}

fn (mut vm VM) get_arg_value(mod beam.BeamModule, arg etf.Value) etf.Value {
	return match arg {
		etf.Atom {
			atom_ := arg as etf.Atom
			if atom_.idx == etf.ETerm(u32(0)) {
				etf.Nil(0)
			} else {
				atom := vm.atom_table.idx_lookup(atom_.idx.to_uint()) or {
					println(err.msg())
					exit(1)
				}
				etf.Atom{
					idx:  atom.idx
					name: atom.str
				}
			}
		}
		etf.ExtendedLiteral {
			idx := arg as etf.ExtendedLiteral
			mod.literals[idx]
		}
		etf.RegX {
			vm.reg_x[arg]
		}
		etf.RegY {
			vm.stack.get(vm.stack.total() - (arg + 2))
		}
		else {
			arg
		}
	}
}
