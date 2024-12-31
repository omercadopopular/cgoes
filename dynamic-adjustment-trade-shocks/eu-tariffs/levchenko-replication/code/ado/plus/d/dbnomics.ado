*! Ver 1.2.0 17may2020 Simone Signore
*! Stata API client for db.nomics.world. Requires libjson and moss
capture program drop dbnomics

/* Main wrapper command */
program dbnomics, rclass
	
	/* Version 14.0 used to be necessary because only http secure calls were possible. 
	Now that http is available, I guess 14.0 is still safer because of unicode. 
	Also version 13 crashes due to a weird pointer issue */
	version 14.0			
	
	/* Changelog
		20mar2018  v1.0.0 Initial release
		08may2018  v1.0.1 Fixed syntax parsing bug
		23may2018  v1.0.2 Updated to API ver 0.18.0
		15oct2018  v1.0.3 Updated to API ver 0.21.5
		19oct2018  v1.1.0 Added news API and smart listing (0.21.6)
		21oct2018  v1.1.1 Improved parsing engine, added search endpoint (ver 0.21.6)
		30oct2018  v1.1.2 Fixed bug in dbnomics news
		17jun2020  v1.2.0 Updated to API ver 0.22.0.1, added insecure request
	*/
	
	/*TODO:
		Add new metadata info to payloads [n] --- decided args are not worthy to include
		Evaluate whether to add new align_period and complete_missing_periods options to account for new API parameters [n] --- decided against that, best to keep the payload as small as possible
		Stata can't copy internet files when the server throws an HTTP  error. There's no way to parse error messages then []
		dbnomics_list causes a strange Stata crash when trying to visualise 25+ results. Capped the option at 25, perhaps the routine should be rewritten entirely []
	*/

	/* Housekeeping: taken from insheetjson */
	/* Check if libjson exists */
	mata: if (findexternal("libjson()")) {} else printf("{err:Error: The required JSON library (libjson) seems to be missing so this command will fail. Read the help file for more information.}\n");

	/* Check libjson version */
	mata: if (libjson::checkVersion((1,0,2))) {} else printf("{err: The JSON library version is not compatible with this command and so will likely fail. Please update libjson.}\n");
	
	/* Check whether moss is installed */
	capture which moss
	if _rc {
		di as smcl `"{err:Error: the package {cmd:moss} is required by {cmd:dbnomics}. Try {stata "ssc install moss":ssc install moss}}"'
		exit 111
	}

	syntax [anything(name=subcall id="subcall list")], [CLEAR INSECURE *]

	/* Setup API endpoint */
	local apipath = cond("`insecure'" != "", "http", "https") + "://api.db.nomics.world/v22"
	
	/* Declare API call hard limit */
	global S_dbnomics_hard_limit = 1000
	
	/* Parse subcall*/
	if inlist(`"`subcall'"',"provider","providers") {
		dbnomics_providers `apipath', `clear' `macval(options)'
	}
	else if `"`subcall'"' == "tree" {
		dbnomics_tree `apipath', `clear' `macval(options)'
	}
	else if strpos("datastructure", `"`subcall'"') & length(`"`subcall'"') >= 4 {
		dbnomics_structure `apipath', `clear' `macval(options)'
	}
	else if `"`subcall'"' == "series" {
		dbnomics_series `apipath', `clear' `macval(options)'
	}
	else if `"`subcall'"' == "import" {
		/* timer on 1 */
		dbnomics_import `apipath', `clear' `macval(options)'
		/* timer off 1
		timer list 1
		timer clear 1 */
	}
	else if `"`subcall'"' == "news" {
		dbnomics_news `apipath', `clear' `macval(options)' `insecure'
	}
	else if (substr(`"`subcall'"',1,4) == "use ") {
		tokenize `macval(subcall)'
		dbnomics_use `2', `clear' path(`apipath') `macval(options)' delim(",")
		/* di as err "Sorry, the {err:{bf:dbnomics use}} API is deprecated. Use {cmd:dbnomics import, seriesids(...)} instead."
		exit 198 */
	}
	else if (substr(`"`subcall'"',1,5) == "find ") {
		tokenize `"`subcall'"'
		dbnomics_query `2', `clear' `macval(options)' path(`apipath') `insecure'
	}	
	else {
		di as err "dbnomics: unknown subcommand "`""`subcall'""'"" 
		exit 198
	}
	
	return add
	return local endpoint "`subcall'"
	
	/* Housekeeping */
	/* Done at the subroutine level */

end

/*Subroutines*/
/*1) Providers table */
program dbnomics_providers
	
	syntax anything(name=path), [CLEAR]
	
	/* Setup call*/
	local apipath = "`path'/providers"
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use the {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}
	
	display as txt "Fetching providers list"
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata
	capture copy "`apipath'" `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		if (_rc == 601) di as err "server returned error. Check `apipath' for possibly more info about the issue."
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}
	
	/* Parse JSON */
	mata: providers = fetchjson("`jdata'", "");
	mata: provobj = fetchjson("`jdata'", "providers");
	mata: provnode = provobj->getNode("docs");
	
	/* Check for error in response */
	mata: parseresperr(providers);
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(providers));
	
	/* Call mata function */
	mata: pushdata(json2table(provnode), jsoncolsArray(provnode, 0)');
	
	/* Reduce space (this can be automated in the future)*/
	qui compress	
	
	/* Housekeeping */
	quietly {
	
		cleanutf8
		destring _all, replace
		remove_destrchar _all
		auto_labels _all
	
		/* Parse dates */
		unab varlist : _all
		local dbdates "converted_at indexed_at created_at"
		local dbdates : list dbdates & varlist
	
		local iter 0

		foreach dbd of local dbdates {
			tempvar dbd`iter'
			gen `dbd`iter'' = clock(`dbd',"YMD#hms#")
			order `dbd`iter'', after(`dbd')
			la var `dbd`iter'' "`: var lab `dbd''"
			drop `dbd'
			clonevar `dbd' = `dbd`iter''
			format %tc `dbd'
			order `dbd', after(`dbd`iter++'')
		}
	
		/* Order dataset */
		local ordlist "code name region"
		local ordlist : list ordlist & varlist
		capture order `ordlist', first
	}	
	
	/* Add metadata as dataset data characteristic */
	char _dta[endpoint] "`apipath'"
	char _dta[_meta] "`nomicsmeta'"

	di as text `"(`=_N' `=plural(_N, "provider")' read)"'
	
	/* Housekeeping */
	capture mata : mata drop providers provobj provnode
	
end

/*2) Dataset trees */
program dbnomics_tree

	syntax anything(name=path), PRovider(string) [KEYS(string) CLEAR LEVel(name)]
	
	/* Setup call*/
	local apipath = "`path'/providers/`provider'"
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}	
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata
	capture copy "`apipath'" `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		if (_rc == 601) di as smcl `"{err:server returned error. Make sure {cmd:`provider'} is a valid DB.nomics provider, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"	
		exit _rc
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}	
	else {
		display as txt "Fetching category tree for `provider'"
	}	

	/* Parse JSON */
	mata: tree = fetchjson("`jdata'", "");
	
	/* Check for error in response */
	mata: parseresperr(tree);
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(tree));	
	
	/* Call mata function */
	tempname lvl
	mata: pushdata(parsetree(tree, treekeys("`keys'")), ("`lvl'", treekeys("`keys'")));
	
	/* Reduce space (this can be automated in the future)*/
	qui compress	
	
	/* Parse level */
	tempvar lvlenc lvlgroup
	quietly {
		gen `lvlenc' = real(`lvl')
		if ("`level'" != "") {
			confirm new variable `level'
			egen `level' = group(`lvlenc')
			lab var `level' "Level"
			order `level'
		}
		else {
			confirm new variable level
			egen level = group(`lvlenc')
			lab var level "Level"
			order level
		}
	}
	
	/* Housekeeping */
	quietly {
		cleanutf8
		auto_labels _all
		capture {
			format `=subinstr("`: format name'","%","%-",1)' name
			replace name = ustrupper(name) if level == 1
			replace name = " "*(level-1) + name
		}
		
	}
	
	/* Add provider metadata */
	mata: metadata = ("website","terms_of_use","region","name");
	mata: providermeta = fetchkeyvals(tree->getNode("provider"), metadata);
	mata: for (kk=1; kk<=cols(metadata); kk++) st_lchar("_dta", metadata[kk], providermeta[kk]);

	/* Add metadata as dataset data characteristic */
	char _dta[provider] "`provider'"
	char _dta[endpoint] "`apipath'"	
	char _dta[_meta] "`nomicsmeta'"
	
	/* Housekeeping */
	capture mata : mata drop tree metadata providermeta kk
	
