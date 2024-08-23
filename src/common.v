module main

type Eterm = u64

struct BeamfileImportEntry {
    mod Eterm
		function Eterm
		arity int
}
struct BeamfileExportEntry {
		function Eterm
		arity int
		label int
}
struct BeamfileLambdaEntry {
		function Eterm
		index int
		old_uniq int
		num_free int
		arity int
		label int
}

struct BeamfileLineEntry {
		location int
		name_index int
}

struct BeamfileLiteralEntry {
		heap_fragments &HeapFragment
		value Eterm
}

struct BeamType {
		type_union int
		metadata_flags int
		min i64
		max i64
		size_unit u8
}
struct OffHeapHeader {
    thing_word Eterm

    /* As an optimization, the first word of user data is stored before the
     * next pointer so that the meaty part of the term (e.g. ErtsDispatchable)
     * can be loaded together with the thing word on architectures that
     * support it. */
    opaque u32
    next &OffHeapHeader
};

struct OFFHeap {
    first &OffHeapHeader
    overhead u64     /* Administrative overhead (used to force GC). */
}
struct HeapFragment {
    next &HeapFragment	/* Next heap fragment */
    off_heap OFFHeap	/* Offset heap data. */
    alloc_size u32		/* Size in words of mem */
    used_size u32		/* With terms to be moved to heap by GC */
    mem [1]Eterm		/* Data */
};