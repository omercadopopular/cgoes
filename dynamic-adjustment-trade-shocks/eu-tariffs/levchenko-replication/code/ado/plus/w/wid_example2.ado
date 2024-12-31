*! wid_example1 v1.0.4 Thomas Blanchet 7apr2020

// Plot the evolution of the pre-tax national income of the bottom 50% of the
// population in China, France and the United States since 1978 (in log scale)

program wid_example2
	version 13

	quietly {
		preserve

		// Download and store the 2017 USD PPP exchange rate
		wid, indicators(xlcusp) areas(FR US CN) year(2017) clear
		rename value ppp
		tempfile ppp
		save "`ppp'"

		wid, indicators(aptinc) areas(FR US CN) perc(p0p50) year(1978/2017) ages(992) pop(j) clear
		merge n:1 country using "`ppp'", nogenerate

		// Convert to 2017 USD PPP (thousands)
		replace value = value/ppp/1000

		// Reshape and plot
		keep country year value
		reshape wide value, i(year) j(country) string
		label variable valueFR "France"
		label variable valueUS "United States"
		label variable valueCN "China"

		graph twoway line value* year, yscale(log) ylabel(1 2 5 10 20) ///
			ytitle("2017 PPP USD (000')") ///
			title("Average pre-tax national income of the bottom 50%") subtitle("equal-split adults") ///
			note("Source: WID.world") legend(rows(1))

		restore
	}
end
