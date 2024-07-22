module beam

import os
// import vm

pub fn load_file(path string) ModuleInternal {
	println('LOAD module ${path}')
	data := os.read_bytes(path) or { exit(1) }
	mut modl := new(data)
	modl.scan_beam()
	modl.scan_instructions()
	return modl
}
