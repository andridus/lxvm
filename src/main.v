module main

import machine
import lxrts
// import beam
import arrays
import etf
// import time

@[export: 'lxvm_start_vm']
fn lxvm_start_vm(argc int, argv voidptr) {
	println('Starting LxVM!!!')
}

@[export: 'lxvm_beam_file_read']
fn lxvm_beam_file_read(magic voidptr, process voidptr, group_loader etf.ETerm, mod &etf.ETerm, data voidptr, size u64) {
	// volatile a := 0
	// println(a)
	// println("Start LxVm")
	// exit(0)
	// mut vm := machine.VM.init() or {
	// 	println(err)
	// 	exit(1)
	// }
	// println(data)
	// bytes := unsafe { arrays.carray_to_varray[u8](data, int(size)) }
	// // println(bytes)
	// vm.load_beam_from_bytes(bytes)
	// println('Compiled BEAM ${*mod}')
	// beam1 := &BeamFileOTP(beam0)
	// println(lxam)
	// println(beam)
	// C.beamfile_free(beam)
	// println(beam0)
	// lxam := beam_to_lxam(beam1)
	// beam0 = unsafe { &u64(&lxam) }
	// exit(0)
}

@[export: 'lxvm_beam_iff_init']
fn lxvm_beam_iff_init(magic &u8, process &u8, group_loader etf.ETerm, modp etf.ETerm, data &u8, size u32) int {
	println('${magic}, ${process}, ${group_loader}, ${modp}, ${data}, ${size}')
	mut vm := machine.VM.init() or {
		println(err)
		exit(1)
	}
	bytes := unsafe { arrays.carray_to_varray[u8](data, size) }
	vm.load_beam_from_bytes(bytes)

	// iff := beam.iff_init(bytes) or {
	//  println("${err}")
	// 	return 0
	//  }
	//  println(iff0)
	//  println(iff)
	// // iff0 = unsafe { &iff }
	// // println("make iff, ${iff}")
	exit(0)
	return 1
}

// fn main() {
// 	mut vm := machine.VM.init()
// 	vm.load_beam('/home/helder/lib/lxvm/fib1.beam')
// 	mut tm := time.StopWatch{}
// 	tm.start()
// 	args := [
// 		etf.Value(etf.Integer(10)),
// 	]

// 	vm.exec_args('fib/1', args) or {
// 		println(err.msg())
// 		exit(1)
// 	}
// 	println('execution time: ${tm.elapsed()}')
// 	// vm.loop()
// }

fn lxvm_init() !&lxrts.Machine {
	mut vm := lxrts.Machine.init()!
	vm.load_preloaded()!
	// vm.end_staging_code()
	// vm.commit_staging_code()
	vm.initialised = true
	return vm
}

fn main() {
	_ := lxvm_init() or {
		println('ERROR: ${err.msg()}')
		exit(1)
	}
	println('Process done with success')
}
