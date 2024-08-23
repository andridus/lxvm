module etf

struct Port {
	id   u32
	low  u32
	high u32
}

struct Pid {
	num u32
	ser u32
}

type EthrAtomic = u32
type ExternalThingData = Port | Pid | u32 | u64
type HashValue = u32

struct HashBucket {
	next  &HashBucket
	value HashValue
	refc  EthrAtomic
}

struct ErlNode {
	hash_bucket HashBucket
	sysname     ETerm
	creation    u32
}

struct ExternalThing {
	header ETerm
	node   ErlNode
	next   OffHeapHeader
	data   ExternalThingData
}
