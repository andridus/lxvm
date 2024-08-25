module etf

pub type BeamInstruction = u32

pub struct BeamCatch {
	cp  &BeamInstruction
	cdr u32
}

// Why to do this?
pub struct BeamCatchPool {
pub mut:
	free_list    int = -1
	high_mark    u32
	tabsize      u32 = 1024
	beam_catches []BeamCatch
	is_staging   int
}

pub fn BeamCatchPool.init() [3]BeamCatchPool {
	mut bc_pools := [3]BeamCatchPool{}
	bc_pools[0].is_staging = 1
	return bc_pools
}
