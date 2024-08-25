module etf

@[aligned]
pub struct Process{
    // common PTabElementCommon
    htop &ETerm
    stop &ETerm
    heap &ETerm
    hend &ETerm
    abandoned_heap &ETerm
    heap_sz UInt
    min_heap_size UInt
    min_vheap_size UInt
    max_heap_size UInt
    fp_exception u64
}
pub type ProcessTracer = u64
pub type PTabElementCommonRefc = SInt | EthrAtomic

struct RegProc
{
    bucket HashBucket
    p &Process
    pt &Port
    name ETerm
}

pub struct ErtsMonLnkDist {
    nodename ETerm
    connection_id int
    refc EthrAtomic
    // mtx erts_mtx_t
    alive int
    links []ErtsMonLnkNode
    monitors ErtsMonLnkNode
    orig_name_monitors ErtsMonLnkNode
    // cleanup_lop ErtsThrPrgrLaterOp
} ;
struct ErtsDistExternal {
	// dep &DistEntry
	extp &u8
	ext_endp &u8
	// heap_size DistEntry
	connection_id int
	flags int
	mld &ErtsMonLnkDist
    /* copied from DistEntry.mld */
	// attab ErtsAtomTranslationTable;
}
struct ErlMsg {
	 next &ErlMsg
	 dist_ext &ErtsDistExternal
	 heap_frag &HeapFragment
	 attached voidptr
	 m [3]ETerm
}
struct ErtsSignalCommon {
	next &ErlMsg
}

pub type ErtsMonLnkNodeType = ErtsSignalCommon //| ErtsMonLnkTreeNode | ErtsMonLnkListNode
pub type ErtsMonLnkNodeOther = voidptr | ETerm
pub struct ErtsMonLnkNode {
   node ErtsMonLnkNodeType
	 other ErtsMonLnkNodeOther
	 offset i16 /* offset from monitor/link data to this structure (node) */
	 key_offset i16 /* offset from this structure (node) to key */
	 flags i16
	 type_ i16
}
pub struct ProcessAlive {
	started_interval UInt
	reg &RegProc
	// links []ErtsLink
	// monitors []ErtsMonitor
	// lt_monitors []ErtsMonitor
}
// @[aligned]
// pub struct PTabElementCommon {
// id ETerm
// refc PTabElementCommonRefc
// tracer ProcessTracer
// trace_flags UInt
// timer EthrAtomic
// alive
// }