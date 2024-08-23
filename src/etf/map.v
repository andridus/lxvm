module etf

pub fn hashmap_estimated_tot_node_size(keys u32) u32 {
	// hasmap_words_per_key
	return hashmap_words_per_node * keys * 4 / 10
}

pub fn hashmap_estimated_heap_size(keys u32) u32 {
	return (keys * hashmap_words_per_key) * hashmap_estimated_tot_node_size(keys)
}
