module main

import beam
import machine

fn main() {
	loaded_module := beam.load_file('./hello.beam')
	vm := machine.new()
	vm.add_module(loaded_module)
	vm.loop()
}
