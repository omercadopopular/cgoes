capture program drop rforest_examples
capture program drop exampleRegression
capture program drop exampleClassification
program define rforest_examples
	if ("`1'" == "class"){
		exampleClassification
	}
	else if ("`1'" == "reg"){
		exampleRegression
	}
	else if ("`1'" == "varimport"){
		exampleVarImport
	}

end


program define exampleRegression
	di "{cmd:. clear}"
	clear
	di "{cmd:. sysuse auto}"
	sysuse auto
	di "{cmd:. set seed 1}"
	set seed 1
	di "{cmd:. gen u = uniform()}"
	gen u = uniform()
	di "{cmd:. sort u}"
	sort u
	di "{cmd:. rforest price weight length, type(reg) iter(500)}"
	rforest price weight length, type(reg) iter(500)
	di "{cmd:. ereturn list}"
	ereturn list
	di "{cmd:. predict p1}"
	predict p1
	di "{cmd:. list p1 price in 1/5}"
	list p1 price in 1/5
	di "{cmd:. ereturn list}"
	ereturn list
	
end

program define exampleVarImport
	di "{cmd:. clear}"
	clear
	di "{cmd:. sysuse auto}"
	sysuse auto
	di "{cmd:. set seed 1}"
	set seed 1
	di "{cmd:. gen u = uniform()}"
	gen u = uniform()
	di "{cmd:. sort u}"
	sort u
	di "{cmd:. rforest weight foreign trunk length mpg price, type(reg)}"
	rforest weight foreign trunk length mpg price, type(reg)
	
	di "{cmd:. predict pred}"
	predict pred
	
	di "{cmd:. list trunk pred foreign weight in 1/5}"
	list trunk pred foreign weight in 1/5
	
	di "{cmd:. matrix importance=e(importance)}"
	matrix importance=e(importance)
	di "{cmd:. svmat importance}"
	svmat importance 
	di "{cmd:. list importance in 1/5}"
	list importance in 1/5
	

	// replace id with labels from matrix
	di "{cmd:. gen id = }" `"""
	gen id=""
	di "{cmd:. local mynames : rownames importance}"
	local mynames : rownames importance
	di "{cmd:. local k : word count 'mynames' }"
	local k : word count `mynames'
	
	// if more variables than observations
	di "{cmd:. if 'k' >_N set obs 'k' }"
	if `k'>_N set obs `k'
	di "{cmd:. forvalues i = 1(1)'k'}"" {"
	di _col(5) "{cmd: local aword : word 'i' of 'mynames'}"
	di _col(5) "{cmd: local alabel : variable label 'aword'}"
	di _col(5) "{cmd: if}" `" "{cmd:'alabel'" != "" qui replace id = }"{cmd:'alabel'" in 'i'}
	di _col(5) "{cmd: else qui replace id =}" `" "{cmd:'aword'" in 'i'}"
	di "  }"
	forvalues i = 1(1)`k' {
		local aword : word `i' of `mynames'
		local alabel : variable label `aword'
		if "`alabel'"!="" qui replace id= "`alabel'" in `i'
		else qui replace id= "`aword'" in `i'
	}
	di "{cmd:. graph hbar (mean) importance, over(id, sort(1)) ytitle(Importance)}"
	graph hbar (mean) importance, over(id, sort(1)) ytitle(Importance)
end

program define exampleClassification
	di "{cmd:. clear}"
	clear
	di "{cmd:. sysuse auto}"
	sysuse auto
	di "{cmd:. set seed 1}"
	set seed 1
	di "{cmd:. gen u = uniform()}"
	gen u = uniform()
	di "{cmd:. sort u}"
	sort u
	di "{cmd:. rforest foreign weight length, type(class) iter(500)}"
	rforest foreign weight length, type(class) iter(500)
	di "{cmd:. ereturn list}"
	ereturn list
	di "{cmd:. predict p1}"
	predict p1
	di "{cmd:. predict c1 c2, pr}"
	predict c1 c2, pr
	di "{cmd:. list p1 foreign c1 c2 in 1/5}"
	list p1 foreign c1 c2 in 1/5
	di "{cmd:. ereturn list}"
	ereturn list
end
