*! wid_example1 v1.0.4 Thomas Blanchet 7apr2020

// Plot the long run evolution wealth inequality in France

program wid_example1
	version 13

	quietly {
		preserve

		wid, indicators(shweal) areas(FR) perc(p90p100 p99p100) ages(992) pop(j) clear

		// Reshape and plot
		reshape wide value, i(year) j(percentile) string
		label variable valuep90p100 "Top 10% share"
		label variable valuep99p100 "Top 1% share"

		graph twoway line value* year, title("Wealth inequality in France") ///
			ylabel(0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%") ///
			subtitle("equal-split adults") ///
			note("Source: WID.world")

		restore
	}
end