end

/*3) Datastructure */
program dbnomics_structure
	
	syntax anything(name=path), PRovider(string) Dataset(string) [CLEAR noSTAT]
	
	/* Setup call*/
	local apipath = "`path'/series/`provider'/`dataset'?facets=true&metadata=true&format=json&limit=0&offset=0"
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}		
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata
	capture copy "`apipath'" `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		if (_rc == 601) di as smcl `"{err:server returned error. Make sure {cmd:`provider'} and {cmd:`dataset'} are valid DB.nomics provider and dataset respectively, or check {browse "`path'/series/`provider'/`dataset'":`path'/series/`provider'/`dataset'} for possibly more info about the issue.}"'			/*"'*/
		char _dta[errormsg] "`=_rc'"			
		char _dta[endpoint] "`apipath'"
		exit _rc
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}	

	/* Parse JSON */
	mata: structure = fetchjson("`jdata'", "");
	
	/* Check for error in response */
	mata: parseresperr(structure);
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(structure));

	/* Parse dataset structure */
	/* mata: datainfo = fetchjson("`jdata'", "dataset"); */
	mata: datainfo = structure->getNode("dataset");
	mata: datastruct = datainfo->getNode("dimensions_values_labels");
	/* Check whether null structure */
	mata: st_local("nullstruct", strofreal(datastruct==NULL));
	
	/* Proceed accordingly */
	if ("`nullstruct'" == "0") {
		
		/* Parse UNDATA formatting exception */
		if (`"`provider'"' == "UNDATA") {		
			mata: tablestruct = dict2tablev2(datastruct, dictdim(datastruct)[.,2]);
			mata: pushdata(tablestruct[.,2..4], tokenizer("dimensions_values_labels", "_"));
		}
		else {
			mata: tablestruct = dict2table(datastruct, dictdim(datastruct)[.,2]);
			mata: pushdata(tablestruct[.,1..3], tokenizer("dimensions_values_labels", "_"));
		}

		/* Add additional statistics (default) */
		if ("`stat'" == "") {
			
			/* Select facets node */
			mata: statstruct = structure->getNode("series_dimensions_facets");
			
			/* Series stats matrix */
			local nofacets 0
			mata: tablesstat = dict2tablev2(statstruct, dictdim(statstruct)[.,2]);
			
			/* Capture empty node */
			mata: st_local("nofacets", strofreal(tablesstat == "0"));
			
			if (`nofacets' == 0) {
				
				tempfile statdata
				preserve
				
					drop _all
						
					/* Keep only additional data */
					mata: tablesstat = select(tablesstat, tablesstat[., 2] :!= "label");
					
					/* Keep relevant cols */
					mata: pushdata(tablesstat, tokenizer("tracker_dimensions_values_seriescount", "_"));
					
					qui save `statdata'
				restore
				
				/* Parse UNDATA formatting exception */
				if (`"`provider'"' == "UNDATA") {
					qui replace labels = trim(substr(values, strpos(values,",")+1, .))  
					qui replace values = trim(substr(values, 2, strpos(values,",")))
					qui replace values = substr(values,1,length(values)-1)
					qui replace labels = substr(labels,1,length(labels)-1)
				}
				
				qui merge 1:1 dimensions values using `statdata', nogen norep
				capture drop tracker
			
			}

			/* Mata housekeeping */
			mata : mata drop statstruct tablesstat			
		}
		
		/* Reduce space (this can be automated in the future)*/
		qui compress		

		/* Housekeeping */
		quietly {
			cleanutf8
			/* Use destring carefully */
			unab nodestr: dimensions values
			unab allvars : _all
			local todestr : list allvars - nodestr
			destring `todestr', replace
			remove_destrchar _all
			auto_labels _all
		}
		
		/* Mata housekeeping */
		mata : mata drop tablestruct
	}
	else {
		di as smcl "{err:Warning. Dataset structure not found for {cmd:`dataset'}}"
	}
	
	/* Add provider metadata */
	mata: metadata = ("nb_series","code","name");
	mata: datafeat = fetchkeyvals(datainfo, metadata);
	mata: for (kk=1; kk<=cols(metadata); kk++) st_lchar("_dta", metadata[kk], datafeat[kk]);
	
	/* Finally get datastructure template */
	mata: structinfo = parsestructure(datainfo);
	mata: st_local("dtstructure", structinfo);
	mata: st_lchar("_dta", "dtstructure", structinfo);
	
	local seriesnum : char _dta[nb_series1]
	display as res "`: char _dta[name1]' `: char _dta[name2]'"
	display as txt "`seriesnum' series found. Order of dimensions: (`dtstructure')"
	
	/* Add metadata as dataset data characteristic */
	char _dta[provider] "`provider'"
	char _dta[dataset] "`dataset'"
	char _dta[endpoint] "`apipath'"
	char _dta[_meta] "`nomicsmeta'"
	
	/* Housekeeping */
	capture mata : mata drop structure datainfo datastruct metadata datafeat kk structinfo
	
end

/*4. Series */
program dbnomics_series
	
	syntax anything(name=path), PRovider(string) Dataset(string) [LIMIT(numlist integer max=1 <= ${S_dbnomics_hard_limit}) OFFSET(numlist integer max=1 >= 0) SDMX(string asis) CLEAR *]  

	/* Set limit and offset if not provided  */
	if ("`limit'" == "") local limit = ${S_dbnomics_hard_limit}
	if ("`offset'" == "") local offset = 0

	/* smdx and dimensions mutually exclusive */
	if (`"`sdmx'"' != "" & "`macval(options)'" != "") {
		di as smcl "{err:Options {cmd:sdmx} and {cmd:dimensions} are mutually exclusive.}"
		exit 4
	}
	
	/* Parse filtering options */
	_optdict `macval(options)'
	if (`"`dimdict'"' != "") local thequery "&dimensions=`dimdict'"	
	
	if (`"`sdmx'"' != "") mata: st_local("thequery", urlencode(`"`sdmx'"'))
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}		
	
	/* Capture limit override */
	local override 0
	if (`limit' != ${S_dbnomics_hard_limit}) local override 1
	
	/* Setup call*/
	if (`"`sdmx'"' != "") {
		local apipath = `"`path'/series/`provider'/`dataset'/`macval(thequery)'?facets=true&metadata=true&format=json&limit=`limit'&offset=`offset'&observations=false"'
	}
	else {
		local apipath = `"`path'/series/`provider'/`dataset'?facets=true&metadata=true&format=json&limit=`limit'&offset=`offset'`macval(thequery)'&observations=false"'
	}
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata
	capture copy `"`macval(apipath)'"' `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		/* Determine whether it's a provider/dataset issue or sdmx or else */
		char _dta[errormsg] "`=_rc'"
		local theissue = _rc 
		if (_rc == 601) {
			capture copy `"`path'/series/`provider'/`dataset'?facets=false&metadata=false&format=json&limit=0&offset=0&observations=false"' `jdata', replace
			if (_rc == 0) {
				di as smcl `"{err:server returned error. Make sure `macval(options)'`sdmx' are valid DB.nomics filters, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
			}
			else {
				di as smcl `"{err:server returned error. Make sure {cmd:`provider'} and {cmd:`dataset'} are valid DB.nomics provider and dataset respectively, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
			}
		char _dta[endpoint] "`apipath'"
		exit `theissue'
		}
		else {
			char _dta[endpoint] "`apipath'"
			error `theissue'
			exit `theissue'
		}
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}

	/* Parse JSON */
	mata: structure = fetchjson("`jdata'", "");
	
	/* Check for error in response */
	mata: parseresperr(structure);
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(structure));

	/* Parse dataset structure */
	/* mata: datainfo = fetchjson("`jdata'", "dataset"); */
	mata: datainfo = structure->getNode("dataset");
	
	/* Tot. series num. */
	mata: numseries = fetchkeyvals(datainfo, ("nb_series"));
	mata: st_local("series_count", numseries[1]);
	
	/* Parse series node */
	/* mata: seriesinfo = fetchjson("`jdata'", "series"); */
	mata: seriesinfo = structure->getNode("series");

	/* Found series num */
	mata: fndseries = fetchkeyvals(seriesinfo, ("num_found"));
	mata: st_local("num_found", fndseries[1]);
	
	if (`limit' < min(`series_count',`num_found')) {
		if ((min(`series_count',`num_found') < ${S_dbnomics_hard_limit}) & (`override')) {
			display as smcl "{err:Warning: series set not complete. Consider removing the {cmd:limit} option.}"
		}
		else if (`override' == 0) {
			display as smcl "{err:Warning: series set larger than dbnomics maximum provided items.}" _n "{err:Use the {cmd:offset} option to load series beyond the ${S_dbnomics_hard_limit}th one.}"
		}
	}
		
	/* Parse series list */
	mata: seriesdata = seriesinfo->getNode("docs");
	capture mata: pushdata(json2table(seriesdata), jsoncolsArray(seriesdata, 0)');
	
	if (_rc > 0) {
		if (`limit' > 0) {
			display as smcl "{err:Warning: no series found}"
		}
	}
	else {

		/* Housekeeping */
		quietly {
			cleanutf8
			destring _all, replace
			remove_destrchar _all
			auto_labels _all
		}
		
		/* Reduce space (this can be automated in the future)*/
		qui compress
	}
	
	/* Add provider metadata */
	mata: metadata = ("nb_series","code","name");
	mata: datafeat = fetchkeyvals(datainfo, metadata);
	mata: for (kk=1; kk<=cols(metadata); kk++) st_lchar("_dta", metadata[kk], datafeat[kk]);
	
	/* Finally get datastructure template */
	mata: structinfo = parsestructure(datainfo);
	mata: st_local("dtstructure", structinfo);
	mata: st_lchar("_dta", "dtstructure", structinfo);
	
	/* Display result */
	if ((`"`thequery'"' != "") | (`"`sdmx'"' != "")) local series_parsed "`num_found' of "
	
	display as txt "`series_parsed'`series_count' series selected. Order of dimensions: (`dtstructure')" _c
	if (`limit' == 0) {
		display as smcl "{txt:. }{bf:None retrieved}"
	}
	else if (`limit' < min(`series_count',`num_found')) {
		display as smcl "{txt:. }{bf:Only #`=`offset'+1' to #`=min(`limit'+`offset',`series_parsed'`series_count')' retrieved}"
	}
	else {
		display as txt ""
	}
	
	/* Add metadata as dataset data characteristic */
	char _dta[provider] "`provider'"
	char _dta[dataset] "`dataset'"
	char _dta[endpoint] "`apipath'"
	char _dta[_meta] "`nomicsmeta'"
	
	/* Housekeeping */
	capture mata : mata drop datafeat datainfo fndseries kk metadata numseries seriesdata seriesinfo structinfo structure
	
end

/*5. Import one or more series */
program dbnomics_import

	syntax anything(name=path), PRovider(string) Dataset(string) [LIMIT(numlist integer max=1 <=${S_dbnomics_hard_limit}) OFFSET(numlist integer max=1 >= 0) SDMX(string asis) SERIESids(string asis) CLEAR *]
	
	/* Set limit and offset if not provided  */
	if ("`limit'" == "") local limit = ${S_dbnomics_hard_limit}
	if ("`offset'" == "") local offset = 0
	
	/* smdx and dimensions mutually exclusive */
	if (`"`sdmx'"' != "" & `"`macval(options)'"' != "") {
		di as smcl "{err:Options {cmd:sdmx} and {cmd:dimensions} are mutually exclusive.}"
		exit 198
	}
	/* seriesids and dimensions mutually exclusive */
	if (`"`seriesids'"' != "" & `"`macval(options)'"' != "") {
		di as smcl "{err:Options {cmd:seriesids} and {cmd:dimensions} are mutually exclusive.}"
		exit 198
	}	
	/* seriesids and sdmx mutually exclusive */
	if (`"`seriesids'"' != "" & `"`sdmx'"' != "") {
		di as smcl "{err:Options {cmd:sdmx} and {cmd:seriesids} are mutually exclusive.}"
		exit 198
	}
	
	/* Parse filtering options */
	_optdict `macval(options)'
	if (`"`dimdict'"' != "") local thequery "&dimensions=`dimdict'"	
	
	if (`"`sdmx'"' != "") mata: st_local("thequery", urlencode(`"`sdmx'"'))

	/* Parse list of series (must be comma separated)*/
	if (`"`seriesids'"' != "") {
		local thequery "series_ids="
		gettoken series oseries : seriesids, parse(",")
		while ("`series'" != "") {
			if ("`series'" != ",") local thequery `"`thequery'`provider'/`dataset'/`macval(series)',"'
			gettoken series oseries : oseries, parse(",")
		}
		local thequery = substr(`"`macval(thequery)'"', 1, length(`"`macval(thequery)'"') - 1)
	}
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}
	
	/* Capture limit override */
	local override 0
	if (`limit' != ${S_dbnomics_hard_limit}) local override 1
	
	/* Setup call*/
	if (`"`seriesids'"' != "") {
		/* local apipath = "`path'/series?`thequery'&limit=`limit'&offset=`offset'" */
		local apipath = `"`path'/series?`macval(thequery)'&facets=false&metadata=false&observations=true"'
	}
	else if (`"`sdmx'"' != "") {
		local apipath = `"`path'/series/`provider'/`dataset'/`macval(thequery)'?facets=false&metadata=false&format=json&limit=`limit'&offset=`offset'&observations=true"'
	}
	else {
		local apipath = `"`path'/series/`provider'/`dataset'?facets=false&metadata=false&format=json&limit=`limit'&offset=`offset'`macval(thequery)'&observations=true"'
	}
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata
	capture copy `"`macval(apipath)'"' `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		/* Determine whether it's a provider/dataset issue or sdmx or else */
		char _dta[errormsg] "`=_rc'"
		local theissue = _rc 
		if (_rc == 601) {
			capture copy `"`path'/series/`provider'/`dataset'?facets=false&metadata=false&format=json&limit=0&offset=0&observations=false"' `jdata', replace
			if (_rc == 0) {
				di as smcl `"{err:server returned error. Make sure `macval(options)'`sdmx' are valid DB.nomics filters, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
			}
			else {
				di as smcl `"{err:server returned error. Make sure {cmd:`provider'} and {cmd:`dataset'} are valid DB.nomics provider and dataset respectively, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
			}
			char _dta[endpoint] "`apipath'"
			exit `theissue'
		}
		else {
			char _dta[endpoint] "`apipath'"
			error `theissue'
			exit `theissue'
		}
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"	
		exit _rc
	}
	
	/* Parse JSON */
	mata: structure = fetchjson("`jdata'", "");
	
	/* Check for error in response */
	mata: parseresperr(structure);	
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(structure));	
	
	/* This API does not return dataset info anymore. No need for variables below */
	/* Parse dataset structure. May be empty */
	/* mata: datainfo = fetchjson("`jdata'", "dataset"); */
	/* mata: datainfo = structure->getNode("dataset"); */

	/* Tot. series num. */
	/* mata: numseries = fetchkeyvals(datainfo, ("nb_series"));
	mata: st_local("series_count", numseries[1]); */

	/* Parse series node */
	/* mata: seriesinfo = fetchjson("`jdata'", "series"); */
	mata: seriesinfo = structure->getNode("series");
	mata: numseries = fetchkeyvals(seriesinfo, ("num_found"));
	mata: st_local("series_found", numseries[1]);
	
	if (`series_found' == 0) {
		display as smcl "{err:no series found}"
		local loopsize 0
	}
	else {
		/* Data is the array containing matching series */
		mata: srsdata = seriesinfo->getNode("docs");
		
		if (`limit' < `series_found') {
			if ((`series_found' < ${S_dbnomics_hard_limit}) & (`override')) {
				display as smcl "{err:Warning: series set not complete. Consider removing the {cmd:limit} option.}"
			}
			else if (`override' == 0) {
				display as smcl "{err:Warning: series set larger than dbnomics maximum provided items.}" _n "{err:Use the {cmd:offset} option to load series beyond the ${S_dbnomics_hard_limit}th one.}"
			}
		}
		
		tempfile theseries
		
		nobreak {
			quietly {
				
				
				local appendlist
				local loopsize = min(`limit'+`offset',`series_found') - `offset'
				
				nois di as smcl "{txt}Processing `loopsize' series"
				
				/* Note: this may fail for huge list of series if the c(macrolen) is hit */
				forval jj = 1/`loopsize' {
					
					tempfile dbseries`jj'
					if (`jj' > 1) local appendlist "`appendlist' "`dbseries`jj''""
				
						drop _all
						
						/* Parse series data */
						mata: seriesformat(srsdata, `jj');
						save `dbseries`jj''
					
						/* Progress report */
						nois _dots `jj' 0
					
				}
				
				use `dbseries1', clear
				if (`"`appendlist'"' != "") append using `appendlist', gen(series_num)
				
				qui replace series_num = series_num + `offset'
				
			}
		}
		
		/* Reduce space (this can be automated in the future)*/
		qui compress		

		/* Housekeeping */
		quietly {
			cleanutf8
			destring _all, replace
			remove_destrchar _all
			auto_labels _all
			foreach v of varlist _all {
				capture confirm new variable `=subinstr(itrim(trim(subinstr(strlower("`: var lab `v''"),"_"," ",.)))," ","_",.)'
				if !_rc {				
					rename `v' `=subinstr(itrim(trim(subinstr(strlower("`: var lab `v''"),"_"," ",.)))," ","_",.)'
				}
			}
		}
	}
	
	/* Add provider metadata */
	/* mata: metadata = ("code","name");
	mata: datafeat = fetchkeyvals(datainfo, metadata);
	mata: for (kk=1; kk<=cols(metadata); kk++) st_lchar("_dta", metadata[kk], datafeat[kk]); */
	
	/* Setup reporting of loaded series */
	local series_loaded "`=min(`limit',`series_found')' "
	if ("`series_loaded'" == "`series_found' ") {
		local series_loaded
	}
	else if ((`series_found' > ${S_dbnomics_hard_limit})|(`offset'>0)) {
		local series_loaded "#`=`offset'+1' to #`=min(`limit'+`offset', `series_found')' "
	}
	
	/* Avoid extra jump when nr of series is an exact multiple of 50 */
	if (mod(`loopsize',50) != 0) {
		display as smcl _n "{res}`series_found' series found and `series_loaded'loaded"
	}
	else {
		display as smcl "{res}`series_found' series found and `series_loaded'loaded"
	}	
	
	/* Add metadata as dataset data characteristic */
	char _dta[provider] "`provider'"
	char _dta[dataset] "`dataset'"
	char _dta[endpoint] "`apipath'"
	char _dta[_meta] "`nomicsmeta'"

	/* Housekeeping */
	capture mata : mata drop datafeat kk metadata numseries srsdata seriesinfo structure
	
end


/*6. Use single series */
program dbnomics_use

	syntax anything(name=series), PRovider(string) Dataset(string) PATH(string asis) [CLEAR DELIMiter(passthru)]
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}	
	
	local apipath = `"`path'/series/`provider'/`dataset'/`series'?format=csv&complete_missing_periods=false&align_periods=false"'
	
	/* Save csv locally to reduce server load in case of multiple calls */
	tempfile csvdata
	capture copy `"`macval(apipath)'"' `csvdata', replace	
	if (inrange(_rc,630,696) | _rc == 601) {
		/* Determine whether it's a provider/dataset issue or sdmx or else */
		if (_rc == 601) {
			capture copy `"`path'/series/`provider'/`dataset'?facets=false&metadata=false&format=json&limit=0&offset=0&observations=false"' `jdata', replace
			if (_rc == 0) {
				di as smcl `"{err:server returned error. Make sure `series' is a valid DB.nomics series, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
			}
			else {
				di as smcl `"{err:server returned error. Make sure {cmd:`provider'} and {cmd:`dataset'} are valid DB.nomics provider and dataset respectively, or check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'			/*"'*/
			}
		}
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"		
		exit _rc
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"		
		exit _rc
	}
	
	/* Import series name: that's the header of the value column (2nd column) */
	quietly {
	
		tempfile theseries
		import delimited toss series_name using `csvdata', `delimiter' clear rowrange(1:1) varnames(nonames) encoding(utf-8)
		local series_name = series_name[1]
		gen byte dummy = 1
		save `theseries'
		
		/* Import full dataset */
		import delimited period value using `csvdata', `delimiter' clear encoding(utf-8) rowrange(2)
		gen code = "`series'"
		gen byte dummy = 1
		merge m:1 dummy using `theseries', assert(3) nogen norep	keepusing(series_name)
		drop dummy
	
	}
	
	di as text `"`series_name'"'
	di as text `"(`=_N' `=plural(_N, "observation")' read)"'
	
	/* Housekeeping */
	quietly {
		cleanutf8
		destring _all, replace
		remove_destrchar _all
		auto_labels _all
		foreach v of varlist _all {
			capture confirm new variable `=subinstr(itrim(trim(subinstr(strlower("`: var lab `v''"),"_"," ",.)))," ","_",.)'
			if !_rc {				
				rename `v' `=subinstr(itrim(trim(subinstr(strlower("`: var lab `v''"),"_"," ",.)))," ","_",.)'
			}
		}
	}	
	
	/* Add metadata as dataset data characteristic */
	char _dta[provider] "`provider'"
	char _dta[dataset] "`dataset'"
	char _dta[series] "`series'"
	char _dta[series_name] "`series_name'"
	char _dta[endpoint] "`apipath'"
	
