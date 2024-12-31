
program define stackedcount
* May work on earlier versions, but only tested on 15 and later versions
version 15.0
*display "Entering: stackedcount"
quietly {
*set trace on
syntax varlist (min=2 max=2 numeric) [if] [in],[xlabel(string)] [xtick(string)] [xmtick(string)] [xtitle(string)] [xrange(numlist)] [ylabel(string)] [ytick(string)] [ymtick(string)] [ytitle(string)] [yscale(string)] [caption(string)] [scheme(string)] [note(string)] [legend(string)]

/* START HELP FILE

title[produce a stacked area graph]

desc[
{cmd:stackedcount} will produce a stacked area graph for the frequencies (y-axis) of the categories in a labeled numeric categorical
variable as a function of a continuous numeric variable (x-axis).

Varlist is 

y x

y is a categorical numeric variable. There must be at least two distinct values. If y takes on only one value, you should just use twoway area.

Categories will be stacked in order of the original numeric values of y, from bottom to top in order of ascending values of y. 

The values of y must be labelled. If any values are unlabelled, the program will exit with error code 182.

If the categorical variable you want to plot is string, run encode beforehand to create a labeled numeric categorical variable

x is a continuous numeric variable (for example, year)

]

opt[xlabel see {help axis_label_options}]
opt[xtick see {help axis_label_options}]
opt[xmtick same as in twoway]
opt[xtitle same as in twoway] 
opt[xrange(numlist) same as in twoway]
opt[ylabel(string) same as in twoway] 
opt[ytick(string) same as in twoway] 
opt[ymtick(string) same as in twoway] 
opt[ytitle(string) same as in twoway] 
opt[yscale(string) same as in twoway] 
opt[caption(string) same as in twoway]
opt[scheme(string) same as in twoway]
opt[note(string) same as in twoway]
opt[legend(string) same as in twoway]

example[
stacked_percent guanzhi_js gap if gap >= 0.5 & gap <= 20 & (甲第 == 1 | 甲第 == 2) & !qiren, 
legend(size(small) cols(4)) xtitle("Years since exam") ytitle("Percent") 
caption("Positions held by jinshi since years since exam 甲第 1 2 - non-Banner") 
note("$note_time_stamp")
]

author[Cameron Campbell]
institute[HKUST]
email[camcam@ust.hk]
]

END HELP FILE */

tokenize `varlist'
tempvar t_count
*set trace on
*set tracedepth 0
preserve
if "`if'" != "" {
	keep `if'
}
if "`in'" != "" {
	keep `in'
}

* The values of numeric 'y' variable that specifies categories must be labeled

local labels : value label `1'
levelsof `1', local(value_list)

foreach i of local value_list {
      	 local value`i' : label `labels' `i' 
		 if "`value`i''" == "" {
				display "Error: Value `i' of variable `1' not labelled."
				exit 182
		 }
*		 display "`value`i''"
}

quietly: table `2' `1', replace
*bysort `2': egen `percent' = pc(table1)
bysort `2' (`1'): generate `t_count' = sum(table1)
keep `2' `1' `t_count'
reshape wide `t_count', i(`2') j(`1')
foreach i of local value_list {
	display "`t_percent'`i'" "`value`i''"
	label variable `t_count'`i' "`value`i''"
}
local i = 1
foreach l of varlist `t_count'* {
	if `i' == 1 {
		local line_command "area `l' `2', cmissing(n)"
		local legend_order "`i'"
		} 
	else {
		local line_command "area `l' `2', cmissing(n) || `line_command'"
		local legend_order "`i' `legend_order'"
		}
	local i = `i'+1
}

if "`xlabel'" != "" {
	local xlabel "xlabel(`xlabel')"
}

if "`ylabel'" != "" {
	local ylabel "ylabel(`ylabel')"
}

if "`yscale'" != "" {
	local yscale "yscale(`yscale')"
}

if "`xtitle'" != "" {
	local xtitle "xtitle(`xtitle')"
}

if "`scheme'" != "" {
	local scheme "scheme(`scheme')"
}

if "`note'" != "" {
	local note "note(`note')"
}

if "`ytitle'" != "" {
	local ytitle "ytitle(`ytitle')"
}

if "`ytick'" != "" {
	local ytick "ytick(`ytick')"
}

if "`xtick'" != "" {
	local xtick "xtick(`xtick')"
}

if "`xmtick'" != "" {
	local xmtick "xmtick(`xmtick')"
}

if "`ymtick'" != "" {
	local ymtick "ymtick(`ymtick')"
}

if "`caption'" != "" {
	local caption "caption(`caption')"
}

tempvar range_match
generate `range_match' = 0
if ("`xrange'" != "") {
	foreach i of numlist `xrange' {
		replace `range_match' = `2' == `i'
		sort `range_match'
		if !`range_match'[_N] {
			insobs 1
			replace `2' = `i' in l
		}
	}
}

tempfile beginning
tempvar new_order

generate `new_order' = 2

save "`beginning'"

sort `2'
replace `2' = `2'[_n+1] if _n < _N
replace `2' = `2'[_N-1]+(`2'[_N-1]-`2'[_N-2]) if _n == _N

list `2'
replace `new_order' = 1

append using "`beginning'"

sort `2' `new_order'

*list `2' `new_order' 

#delimit ;
twoway `line_command' `xlabel' `ylabel' legend(order(`legend_order') `legend') 
	`yscale' `xtitle' `scheme' `note' `ytitle' `caption' `xtick' `ytick' 
	`xmtick' `ymtick' sort(`2' `new_order')
	graphregion(fcolor(white));
#delimit cr

}
*display "Exiting: stacked_count"
restore
*set trace off
end
