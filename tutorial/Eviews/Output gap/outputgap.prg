'/// Do-file written by Carlos Goes (andregoes@gmail.com)
'/// for use at Dr Prakash Loungani's Macroeconometrics course
'/// at Johns Hopkins SAIS

'*** This do file aims at
'**** (a) practicing time-series commands in Eviews
'**** (b) calculating potential Output and Output Gap with the Hodrick-Prescott filter

cd "U:\Research\Macroeconometrics\Eviews\Output gap"
close outputgap.wf1
wfcreate(wf=outputgap,page=yearly) y 1980 2011

read "outputgap.txt" 6

'// 1. Prepare the data

'// 1a. Take logs of the output and calculate first differences

series ly = log(y)																				'' takes the log of GDP
series dly = d(ly) * 100																		'' calulates GDP growth
series du = d(u) * 100																		'' takes the first difference of unemployment

'// 2. Use Hodrick-Prescott filter of the log of GDP

ly.hpf(lambda=6.25) lytrend @ lycycle

'// 3. Exponentiate calculated trend to obtain the trend in levels

series ytrend = exp(lytrend)																'' exponentiates to get trend in levels

'// 4. Calculate Output Gap

series ygap = ( y / ytrend - 1) * 100

'// 5. Do the same to calculate the natural rate of unemployment and the employment gap

u.hpf(lambda=6.25) utrend @ ucycle
series ugap = ( u / utrend - 1) * 100

'// 6. Plot charts

' *** 6a. for Potential GDP, GDP growth, and Output Gap

graph potential.line  y ytrend																'' creates a line graph named 'potential'
potential.addtext(t, font(18pt,+b)) "Actual and Potential GDP in Brazil"		'' adds the title
potential.setelem(1) legend("Actual GDP")											'' sets legend for element 1
potential.setelem(2) legend("Potential GDP")										'' sets legend for element 2


group g1 ygap dly																			'' creates a group called 'g1'
graph gap.bar(l) g1 																			'' combines a bar and a line graph
gap.setelem(1) legend("Output Gap, in pct")								
gap.setelem(2) legend("GDP Growth, in pct")							
gap.axis(l) range(-6, 8) zeroline -minor
gap.addtext(t, font(18pt,+b)) "GDP Growth and Output Gap in Brazil"			'' adds the title

show gap potential																			'' plots graphs

' *** 6b. for Okun's law

equation okun.ls du c dly																	'' runs du on dly
okun.fit du_hat																				'' creates fitted values
sort(a) du 																						'' sorts series

group g2 dly du du_hat																		'' creates group
freeze(graph) g2.scat 																		'' creates scatterplot
graph.setelem(2) legend("Actual")
graph.setelem(2) symbol(none) linepattern(solid) 								'' sets trendline
graph.setelem(3) legend("Fitted")
graph.addtext(t, font(18pt,+b)) "Okun's law in Brazil"								'' adds the tile
graph.axis(l) zeroline																		'' adds zero line
graph.axis(x) zeroline																		'' adds zero line

show graph																					'' plots graph
