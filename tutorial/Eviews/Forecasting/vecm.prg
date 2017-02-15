'' Written by Carlos Goes (cgoes@imf.org)

'' Open workfile

close quarterly-4-25.wf1
wfopen U:\Research\Macroeconometrics\Eviews\Forecasting\quarterly-4-25.wf1

'' Define list of variables in proper Cholesky ordering
%list = "Lprov Lipiq Lroilp" 

'' Increase range size and define sample size
pagestruct(end=@last+12)
smpl 1980q1 2012q2

'' Create VECM with whole sample
var nvecm
nvecm.append(coint) b(1,3) = 1
nvecm.ec(restrict,1) 1 1 {%list}

'' Create model for future forecasting
nvecm.makemodel(modelA)
smpl 2012q2 @last


			modelA.scenario(n,a=_z) "Forecast"
			modelA.solveopt(s=b, d=d, m=1000000)
			modelA.solve

smpl 2008q1 @last

'' Group actuals, forecasts, forecast bands
group g1 Lprov_zm Lprov_zh Lprov_zl Lprov 
group g2 Lipiq_zm Lipiq_zh Lipiq_zl Lipiq 
group g3 Lroilp_zm Lroilp_zh Lroilp_zl Lroilp 

'' Plot forecasts
g1.line
g2.line
g3.line

'''' In sample

'' Create VECM with whole sample
smpl 1980q1 2008q4
var mvecm
mvecm.append(coint) b(1,3) = 1
mvecm.ec(restrict,1) 1 1 {%list}

''Create model for insample forecast
nvecm.makemodel(modelb)
	smpl 2008q4 2012q4
	modelb.scenario(n,a=_w) "In Sample"
	modelb.solveopt(s=s, d=d, m=1000000)
	modelb.solve

for %a Lprov Lipiq Lroilp
	series {%a}_wh = {%a}_wm + 1.96 * {%a}_ws
next

for %a Lprov Lipiq Lroilp
	series {%a}_wl = {%a}_wm - 1.96 * {%a}_ws
next

'' Group actuals, forecasts, forecast bands
group g4 Lprov_wm Lprov_wh Lprov_wl Lprov 
group g5 Lipiq_wm Lipiq_wh Lipiq_wl Lipiq 
group g6 Lroilp_wm Lroilp_wh Lroilp_wl Lroilp 

'' Plot graphs
smpl 1999q1 @last
g4.line
g5.line
g6.line
