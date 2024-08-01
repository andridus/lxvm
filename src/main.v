module main

import machine

fn main() {
	mut vm := machine.VM.init()
	vm.load_beam('./hello.beam')
	vm.exec('do_sum/0') or {
		println(err.msg())
		exit(1)
	}
	// vm.loop()
}
