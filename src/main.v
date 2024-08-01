module main

import machine
import etf

fn main() {
	mut vm := machine.VM.init()
	vm.load_beam('./hello.beam')
	args := [
		etf.Value(etf.Integer(1000)),
		etf.Integer(85),
	]
	vm.exec_args('sum/2', args) or {
		println(err.msg())
		exit(1)
	}
	// vm.loop()
}
