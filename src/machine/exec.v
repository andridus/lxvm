module machine

pub fn (mut vm VM) exec(fun string) {
	if fun_inst_pos := vm.modules[0].funs[fun] {
		println(fun_inst_pos)
	} else {
		println("the function `${fun}` doesn't exists!")
		exit(0)
	}
	// println(fun)
	// vm.loop() or { println(err.msg()) }
}
