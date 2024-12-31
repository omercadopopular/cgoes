 // Hash tables
 // 1) hash0 - Perfect hashing (use the value as the hash)
 // 2) hash1 - Use hash1() with open addressing (linear probing)

// Compilation options -------
assert inlist(`is_vector', 0, 1)
if (`is_vector') {
	loc suffix
}
else {
	loc suffix ", ."
}
// ---------------------------

mata:

// Open addressing hash function (linear probing)
// Use this for non-integers (2.5, "Bank A") and big ints (e.g. 2014124233573)

`Factor' __factor_hash1_`is_vector'(
	`DataFrame' data,
    `Boolean' verbose,
    `Integer' dict_size,
    `Boolean' sort_levels,
    `Integer' max_numkeys,
    `Boolean' save_keys)
{
	`Factor'				F
	`Integer'				h, num_collisions, j, val
	`Integer'				obs, start_obs, num_obs, num_vars
	`Vector'				dict
	`Vector'				levels // new levels
	`Vector'				counts
	`Vector'				p
	`DataFrame'				keys
	`DataRow'				key, last_key
	`String'				msg


	num_obs = rows(data)
	num_vars = cols(data)
	assert(dict_size > 0 & dict_size < .)
	assert ((num_vars > 1) + (`is_vector') == 1) // XOR
	dict = J(dict_size, 1, 0)
	levels = J(num_obs, 1, 0)
	keys = J(max_numkeys, num_vars, missingof(data))
	counts = J(max_numkeys, 1, 1) // keys are at least present once!

	j = 0 // counts the number of levels; at the end j == num_levels
	val = J(0, 0, .)
	num_collisions = 0
	last_key = J(0, 0, missingof(data))

	for (obs = 1; obs <= num_obs; obs++) {
		key = data[obs`suffix']

		// (optional) Speedup when dataset is already sorted
		// (at a ~10% cost for when it's not)
		if (last_key == key) {
			start_obs = obs
			do {
				obs++
			} while (obs <= num_obs ? data[obs`suffix'] == last_key : 0 )
			levels[|start_obs \ obs - 1|] = J(obs - start_obs, 1, val)
			counts[val] = counts[val] + obs - start_obs
			if (obs > num_obs) break
			key = data[obs`suffix']
		}

		// Compute hash and retrieve the level the key is assigned to
		h = hash1(key, dict_size)
		val = dict[h]

		// (new key) The key has not been assigned to a level yet
		if (val == 0) {
			val = dict[h] = ++j
			keys[val`suffix'] = key
		}
		else if (key == keys[val`suffix']) {
			counts[val] = counts[val] + 1
		}
		// (collision) Another key already points to the same dict slot
		else {
			// Look up for an empty slot in the dict

			// Linear probing, not very sophisticate...
			do {
				++num_collisions
				++h
				if (h > dict_size) h = 1
				val = dict[h]

				if (val == 0) {
					dict[h] = val = ++j
					keys[val`suffix'] = key
					break
				}
				if (key == keys[val`suffix']) {
					counts[val] = counts[val] + 1
					break
				}
			} while (1)
		}

		levels[obs] = val
		last_key = key
	} // end for >>>

	dict = . // save memory

	if (save_keys | sort_levels) keys = keys[| 1 , 1 \ j , . |]
	counts = counts[| 1 \ j |]
	
	if (sort_levels & j > 1) {
		// bugbug: replace with binsort?
		p = order(keys, 1..num_vars) // this is O(K log K) !!!
		if (save_keys) keys = keys[p, .] // _collate(keys, p)
		counts = counts[p] // _collate(counts, p)
		levels = rows(levels) > 1 ? invorder(p)[levels] : 1
	}
	p = . // save memory


	if (verbose) {
		msg = "{txt}(%s hash collisions - %4.2f{txt}%%)\n"
		printf(msg, strofreal(num_collisions), num_collisions / num_obs * 100)
	}

	F = Factor()
	F.num_levels = j
	if (save_keys) swap(F.keys, keys)
	swap(F.levels, levels)
	swap(F.counts, counts)
	return(F)
}

end
