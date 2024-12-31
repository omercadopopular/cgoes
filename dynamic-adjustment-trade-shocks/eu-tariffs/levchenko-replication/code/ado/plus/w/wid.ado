*! wid v1.0.4 Thomas Blanchet 7apr2020

program wid
	version 13
	
	syntax, [INDicators(string) AReas(string) Years(numlist) Perc(string) AGes(string) POPulation(string) METAdata EXclude clear]
	
	// ---------------------------------------------------------------------- //
	// Check if there are already some data in memory
	// ---------------------------------------------------------------------- //
	
	quietly count
	if (r(N) > 0 & "`clear'" == "") {
		display as error "no; data in memory would be lost"
		exit 4
	}
	
	// ---------------------------------------------------------------------- //
	// Check the user specified at least some countries and/or indicators
	// ---------------------------------------------------------------------- //
	
	if (inlist("`indicators'", "", "_all") & inlist("`areas'", "", "_all")) {
		display as error "you need to specify some indicators, some areas, or both"
		exit 198
	}
	
	// ---------------------------------------------------------------------- //
	// Parse the arguments
	// ---------------------------------------------------------------------- //
	
	// If no area specified, use all of them
	if inlist("`areas'", "_all", "") {
		local areas "all"
	}
	else {
		// Add a comma between areas
		foreach a of local areas {
			if ("`areas_comma'" != "") {
				local areas_comma "`areas_comma',`a'"
			}
			else {
				local areas_comma "`a'"
			}
		}
		local areas `areas_comma'
	}
	
	// ---------------------------------------------------------------------- //
	// Retrieve all possible variables for the area(s)
	// ---------------------------------------------------------------------- //
	
	display as text ""
	display as text "* Get variables associated to your selection...", _continue
	
	tempfile allvars
	clear
	quietly save "`allvars'", emptyok
	
	foreach sixlet in `indicators' {
		clear
		if regexm("`sixlet'", "^[a-z][a-z][a-z][a-z][a-z][a-z]$") {
			clear
			javacall com.wid.WIDDownloader importCountriesAvailableVariables, args("`areas'" "`sixlet'")
		}
		else if ("`sixlet'" == "_all") {
			clear
			javacall com.wid.WIDDownloader importCountriesAvailableVariables, args("`areas'" "all")
		}
		else {
			display as error "`name' is not a valid six letter code"
			exit 198
		}
		quietly append using "`allvars'"
		quietly save "`allvars'", replace
	}
	
	// Check if there are some results
	quietly use "`allvars'"
	quietly count
	if (r(N) == 0) {
		display as text "DONE"
		display as text "(no data matching your selection)"
		exit 0
	}
	
	// ---------------------------------------------------------------------- //
	// Only keep variables that the user asked for
	// ---------------------------------------------------------------------- //
	
	// Create a file with all indicators specified, if any
	clear
	if !inlist("`indicators'", "", "_all") {
		local n: word count `indicators'
		quietly set obs `n'
		quietly generate variable = ""
		forvalues i = 1/`n' {
			local name: word `i' of `indicators'
			if !regexm("`name'", "^[a-z][a-z][a-z][a-z][a-z][a-z]$") {
				display as error "`name' is not a valid six letter code"
				exit 198
			}
			quietly replace variable = "`name'" in `i'
		}
		quietly duplicates drop
		tempfile list_indicators
		quietly save "`list_indicators'"
	}
	
	// Create a list with all the years specified, if any
	clear
	if !inlist("`years'", "", "_all") {
		local n: word count `years'
		quietly set obs `n'
		quietly generate year = .
		forvalue i = 1/`n' {
			local year: word `i' of `years'
			quietly replace year = `year' in `i'
		}
		quietly duplicates drop
		tempfile list_years
		quietly save "`list_years'"
	}
	
	// Create a list with all percentiles specified, if any
	clear
	if !inlist("`perc'", "", "_all") {
		local n: word count `perc'
		quietly set obs `n'
		quietly generate percentile = ""
		forvalues i = 1/`n' {
			local p: word `i' of `perc'
			if !(regexm("`p'", "^p[\.0-9]+$") | regexm("`p'", "^p[\.0-9]+p[\.0-9]+$")) {
				display as error "`p' is not a valid percentile or percentile group"
				exit 198
			}
			quietly replace percentile = "`p'" in `i'
		}
		quietly duplicates drop
		tempfile list_perc
		quietly save "`list_perc'"
	}
	
	// Create a list with all ages specified, if any
	clear
	if !inlist("`ages'", "", "_all") {
		local n: word count `ages'
		quietly set obs `n'
		quietly generate age = ""
		forvalues i = 1/`n' {
			local a: word `i' of `ages'
			if !regexm("`a'", "^[0-9][0-9][0-9]$") {
				display as error "`a' is not a valid age code"
				exit 198
			}
			quietly replace age = "`a'" in `i'
		}
		quietly duplicates drop
		tempfile list_ages
		quietly save "`list_ages'"
	}
	
	// Create a list with all populations specified, if any
	clear
	if !inlist("`population'", "", "_all") {
		local n: word count `population'
		quietly set obs `n'
		quietly generate pop = ""
		forvalues i = 1/`n' {
			local pop: word `i' of `population'
			if !inlist("`pop'", "i", "j", "m", "f", "t", "e") {
				display as error "`pop' is not a valid population code"
				exit 198
			}
			quietly replace pop = "`pop'" in `i'
		}
		quietly duplicates drop
		tempfile list_population
		quietly save "`list_population'"
	}
	
	// From the list of all indicators, only keep the one we are interested in
	quietly use "`allvars'", clear
	if !inlist("`indicators'", "", "_all") {
		quietly merge n:1 variable using "`list_indicators'", nogenerate keep(match)
	}
	if !inlist("`perc'", "", "_all") {
		quietly merge n:1 percentile using "`list_perc'", nogenerate keep(match)
	}
	if !inlist("`ages'", "", "_all") {
		quietly merge n:1 age using "`list_ages'", nogenerate keep(match)
	}
	if !inlist("`population'", "", "_all") {
		quietly merge n:1 pop using "`list_population'", nogenerate keep(match)
	}
	
	// Check that there are some data left
	quietly count
	if (r(N) == 0) {
		display as text "DONE"
		display as text "(no data matching you selection)"
		exit 0
	}
	
	// ---------------------------------------------------------------------- //
	// Display how many variables remain
	// ---------------------------------------------------------------------- //
	
	quietly tab variable
	local nb_variable = r(r)
	if (`nb_variable' > 1) {
		local plural_variable "s"
	}
	quietly tab country
	local nb_country = r(r)
	if (`nb_country' > 1) {
		local plural_country "s"
	}
	quietly tab percentile
	local nb_percentile = r(r)
	if (`nb_percentile' > 1) {
		local plural_percentile "s"
	}
	quietly tab age
	local nb_age = r(r)
	if (`nb_age' > 1) {
		local plural_age "ies"
	}
	else {
		local plural_age "y"
	}
	quietly tab pop
	local nb_pop = r(r)
	if (`nb_pop' > 1) {
		local plural_pop "ies"
	}
	else {
		local plural_pop "y"
	}
	
	display as text "DONE"
	display as text "(found `nb_variable' variable`plural_variable'", _continue
	display as text "for `nb_country' area`plural_country',", _continue
	display as text "`nb_percentile' percentile`plural_percentile',", _continue
	display as text "`nb_age' age categor`plural_age',", _continue
	display as text "`nb_pop' population categor`plural_pop')"
	display as text ""
	
	// ---------------------------------------------------------------------- //
	// Retrieve the data from the API
	// ---------------------------------------------------------------------- //
	
	display as text "* Downloading the data",, _continue
	
	// Generate the variable names to be used in the API
	quietly generate data_code = variable + "_" + percentile + "_" + age + "_" + pop
		
	// Divide the data in smaller chunks before making the request: group by
	// variable and percentiles
	sort variable percentile age pop country
	quietly egen grp = group(variable percentile age pop)
	quietly generate chunk = round(grp/10)
	quietly drop grp
	
	tempfile codes output_data
	quietly save "`codes'"
		
	display ""
	display ""
	display "{c LT} 0% {hline 3}{c +}{hline 3} 20% {hline 3}{c +}{hline 3} 40% {hline 3}{c +}{hline 3} 60% {hline 3}{c +}{hline 3} 80% {hline 3}{c +}{hline 3} 100% {c RT}" in smcl
	
	quietly tabulate chunk
	local nchunks = r(r)
	quietly levelsof chunk, local(chunk_list)
	local progress = 1
	foreach c of local chunk_list {
		quietly use "`codes'"
		quietly levelsof data_code if (chunk == `c'), separate(",") local(variables_list) clean
		quietly levelsof country if (chunk == `c'), separate(",") local(areas_list) clean
		
		clear
		javacall com.wid.WIDDownloader importCountriesVariables, args("`areas_list'" "`variables_list'" "`exclude'")
		quietly drop if missing(value)
		
		if (`c' != 0) {
			quietly append using "`output_data'"
		}
		quietly save "`output_data'", replace
		
		while (`c'/`nchunks'*68 > `progress') {
			di "=",, _continue
			local progress = `progress' + 1
		}
	}
	while (`progress' < 68) {
		di "=",, _continue
		local progress = `progress' + 1
	}
	display ""
	display ""
	
	if ("`list_years'" != "") {
		quietly merge n:1 year using "`list_years'", nogenerate keep(match)
	}
	
	quietly count
	if (r(N) == 0) {
		display as text "(no data matching you selection)"
		exit 0
	}
	
	quietly duplicates drop country variable age pop percentile year, force
	quietly replace variable = variable + age + pop
	order country variable percentile year value
	quietly save "`output_data'", replace
	
	// ---------------------------------------------------------------------- //
	// Retrieve the metadata, if required
	// ---------------------------------------------------------------------- //
	
	if ("`metadata'" != "") {
		display as text "* Download the metadata...", _continue
		
		// Only keep information required for the metadata, and divide them again
		tempfile output_metadata
		quietly use "`codes'", clear
		
		// Only keep one percentile per variable (metadata are the same for all percentiles)
		drop chunk
		quietly duplicates drop variable country age pop, force
		quietly generate chunk = round(_n/50)
		quietly save "`codes'", replace
		
		quietly levelsof chunk, local(chunk_list)
		local first 1
		foreach c of local chunk_list {
			quietly use "`codes'", clear
			quietly levelsof data_code if (chunk == `c'), separate(",") local(variables_list) clean
			quietly levelsof country if (chunk == `c'), separate(",") local(areas_list) clean
			
			clear
			javacall com.wid.WIDDownloader importCountriesVariablesMetadata, args("`areas_list'" "`variables_list'")
			
			// Pass if the dataset is empty (can happen with metadata)
			quietly count
			if (r(N) == 0) {
				continue
			}
		
			drop percentile
			
			if (`first' == 0) {
				quietly append using "`output_metadata'"
			}
			local first 0
			quietly save "`output_metadata'", replace
		}
				
		quietly count
		if (r(N) > 0) {
			display as text "DONE"
		
			quietly replace variable = variable + age + pop
			quietly duplicates drop variable country, force
			
			quietly save "`output_metadata'", replace
			
			// Merge data & metadata
			use "`output_data'", clear
			quietly merge n:1 country variable using "`output_metadata'", nogenerate keep(master match)
		}
		else {
			display as text "DONE (no metadata found for requested data)"
		}
		
		quietly replace imputation = "regional imputation"       if imputation == "region"
		quietly replace imputation = "adjusted surveys"          if imputation == "survey"
		quietly replace imputation = "surveys and tax data"      if imputation == "tax"
		quietly replace imputation = "surveys and tax microdata" if imputation == "full"
		quietly replace imputation = "rescaled fiscal income"    if imputation == "rescaling"

		order country variable percentile year value
	}
	
	// Saves memory
	quietly compress
	
	sort country variable percentile year
end
