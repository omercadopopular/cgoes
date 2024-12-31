mata:

// Equivalent to order() for with binary sort algorithm
// We can use it to sort a vector of integers by its counts:
// 	F = _factor(y, 1)
// 	p = bin_order(y, F.keys, F.counts)
// +-+-+-+- are we using this???
`Vector' bin_order(`Vector' id, | `Matrix' info)
{
	`Integer'				i, j, num_bins, n, bin
	`Boolean'				need_expansion
	`Boolean'				compute_info
	`Factor'				F
	`Vector'				bins, offset, p

	compute_info = (args()==2 & !isfleeting(info))

	assert(cols(id)==1) // is this really necessary?
	F = _factor(id, 1)
	n = F.num_obs
	
	num_bins = F.keys[F.num_levels]
	need_expansion = F.num_levels < num_bins

	if (compute_info) {
		info = runningsum(F.counts)
		info = (1 \ info[1..rows(info)-1] :+ 1) , info
	}
	compute_info

	if (need_expansion) {
		offset = J(num_bins, 1, 0)
		offset[F.keys] = F.counts
	}
	else {
		swap(offset, F.counts)
	}
	offset = runningsum(1 \ offset[1..num_bins-1])

	swap(bins, F.levels)
	F = Factor() // clear it
	p = J(n, 1, .)

	for (i=1; i<=n; i++) {
		bin = id[i]
		offset[bin] = (j = offset[bin]) + 1
		p[j] = i
	}

	return(p)
}

end
