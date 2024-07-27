module main

import machine

fn main() {
	mut vm := machine.VM.init()
	vm.load_beam('./hello.beam')
	vm.exec('world/0')
	// vm.loop()
}
