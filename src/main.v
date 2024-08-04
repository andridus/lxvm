module main

import machine
import etf
import time

fn main() {
	mut vm := machine.VM.init()
	vm.load_beam('/home/helder/lib/lxvm/fib1.beam')
	mut tm := time.StopWatch{}
	tm.start()
	args := [
		etf.Value(etf.Integer(10)),
	]
	vm.exec_args('fib/1', args) or {
		println(err.msg())
		exit(1)
	}
	println('execution time: ${tm.elapsed()}')
	// vm.loop()
}
