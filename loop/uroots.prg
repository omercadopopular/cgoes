
'' 1. Prepare workspace


	cd "Q:\DATA\S1\BRA\Research\Regional Price Indices\IBGE\Eviews\"
	close puroot.wf1
	wfopen(wf=puroot,page=one,typ) "CPI_panel.csv" 
	cd "Q:\DATA\S1\BRA\Research\Regional Price Indices\IBGE\Eviews\short"
	'read(t=csv) "panel_8101.csv" 11

'' 1. Run Panel Unit Root Tests

	pagestruct panelid @datevar(date)
	smpl 2002M1 @last

	%group = "1101 1102 1103 1104 1105 1106 1107 1108 1109 1110 1111 1112 1113 1114 1115 1116 1117 1201 2101 2103 2104 2201 2202 3101 3102 3103 3201 3202 3301 4101 4102 4103 4201 4301 4401 5101 5102 5104 6101 6102 6201 6202 6203 6301 7101 7201 7202 7203 8101 8102 8103 9101"	

	for %a {%group} 
		smpl 2002M1 @last if code = {%a}
		freeze(llc_uroot{%a}) lindex_time.uroot(llc,info=aic,maxlag=10)
		llc_uroot{%a}.save(t=csv) llc_uroot{%a}
	next

stop

	for %a {%group} 
		smpl 2002M1 @last if code = {%a}
		freeze(uroot{%a}) lindex_time.uroot(ips,info=aic,maxlag=10)
		uroot{%a}.save(t=csv) uroot{%a}
	next

'' 1. Run Individual Unit Root Tests

	pageunstack(namepat="*_?",page="unstack") panelid date @ lindex_time
	stop
	smpl 2002M1 @last

	cd "Q:\DATA\S1\BRA\Research\Regional Price Indices\IBGE\Eviews\short\individual"

	%base = "30 686 1998 3108 3764 4420 5530 6186 6842 7498 8154"
	!range = 50
	
	for %x {%base}

		!z = {%x}
		!y = !z + !range + 1

		while !z < !y
			freeze(uroot{!z}) lindex_time_{!z}.uroot(adf,info=aic,maxlag=10)
			uroot{!z}.save(t=csv) n_uroot{!z}
			!z = !z + 1
		wend

	next

	%base2 = "82 738 2050 3160 3816 4472 5582 6238 6894 7550 8206"

	for %a {%base2} 
		freeze(uroot{%a}) lindex_time_{%a}.uroot(adf,info=aic,maxlag=10)
		uroot{%a}.save(t=csv) n_uroot{%a}
	next



stop