end

/*7. Last updates */
program dbnomics_news
	
	syntax anything(name=path), [CLEAR LIMIT(numlist integer max=1 <=100) INSECURE]
	
	/* Set limit if not provided  */
	if ("`limit'" == "") local limit = 20
	
	/* Setup call*/
	local apipath = "`path'/last-updates"
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use the {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}
	
	display as txt "Downloading recently added datasets..."
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata
	capture copy "`apipath'" `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		if (_rc == 601) di as smcl `"{err:server returned error. Check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"			
		exit _rc
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}
	
	/* Parse JSON */
	mata: thenews = fetchjson("`jdata'", "");
	mata: datanode = thenews->getNode("datasets");
	mata: datadocs = datanode->getNode("docs");
	
	/* Check for error in response */
	mata: parseresperr(thenews);
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(thenews));
	
	/* Call mata function */
	mata: pushdata(json2table(datadocs), jsoncolsArray(datadocs, 0)');
	
	/* Reduce space (this can be automated in the future)*/
	qui compress	
	
	/* Housekeeping */
	quietly {
		cleanutf8
		destring _all, replace
		remove_destrchar _all
		auto_labels _all
	}
	
	quietly {
		/* Parse dates */
		unab varlist : _all
		local dbdates "converted_at indexed_at"
		local dbdates : list dbdates & varlist
	
		local iter 0

		foreach dbd of local dbdates {
			tempvar dbd`iter'
			gen `dbd`iter'' = clock(`dbd',"YMD#hms#")
			order `dbd`iter'', after(`dbd')
			la var `dbd`iter'' "`: var lab `dbd''"
			drop `dbd'
			clonevar `dbd' = `dbd`iter''
			format %tc `dbd'
			order `dbd', after(`dbd`iter++'')
		}
	
		/* Order dataset */
		local ordlist "provider_code name provider_name code nb_series indexed_at"
		local ordlist : list ordlist & varlist
		capture order `ordlist', first
	
	}
	
	/* Display results */
	dbnomics_list `ordlist', target(code) pr(provider_code) subcall(structure) apipath("`path'") show(`limit') `insecure'
	
	/* Add metadata as dataset data characteristic */
	char _dta[endpoint] "`apipath'"
	char _dta[_meta] "`nomicsmeta'"
	
	/* Housekeeping */
	capture mata : mata drop thenews datadocs datanode
	
end

/*8. Search data and series */
program dbnomics_query, rclass
	
	syntax anything(name=query), [CLEAR PATH(string asis) LIMIT(numlist integer max=1 <=100) OFFSET(integer 0) INSECURE]
	
	/* Set limit if not provided  */
	if ("`limit'" == "") local limit = 10
	
	/* Parse clear option*/
	if ("`clear'" == "") {
		if `c(width)' > 0 {
			di as err "no; data in memory would be lost. Use the {cmd:clear} option"
			exit 4
		}
	} 
	else {
		clear
	}	
	
	display as txt "Searching for {bf:`query'} in datasets and series..." _c
	
	/* Save json locally to reduce server load over multiple calls */
	tempfile jdata

	/* Setup call*/
	mata: st_local("queryenc", urlencode(`"`query'"'))
	local apipath `"`path'/search?q=`queryenc'&limit=`limit'&offset=`offset'"'	

	capture copy "`apipath'" `jdata', replace
	if (inrange(_rc,630,696) | _rc == 601) {
		if (_rc == 601) di as smcl `"{err:server returned error. Check {browse "`apipath'":`apipath'} for possibly more info about the issue.}"'
		exit _rc
	}
	else if (_rc > 0) {
		di as smcl "{err:failed to reach the dbnomics servers. Check your internet connection, or try using the {cmd:insecure} option.}"
		char _dta[endpoint] "`apipath'"
		char _dta[errormsg] "`=_rc'"
		exit _rc
	}

	/* Parse JSON */
	mata: qmain = fetchjson("`jdata'", "");

	/* Parse number of results */
	/* mata: qresult = fetchjson("`jdata'", "results"); */
	mata: qresult = qmain->getNode("results");
	mata: numseries = fetchkeyvals(qresult, ("num_found"));
	mata: st_local("results_found", numseries[1]);	
	
	/* Check for error in response */
	mata: parseresperr(qmain);
	
	/* Parse metadata */
	mata: st_local("nomicsmeta", parsemeta(qmain));
	
	/* Call mata function */
	if (`results_found' > 0) {
		
		mata: resnode = qresult->getNode("docs");
		mata: pushdata(json2table(resnode), jsoncolsArray(resnode, 0)');
			
		/* Reduce space (this can be automated in the future)*/
		qui compress	
		
		/* Housekeeping */
		quietly {
			cleanutf8
			destring _all, replace
			remove_destrchar _all
			auto_labels _all
		}	
		
		quietly {
			/* Parse dates */
			unab varlist : _all
			local dbdates "converted_at indexed_at"
			local dbdates : list dbdates & varlist
		
			local iter 0

			foreach dbd of local dbdates {
				tempvar dbd`iter'
				gen `dbd`iter'' = clock(`dbd',"YMD#hms#")
				order `dbd`iter'', after(`dbd')
				la var `dbd`iter'' "`: var lab `dbd''"
				drop `dbd'
				clonevar `dbd' = `dbd`iter''
				format %tc `dbd'
				order `dbd', after(`dbd`iter++'')
			}
		
			/* Order dataset */
			local ordlist "type id provider_code name provider_name code nb_series nb_matching_series indexed_at"
			local ordlist : list ordlist & varlist
			capture order `ordlist', first
			
			/* Control data */
			local ctrlist "_version_ json_data_commit_ref"
			local ctrlist : list ctrlist & varlist
			capture order `ctrlist', last
			
			/* Prepare to display results */
			local displaylist "type provider_name name code nb_series nb_matching_series indexed_at"
			local displaylist : list displaylist & varlist
		}
	
		if (`limit' < `results_found') local extramsg " (first `=min(`limit',25)' shown)"
		display as txt "`results_found' `=plural(`results_found', "result")' found`extramsg'." _n
		
		/* Display results */
		tempvar subcallvar
		/* In the v22 API, server only responds datasets */
		gen `subcallvar' = "structure"
		/* Stata crashes with more than 25 results, set maximum display length to 25 */
		dbnomics_list `displaylist', target(code) pr(provider_code) subcall(`subcallvar') apipath("`path'") shownum(25) varsubcall `insecure'
		
		capture mata : mata drop resnode
		
	}
	else {
		display as err "no results found." _n
	}
	
	/* Propagate rclass */
	return add
	
	/* Add metadata as dataset data characteristic */
	char _dta[endpoint] "`apipath'"
	char _dta[_meta] "`nomicsmeta'"
	
	/* Housekeeping */
	capture mata : mata drop qresult numseries qmain
	
end



/* 99. Utilities */

/* List data with smart linking */
capture program drop dbnomics_list
program dbnomics_list, rclass

	syntax varlist(min=2), Target(varname) SUBCALL(string) APIPATH(string) [SHOWnum(integer 20) PRoviderlist(varname) Datasetlist(varname) VARSUBCALL INSECURE]
	
	/* Allocate screen space */
	local cc = 1
	local colspan0 = 1
	/* unab varlist : _all		TO REMOVE */
	local maxshare = round(1.40 * (`c(linesize)'/ `:list sizeof varlist'), 1)
	foreach var of local varlist {
		local varlen = length("`var'") + 3
		local col`cc' : format `var'
		/* default colspan*/
		local colspan`cc' = max(`varlen', 10) + `colspan`=`cc'-1''
		if (regexm("`col`cc''","%([0-9]+).*[a-z]$")) local colspan`cc' = min(`maxshare', max(`varlen', real(regexs(1)))) + `colspan`=`cc++'-1'' + `=("`var'" == "`target'")'
	}
	
	/* Write headers */
	local tablelen = `colspan`=`cc'-1'' + 3
	local cc = 0
	quietly {
		noi di as smcl "{c TLC}{hline `tablelen'}{c TRC}" _n "{c |}" _c
		foreach var of local varlist {
			noi di as smcl "{col `colspan`cc++''}`:var lab `var''" _c
		}
		noi di as smcl "{col `tablelen'}  {c |}" _n "{c BLC}{hline `tablelen'}{c BRC}" _c
	}
	
	quietly {
		forval ii = 1/`=min(`shownum', `c(N)')' {
			
			local cc = 0
			noi di as smcl _n " " _c
		
			if ("`varsubcall'" != "") {
				local subcall_loop = `subcall'[`ii']
			}
			else {
				local subcall_loop : copy local subcall
			}
		
			foreach var of local varlist {
				
				capture confirm string var `var'
				local istr = (_rc==0)
				
				/* Check if variable is the target var */
				if ("`var'" == "`target'") {
					/* Build command */
					if ("`subcall_loop'" == "structure") {
						local ocomm "dbnomics data, pr(`=`providerlist'[`ii']') d(`=`target'[`ii']') clear `insecure'"
					}
					else if ("`subcall_loop'" == "import") {
						local ocomm "dbnomics import, pr(`=`providerlist'[`ii']') d(`=`datasetlist'[`ii']') series(`=`target'[`ii']') clear `insecure'"
					}
					
					
					if (`istr') {
						local olab = abbrev("`=`var'[`ii']'",`colspan`=`cc'+1'' - `colspan`cc'')
						local osmcl `"{txt:{stata "`ocomm'":`olab'}}"' 
					}
					else {
						local osmcl `"{txt:{stata "`ocomm'":`=`var'[`ii']'}}"'
					}
				}
				else {
					if (`istr') {
						local olab = abbrev("`=`var'[`ii']'",`colspan`=`cc'+1'' - `colspan`cc'')
						local osmcl `"`olab'"'
					}
					else {
						local osmcl `"`=`var'[`ii']'"'
					}					
				}
				
				if inlist("`: format `var''","%tc","%tC","%td") {
					noi di as smcl `"{col `colspan`cc++''}"' `: format `var'' `osmcl' _c
				}
				else {
					noi di as smcl `"{col `colspan`cc++''}`osmcl'"' _c
				}				
				
			
			}	
			
			return local cmd`ii' `"`ocomm'"'
		
		}
		
		noi di as txt _n "({it:Click on a highlighted link to load related data})"
	}
	
