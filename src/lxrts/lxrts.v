module lxrts

import sync
import sync.stdatomic
import os
import atom
import etf
import beam

@[heap]
pub struct Machine {
pub mut:
	atom_table                &atom.AtomTable
	bc_pools                  [3]etf.BeamCatchPool
	module_tables             [3][]beam.BeamModule
	ranges                    [3]etf.Ranges
	the_active_code_ix        &u64
	the_staging_code_ix       &u64
	debug_start_load_ix       &i64
	debug_code_load_ix        &i64
	code_write_permission_mtx &sync.RwMutex
	export_staging_lock       &sync.Semaphore
	tracer_lock               &sync.Semaphore
	initialised               bool
}

pub fn Machine.init() !&Machine {
	atom_table := atom.AtomTable.init()!
	mut bc_pools := etf.BeamCatchPool.init()
	// mut module_tables := etf.IndexTable.init()
	mut ranges := etf.Ranges.init()
	mut debug_start_load_ix := i64(0)
	mut debug_code_load_ix := i64(0)
	mut the_active_code_ix := u64(0)
	mut the_staging_code_ix := u64(0)
	m := Machine{
		atom_table:                atom_table
		bc_pools:                  bc_pools
		ranges:                    ranges
		debug_start_load_ix:       &debug_start_load_ix
		debug_code_load_ix:        &debug_code_load_ix
		the_active_code_ix:        &the_active_code_ix
		the_staging_code_ix:       &the_staging_code_ix
		export_staging_lock:       sync.new_semaphore()
		tracer_lock:               sync.new_semaphore()
		code_write_permission_mtx: sync.new_rwmutex()
	}
	return &m
}

pub fn (mut m Machine) get_active_code_ix() u64 {
	return stdatomic.load_u64(m.the_active_code_ix)
}

pub fn (mut m Machine) get_staging_code_ix() u64 {
	return stdatomic.load_u64(m.the_staging_code_ix)
}

pub fn (mut m Machine) put_active_code_ix(value u64) {
	stdatomic.store_u64(m.the_active_code_ix, value)
}

pub fn (mut m Machine) put_staging_code_ix(value u64) {
	stdatomic.store_u64(m.the_staging_code_ix, value)
}

pub fn (mut m Machine) put_debug_start_load_ix(value i64) {
	stdatomic.store_i64(m.debug_start_load_ix, value)
}

pub fn (mut m Machine) end_staging_code() {
	the_staging_code_ix := m.get_staging_code_ix()
	m.bc_pools[the_staging_code_ix].is_staging = 0
	m.put_debug_start_load_ix(the_staging_code_ix)
	// module_end_staging
	m.put_debug_start_load_ix(-1)

	// //erts_end_staging_ranges
	// src := m.get_active_code_ix()
	// dst := m.get_staging_code_ix()
}

pub fn (mut m Machine) commit_staging_code() {
	m.export_staging_lock.wait()
	ix := m.get_staging_code_ix()
	m.put_active_code_ix(ix)
	m.put_staging_code_ix((ix + 1) % 3)
	m.export_staging_lock.post()
	// m.tracer_lock.wait()

	// m.tracer_lock.post()
}

pub fn (mut m Machine) load_preloaded() ! {
	mut loaded_modules := map[string][]u8{}
	modules := [
		'otp_ring0',
		// 'erts_code_purger',
		// 'init',
		// 'prim_buffer',
		// 'prim_eval',
		// 'prim_inet',
		// 'prim_file',
		// 'zlib',
		// 'prim_zip',
		// 'erl_prim_loader',
		// 'erlang',
		// 'erts_internal',
		// 'erl_tracer',
		// 'erts_literal_area_collector',
		// 'erts_dirty_process_signal_handler',
		// 'atomics',
		// 'counters',
		// 'persistent_term'
	]
	for mod in modules {
		loaded_modules[mod] = os.read_bytes('${@VMODROOT}/preload/${mod}.beam')!
	}
	for mod, code in loaded_modules {
		if code.len == 0 {
			return error('Failed to find preloaded code for module ${mod}')
		}
		m.load_beam_from_bytes(code)!
	}
}

pub fn (mut m Machine) load_beam_from_bytes(bytes []u8) ! {
	mut b := beam.BeamModule.init(m.atom_table)
	loaded_module := b.load_from_bytes(bytes)!
	m.put_module(loaded_module)
}

fn (mut m Machine) put_module(mod beam.BeamModule) {
	m.module_tables[m.get_staging_code_ix()] << mod
}
