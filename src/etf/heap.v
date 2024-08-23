module etf
pub enum HeapFactoryMode{
        factory_closed
        factory_halloc
        factory_message
        factory_heap_frags
        factory_static
        factory_tmp
    }
@[aligned]
pub struct OffHeapHeader {
    thing_word ETerm

    /* As an optimization, the first word of user data is stored before the
     * next pointer so that the meaty part of the term (e.g. ErtsDispatchable)
     * can be loaded together with the thing word on architectures that
     * support it. */
    opaque u32
    next &OffHeapHeader
}

@[aligned]
pub struct OFFHeap {
    first &OffHeapHeader
    overhead u64     /* Administrative overhead (used to force GC). */
}
@[aligned]
pub struct HeapFactory{
    mode HeapFactoryMode
    p &u8
    hp [1]ETerm
    message &ErlMsg
    heap_frags HeapFragment
    heap_frags_saved &HeapFragment
    heap_frags_saved_used UInt
    off_heap &OFFHeap
    off_heap_saved OFFHeap
    alloc_type AllocType
}
pub fn HeapFactory.init(size UInt, alloc AllocType) HeapFactory {
    heap_fragment := etf.HeapFragment.init(size)
    return HeapFactory{
    mode: HeapFactoryMode.factory_heap_frags
    p: unsafe { nil }
    hp: heap_fragment.mem
    message: unsafe { nil }
    heap_frags: heap_fragment
    heap_frags_saved: unsafe { nil }
    off_heap: &heap_fragment.off_heap
    off_heap_saved: OFFHeap{
        first: heap_fragment.off_heap.first
        overhead: heap_fragment.off_heap.overhead
    }
    alloc_type: alloc
}
}
@[aligned]
pub struct HeapFragment {
    next &HeapFragment  /* Next heap fragment */
    off_heap OFFHeap	/* Offset heap data. */
    alloc_size UInt		/* Size in words of mem */
    used_size UInt		/* With terms to be moved to heap by GC */
    mem [1]ETerm		/* Data */
}
pub fn HeapFragment.init(size UInt) HeapFragment {
    return HeapFragment{
        next: unsafe {nil}
        off_heap: OFFHeap{
            first: unsafe {nil}
        }
        alloc_size: size
        used_size: size
        mem: [1]ETerm{}
    }
}

pub fn heap_bin_size(num_bytes u64) u64 {
	return (sizeof(ErlHeapBits)/sizeof(ETerm) - 1 + ((num_bytes) + sizeof(ETerm) - 1)/sizeof(ETerm))
}
pub fn heap_bits_size(n u64) u64{
		return heap_bin_size(nbytes(n))
}
pub fn nbytes(x u64) u64{
	return (u64(x) + 7) >> 3
}
pub fn nbits(x u64) u64{
	return x << 3
}