end

/* Replace UNICODE characters */
program cleanutf8
	
	args noutf
	tempfile runtoclean
	
	if ("`noutf'" != "1") {	
		quietly {
			preserve
				
				tostring _all, replace force
				
				stack _all, into(strings) clear
				drop _stack
				duplicates drop
				
				moss strings, match("(\\u[0-9a-f][0-9a-f][0-9a-f][0-9a-f])") regex pref(uni)
				keep if inrange(unicount,1,.)
				
				if (`c(N)' == 0) {
					restore
					cleanutf8 1
					exit 0
				}
				
				/* pause */
				
				unab matches: unimatch?*
				
				if (`:list sizeof matches' > 1) {				
					stack `matches', into(unistr) clear
					drop _stack
				}
				else {
					keep `matches'
					rename `matches' unistr
				}
				duplicates drop
				gen unichar = ustrunescape(unistr)
				gen command = `"replace \`1' = subinstr(\`1',""' + unistr + `"",""' + unichar + `"",.)"'
				
				outfile command using `runtoclean', noquote
			
			restore
		}
	}
	
	foreach v of varlist _all {
		capture confirm string variable `v'
		if !_rc {
			if ("`noutf'" != "1") run `runtoclean' `v', nostop
			qui replace `v' = subinstr(`v',"\n","",.)
			qui replace `v' = subinstr(`v',`"\""',`"""',.)
			qui replace `v' = subinstr(`v',"\/","/",.)
			qui replace `v' = "" if `v' == `""""'
		}
	}

end

/* Clean var chars */
program remove_destrchar
	
	syntax varlist
	
	foreach var of local varlist {
		local thechars : char `var'[]
		foreach ch of local thechars {
			if inlist("`ch'","destring","destring_cmd") {
				char `var'[`ch'] ""
			}
		}
	}
	
end

/* Gen var labels */
program auto_labels

	syntax varlist

	foreach var of local varlist {
		local thelab = strupper(substr("`var'",1,1)) + subinstr(substr("`var'",2,.),"_"," ",.)
		lab var `var' "`thelab'"
	}
	
end

/* DEPRECATED: Check SDMX compatibility. As of API v22, all providers seem to accept an SDMX mask, when the data structure allows */
* program _sdmx_check
	
	* args prtocheck
	
	* quietly {
		* /* Try to get up-to-date list from the web */
		* capture nobreak {
			* preserve
				* import delimited settings config using "https://git.nomics.world/dbnomics/dbnomics-api/raw/master/dbnomics_api/application.cfg", delim("=") clear
				* keep if trim(itrim(settings)) == "SERIES_CODE_MASK_COMPATIBLE_PROVIDERS"
				* replace config = subinstr(subinstr(subinstr(subinstr(config,",","",.), "}","",.), "{","",.),`"""',"",.)			/*"'*/
				* local checklist = config[1]
			* restore
		* }
		* if _rc {
			* local checklist "BIS ECB Eurostat FED IMF IMF-WEO INSEE OECD WTO"
		* }
		* local thetest : list prtocheck & checklist	
	* }
	
	* /* Return test results */	
	* c_local sdmx_compatible = (`"`thetest'"' != "")
			
* end

/* Compile dimensions dict based on macval(options) */
capture program drop _optdict
program _optdict

	local cmdorig : copy local 0 
	
	if (`"`cmdorig'"' == "") {
		c_local dimdict `""'
		exit
	}
	
	tokenize `"`0'"', parse(")")
	
	local i 1
	local optlist
	local optsyn
	
	/* Parse options */	
	while (`"`macval(`i')'"' != "") {
		
		local optfull "``=2*`i'-1''"
		gettoken optcmd optval : optfull, parse("(")
		
		/* Here syntax-encode optcmd */
		mata: st_local("optcmd_enc", syntaxencode(`"`optcmd'"'))
		
		if ("`optcmd_enc'" != "") local cmdorig : subinstr local cmdorig `"`optcmd'"' `"`optcmd_enc'"'
		if ("`optcmd_enc'" != "") local optlist "`optlist' `optcmd_enc'"
		if ("`optcmd_enc'" != "") local optsyn "`optsyn' `=strlower("`optcmd_enc'")'(string asis)"
		
		if ("`=strlower("`optcmd_enc'")'" != "`optcmd_enc'") local cmdorig : subinstr local cmdorig `"`optcmd_enc'("' `"`=strlower("`optcmd_enc'")'("'
		
		/* if ("`optval'" != "") local optvals "`optvals' `=substr(`"`optval'"',2,.)'" */
		
		local `i++'
	}
	
	/* Parse options parameters */
	local 0 `", `macval(cmdorig)'"'
	syntax [anything], `optsyn'
	
	local thedict "{"
	
	foreach opt of local optlist {
		
		local theopt `""``=strlower("`opt'")''""'
		
		/* Here syntax-decode optcmd */
		mata: st_local("optcmd", syntaxdecode(`"`opt'"'))
		
		local theoptdict : subinstr local theopt `"" ""' `"",""', all
		local theoptdict2 : subinstr local theoptdict `""""' `"""', all
		
		local thedict "`thedict'"`optcmd'":[`theoptdict2'],"
	
	}
	
	/* Finalise dict */
	local thedict = substr(`"`thedict'"',1,length(`"`thedict'"')-1) + "}"
	
	/* URL encode dict */
	mata: st_local("output", urlencode(`"`thedict'"'))
	
	/* yield dict */
	c_local dimdict `"`output'"'
	
end

/* Begin mata operations */
mata

	/* Procedure to extract series data */
	void seriesformat(pointer (class libjson scalar) scalar data, real scalar cursor) {

		pointer (class libjson scalar) scalar series
		pointer (class libjson scalar) scalar cell
		real scalar itk
		string matrix thedata
		string matrix oinfo
		string matrix oinfo_p
		string matrix odata
		string matrix output
		string matrix ainfo
		string matrix adata
		
		/* Loop through series */
		series = data->getArrayValue(cursor);

		/* Parse nr. of kkeys */
		selector = series->listAttributeNames(0);		
		/* printf("%s isonefine \n", strofreal(cols(selector))); */
		
		/*Initialise output*/
		thedata = J(0,0,"");
		scollector = J(1,0,"");
		
		/* Series data (period-value) */
		/* printf("made it here \n") */
		for (kk=1; kk<=cols(selector); kk++) {
			cell = series->getAttribute(selector[kk]);
			if ((cell->isArray()) && (cell->bracketArrayScalarValues() != "[]")) {
				scollector = (scollector, selector[kk]);
				cellarray = parsearray(cell,0)';
				if (rows(thedata) == 0) {
					thedata = J(rows(cellarray), 0, "");
				}
				thedata = (thedata, cellarray);
			}
		}
				
		/* Parse Other series info */
		oinfo = dict2tablev2(series, 2);
		
		/* Filter out stuff that's already been parsed */
		for (kk=1; kk<=cols(scollector); kk++) {
			oinfo = select(oinfo, oinfo[.,1]:!=scollector[kk]);
		}
		
		/* Ad-hoc parser for list of lists with observation attributes */
		if (series->getAttribute("observations_attributes") != NULL) {
			
			oinfo = select(oinfo, oinfo[.,1]:!="observations_attributes");
			
			/* Get obs attributes data */
			oadata = parseattributeslol(series->getAttribute("observations_attributes"), rows(thedata));
			
			/* Split header from content */
			oainfo = oadata[1,.];
			oadata = oadata[2..rows(oadata),.];
			
		}
		else {
			oainfo = J(1,0,"");
			oadata = J(rows(thedata),0,"");
		}		
		
		/* Transpose oinfo */
		oinfo_p = oinfo';
		
		/* Adjust other info */
		odata = J(rows(thedata), 1, oinfo_p[2,.]);
		
		/*Combine dataset*/
		output = thedata, oadata, odata;

		/* Export data */
		pushdata(output, (scollector, oainfo, oinfo_p[1,.]));

	}
	
	/* NEW: ad-hoc function to parse observation_attributes list-of-lists */
	string matrix parseattributeslol(pointer (class libjson scalar) scalar node, real scalar rowfit) {
	
		pointer (class libjson scalar) scalar sublist
		real scalar alen
		real scalar kk
		string matrix collector
		string matrix oadata
		string matrix oheader
		
		/* Initialise collector given rowfit */
		collector = J(rowfit+1,0,"");
		
		if (node->isArray() == 0) {
			return(J(0,0,""))
		}
		else {
			/* Get list size */
			alen = node->arrayLength();
			
			/* Loop through list of lists */
			for (kk=1; kk<=alen; kk++) {
				
				/* Get sub-list */
				sublist = node->getArrayValue(kk);
				
				/* The format of these sublists is: "HEADER", ["content"] */
				oheader = J(1,1, sublist->getArrayValue(1)->getString("",""))
				
				/* If the content is a string scalar, the payload provides a string, not a list */
				if (sublist->getArrayValue(2)->isArray() == 1) {
					oadata = parsearray(sublist->getArrayValue(2), 0);
				}
				else if (sublist->getArrayValue(2)->isString() == 1) {
					oadata = J(1,rowfit,sublist->getArrayValue(2)->getString("",""));
				}
				else {
					oadata = J(1,rowfit,"");
				}				
				
				/* Piece things together and update collector */
				collector = (collector, (oheader, oadata)')
				
			}
		
			/* Return output */
			return(collector);
		}
	}	

	string scalar parsestructure(pointer (class libjson scalar) scalar node) {
	
		pointer (class libjson scalar) scalar templ
		
		/* Two strategies:*/
		/* 1) List in dimensions_codes_order is available */
		templ = node->getNode("dimensions_codes_order");
		if ((templ!=NULL) && (templ->arrayLength() > 0)) {
			return(parsearray(templ, 1));
		} else {
		/* 2) Get list of attribute names */
			string scalar output
			string rowvector columns
			templ = node->getNode("dimensions_values_labels");
			if (templ!=NULL) {
				columns = templ->listAttributeNames(0);
				output = columns[1];
				for (kk=2; kk<=cols(columns); kk++) output = output + "." + columns[kk]
				return(output);
			} else {
				output = "Not Available"
				return(output);
			}			
		}
	}

	real rowvector dictdim(pointer (class libjson scalar) scalar node) {
		
		string rowvector selector
		string matrix collector
		real scalar NR
		real scalar NC
		
		/* Parse nr. of kkeys */
		selector = node->listAttributeNames(0);
		NR = cols(selector);
		/* Flatten and get longest col */
		collector = node->flattenToKV();
		/* Initialise max */
		NC = 1
		for (kk=1; kk<=rows(collector); kk++) {
			NC = rowmax((NC, cols(tokenizer(collector[kk,1], ":"))));
		}	
		return((NR, NC + 1));	
	}

	string rowvector tokenizer(string scalar toparse, string scalar punct) {
		tok = tokens(toparse,punct);
		NC = ceil(cols(tok)/2);
		res = J(1,NC,"");
		for (kk=1; kk<=NC; kk++) {
			res[kk]=tok[kk*2-1];
		}
		return(res);
	}

	/* Parse dict of dicts. Assumption: at most x nested level */
	string matrix dict2table(pointer (class libjson scalar) scalar node, real scalar depth) {

		string matrix output
		string matrix content
		string matrix yield
		string matrix isempty
		string rowvector selector
		pointer (class libjson scalar) scalar cell
		real scalar kk
		
		/* Capture empty node */
		isempty = node->flattenToKV();
		if (rows(isempty) == 0) {
			return("0");
		}
		if (node==NULL) {
			return("0");
		}
		
		/* Parse nr. of kkeys */
		selector = node->listAttributeNames(0);
			
		/*Initialise output*/
		output = J(0, depth, "");
			
		for (kk=1; kk<=cols(selector); kk++) {
			
			cell = node->getAttribute(selector[kk]);
			
			if (cell==NULL) {
				return(0);
				exit();
			} else if (cell->isObject()) {
				if (depth <= 2) {
					content = cell->flattenToKV();
				} else {
					content = dict2table(cell, depth - 1);
				}
				if (cols(content) < cols(output)) {
					yield = (J(rows(content), 1, selector[kk]), content, J(rows(content), cols(output) - cols(content) - 1, ""));
				} else {
					yield = content;
				}
				output = output \ yield;
			} else if (cell->isString()) {
				output = output \ (selector[kk], cell->getString("",""), J(1, cols(output) - 2, ""));
			} else if (cell->isArray()) {
				if (cell->bracketArrayScalarValues() == "[]") {
					content = json2table(cell)
					if (cols(content) < cols(output)) {
						yield = (strofreal(range(1, rows(content), 1)), content, J(rows(content), cols(output) - (cols(content) + 1), ""));
					} else {
						yield = content;
					}
					output = output \ yield;
				} else {
					output = output \ (selector[kk], cell->bracketArrayScalarValues(), J(1, cols(output) - 2, ""));
				}
			} 
			
			/* Skip cell if none of the above */
			/* else {				return(0);				exit();			} */
		}
		return(output);
	}

	/* Parse dict of dicts with complex structure. Assumption: at most x nested level */
	string matrix dict2tablev2(pointer (class libjson scalar) scalar node, real scalar depth) {

		string matrix output
		string matrix content
		string matrix yield
		string matrix isempty
		string rowvector selector
		pointer (class libjson scalar) scalar cell
		real scalar kk
		
		/* Capture empty node */
		isempty = node->flattenToKV();
		if (rows(isempty) == 0) {
			return("0");
		}
		if (node==NULL) {
			return("0");
		}
		
		/* Parse nr. of kkeys */
		selector = node->listAttributeNames(0);
			
		/*Initialise output*/
		output = J(0, depth, "");
			
		for (kk=1; kk<=cols(selector); kk++) {
			
			cell = node->getAttribute(selector[kk]);
			
			if (cell==NULL) {
				return(0);
				exit();
			} else if (cell->isObject()) {
				if (depth <= 2) {
					content = cell->flattenToKV();
				} else {
					content = dict2table(cell, depth - 1);
				}
				if (cols(content) < cols(output)) {
					yield = (J(rows(content), 1, selector[kk]), content, J(rows(content), cols(output) - cols(content) - 1, ""));
				} else {
					yield = content;
				}
				output = output \ yield;
			} else if (cell->isString()) {
				output = output \ (selector[kk], cell->getString("",""), J(1, cols(output) - 2, ""));
			} else if (cell->isArray()) {
				if (cell->bracketArrayScalarValues() == "[]") {
					content = json2table(cell)
					content = (J(rows(content),1,selector[kk]), content)
					if (cols(content) < cols(output)) {
						yield = (strofreal(range(1, rows(content), 1)), content, J(rows(content), cols(output) - (cols(content) + 1), ""));
					} else {
						yield = content;
					}
					output = output \ yield;
				} else {
					output = output \ (selector[kk], cell->bracketArrayScalarValues(), J(1, cols(output) - 2, ""));
				}
			} 
			
			/* Skip cell if none of the above */
			/* else {				return(0);				exit();			} */
		}
		return(output);
	}

	string matrix parsetree(pointer (class libjson scalar) scalar node, string rowvector dictkeys) {
		
		pointer (class libjson scalar) scalar provnode
		string matrix thetree
		
		/*Extract relevant node*/
		provnode = node->getNode("category_tree");
		
		/* Build tree table */
		thetree = getrecursive(provnode, dictkeys, 0);
		
		/*Output*/
		return(thetree);
	
	}
	
	string rowvector treekeys(string scalar keylist) {

		string rowvector tok
		real scalar NC
		string scalar dictkeys

		if (keylist != "") {
			tok = tokens(keylist,",");
			NC = ceil(cols(tok)/2);
			if (NC > 0) {
				dictkeys=J(1,NC,"");
				for (kk=1; kk<=NC; kk++) dictkeys[kk]=tok[kk*2-1];
			}
			else {
				printf("{err: Invalid key list}\n", selector);
				exit(error(198));
			}
		}
		else {
			dictkeys = ("code","name","doc_href");
		}		
		return(dictkeys);	
	}

	string matrix fetchjson(string scalar url, string scalar path) {
	
		class libjson scalar w
		pointer (class libjson scalar) scalar node
		
		/* Import JSON data*/
		jstr = w.getrawcontents(url ,J(0,0,""));
		
		/* Fill any empty JSON object that would screw up the libjson parse command */
		jstr = subinstr(jstr, `":{},"',`":{"null":true},"');
		/*jstr = subinstr(jstr, `""dimensions":{},"',"");	*/
		
		/*Parse contents*/
		node = w.parse(jstr);
		
		/* Parse path option */
		if (path != "") {
			pointer (class libjson scalar) scalar pnode
			pnode = node->getNode(path);
			if (pnode != NULL) {
				return(pnode);
			}
		}		
		return(node);	
	}

	void parseresperr(pointer (class libjson scalar) scalar node) {
		
		pointer (class libjson scalar) scalar provnode
		
		/* Extract important node */
		provnode = node->getNode("message");
		
		/* Extract error message */
		if (provnode==NULL) {
			/*No error key found*/
			exit(0);
		} else {
			/* Display error description and exit 601 */
			if (provnode->isString()) output = provnode->getString("","");
			printf("{err: %s}\n", output);
			exit(601);
		}
	}

	string scalar parsemeta(pointer (class libjson scalar) scalar node) {

		pointer (class libjson scalar) scalar provnode
		pointer (class libjson scalar) scalar metanode
		string rowvector provnode_attr
		string scalar output

		/* Extract important node */
		provnode = node->getNode("_meta");	
		
		/* Extract error message */
		/* Initialise output str */
		output = ""
		
		if (provnode==NULL) {
			/*No meta data found*/
			return(output);
		} else {
			/* Get attributes*/
			provnode_attr = provnode->listAttributeNames(0);
			
			/* Loop through attributes and fill output */
			pointer (class libjson scalar) scalar cell
			
			for (k=1; k<=cols(provnode_attr); k++) {
				/* Get attr name */
				kk = provnode_attr[k];
				/* Get attr content */
				cell = provnode->getAttribute(kk);
				
				if (cell->isString()) {
					if (output == "")	 {
						output = kk + ": " + cell->getString("","");
					} else {
					output = output + ". " + kk + ": " + cell->getString("","");
					}
				}
			}
			return(output);		
		}
	}	
	
	void pushdata(string matrix ptable, string rowvector pheaders) {
		
		string rowvector pheadersp
		
		/* Ensure headers are proper stata var names*/
		pheadersp = J(rows(pheaders),cols(pheaders),"")
		
		for (r=1; r<=cols(pheaders); r++) {
			if (strlen(pheaders[1,r])>32) {
				pheadersp[1,r] = strtoname(substr(pheaders[1,r],1,16)+substr(pheaders[1,r],-16,.));
			}
			else {
				pheadersp[1,r] = strtoname(pheaders[1,r]);
			}
		}		
		
		/*Add info to dataset*/
		st_addobs(rows(ptable));
		st_sstore(.,st_addvar("str2045", pheadersp), ptable);	

	}
	
	string matrix json2table(pointer (class libjson scalar) scalar provnode) {
		
		/* Define json elements as libjson pointers */
		pointer (class libjson scalar) scalar arrayval
		pointer (class libjson scalar) scalar cell
		pointer (string rowvector) scalar selectors
		
		real scalar NC
		real scalar NR
		string matrix res
		
		/* Get dimensions */
		NC = strtoreal(jsoncolsArray(provnode, 1));
		if (provnode->isArray()) {
			NR = provnode->arrayLength();		
		}
		else if (provnode->isObject()) {
			string rowvector cols
			cols = provnode->listAttributeNames(0);
			NR = rows(cols');
		}		

		/* provnode is always an Array */
		selectors = getcolsArray(provnode);

		/* Initialise output */
		res = J(NR, NC, "");	
		
		/* Shamelessly adapted from insheetjson */
		/* Loop through rows and parse columns */			
		for (r=1; r<=NR; r++) {
			
			/* Get rth item from tableroot */
			arrayval = provnode->getArrayValue(r);
			
			/* Loop through columns of rth row and parse cells */
			for(c=1; c<=NC; c++) {
				
				/* The following is repeated from above */
				/* Get cell content from rownod */
				cell = arrayval->getNode(*selectors[c]);
				
				/* Cell is not empty: */
				if (cell) {
					/*Case 1: cell contains string. Getstring behaves like the dict.get() command in python */
					if (cell->isString()) res[r,c] = cell->getString("","");
					/* Case 2: cell contains array. Return list containing array values */
					else if (cell->isArray()) res[r,c] = cell->bracketArrayScalarValues();
					/* Case 3: cell is object. Return flattened json */
					else if (cell->isObject()) {
						if (substr(strtrim(cell->toString()), 1, 1) == "{") res[r,c] = substr(strtrim(cell->toString()),2,.)
						else res[r,c] = strtrim(cell->toString())
					}
				}
				
				/* If cell is not found leave res with blank */
					
			}
		}	
		return(res);
	}
	
	string matrix getrecursive(pointer (class libjson scalar) scalar node, string rowvector dictkeys, real scalar level) {

		/* Loop through submitted key vector and fill output */
		pointer (class libjson scalar) scalar cell
		string matrix output
		real scalar NR
		
		/*Initialise output*/
		output = J(0,cols(dictkeys)+1,"");
		
		/*Case 0: node must be Array*/
		if ( node->isObject() ) {
			/* Capture node object */
			output = output \ (strofreal(level), fetchkeyvals(node, dictkeys));
			/*Try navigating to children object */
			cell = node->getNode("children");
			/* Build exception*/
			if (cell==NULL) {
				/*Reached the end of the tree*/
				return(output);
			}
			else {
				output = output \ getrecursive(cell, dictkeys, level + 1);
				return(output);
			}
		}
		else if ( node->isArray() ) {
			/* Get array length*/
			NR = node->arrayLength();
			/*Exit if array length is zero*/
			if (NR < 1) return(output);
			for (r=1; r<=NR; r++) {
				cell = node->getArrayValue(r);
				output = output \ getrecursive(cell, dictkeys, level + 1);
			}
			return(output);
		}
		else {
			return(output);
		}
	}	

	pointer (string rowvector) getcolsArray(pointer (class libjson scalar) scalar node) {
		
		real scalar NR
		string rowvector collector
		string colvector uniquecols
		pointer (string rowvector) scalar colsel 
		
		pointer (class libjson scalar) scalar arrayval
			
		NR = node->arrayLength();
		collector = J(1,0,"");
		
		for (r=1; r<=NR; r++) {
			
			/* Get inner array val*/
			arrayval = node->getArrayValue(r);
			
			/* Update collector with node attributes */
			collector = collector, arrayval->listAttributeNames(0);
		
		}
		
		/*Use uniqrows to list all atributes*/
		uniquecols = uniqrows(collector')';
		
		colsel=J(1,cols(uniquecols),NULL)
		for (k=1; k<=cols(uniquecols); k++) colsel[k] = & (uniquecols[k]);
		
		return(colsel);
	}
	
	string rowvector parsearray(pointer (class libjson scalar) scalar node, real scalar nflag) {
		
		pointer (class libjson scalar) scalar cell
		string rowvector collector
		real scalar NR
		
		NR = node->arrayLength();
		collector = J(1,NR,"");
		
		for (r=1; r<=NR; r++) {
			
			/* Get inner array val*/
			cell = node->getArrayValue(r);
			
			if (cell->isString()) {
				
				if (nflag==. || nflag==0) {
					/* Update collector with node attributes */
					collector[r] = cell->getString("","");
				}
				else {
					if (collector[1] == "") {
						collector[1] = cell->getString("","");
					} else {
						collector[1] = collector[1] + "." + cell->getString("","");
					}
				}
			} else {
				return(0);
			}
		}
		if (nflag==. || nflag==0) {
			return(collector);		
		} else {
			return(collector[1]);
		}
	}

	/* Returns either columns of JSON node or nr. of rows. Accepts an Array of dicts */
	string matrix jsoncolsArray(pointer (class libjson scalar) scalar node, real scalar nflag) {
		
		real scalar NR
		string rowvector collector
		string colvector uniquecols
		
		pointer (class libjson scalar) scalar arrayval
			
		NR = node->arrayLength();
		collector = J(1,0,"");
		
		for (r=1; r<=NR; r++) {
			
			/* Get inner array val*/
			arrayval = node->getArrayValue(r);
			
			/* Update collector with node attributes */
			collector = collector, arrayval->listAttributeNames(0);
		
		}
		
		/*Use uniqrows to list all atributes*/
		uniquecols = uniqrows(collector');
		
		if (nflag==. || nflag==0) {
			return(uniquecols)
		}
		else {	
			return(strofreal(rows(uniquecols)));
		}
	}
	
	string matrix fetchkeyvals(pointer (class libjson scalar) scalar node, string rowvector dictkeys) {

		/* Loop through submitted key vector and fill output */
		pointer (class libjson scalar) scalar cell
		string rowvector output
		
		/* Initialise output */
		output = J(1, cols(dictkeys), "");
		
		if (node==NULL) {
			/*No error key found*/
			return(output);
		}
		else {
			for (k=1; k<=cols(dictkeys); k++) {
				/* Get attr content */
				cell = node->getAttribute(dictkeys[k]);		
				
				if (cell==NULL) {
					return(output);
				} else if (cell->isString()) {
					output[k] = cell->getString("","");
				} else {
					output[k] = "";
				}
			}
			return(output);
		}
	}	

	/* URL encode, taken from libjson_source */
	string scalar urlencode(string scalar s) { 
		
		res = J(1,0,.); 
		a=ascii(s); 
		
		for(c=1;c<=cols(a); c++) { 
			if ((a[c]>=44 && a[c]<=59) || (a[c]>=64 && a[c]<=122)) {
				res=(res,a[c]);
			} else { 
				h1 = floor(a[c]/16); 
				h2 = mod(a[c],16); 
				if (h1<10) {
					h1=h1+48;
				} else {
					h1=h1+55;
				}  
				if (h2<10) {
					h2=h2+48;
				} else {
					h2=h2+55;
				} 
				res=(res, 37, h1,h2);
			} 
		} 
		
		return(char(res));
	}
	
	/* Convert to syntax-approved string */
	string scalar syntaxencode(string scalar input) {

		real rowvector ascinput
		string scalar output

		ascinput = ascii(input);
		output = "";
		for (kk=1; kk<=cols(ascinput); kk++) {
			if ((ascinput[kk] >= 1 && ascinput[kk] <=45) || (ascinput[kk] >= 58 && ascinput[kk] <=64) || (ascinput[kk] >= 91 && ascinput[kk] <=94) || (ascinput[kk] >= 123 && ascinput[kk] <=126) || (ascinput[kk] == 47 || ascinput[kk] == 96)) {
				output = output + "_" + strofreal(ascinput[kk]) + "_";
			} else {
				output = output + char(ascinput[kk]);
			}		
		}
		
		return(output);
	}
	
	/* Decode from syntax-approved string */
	string scalar syntaxdecode(string scalar input) {

		string scalar output
		
		output = input;
		for (kk=1; kk<=128; kk++) {
			output = subinstr(output, "_" + strofreal(kk) + "_", char(kk));
		}
		
		return(output);
	}	
	
	
end

exit

