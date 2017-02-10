'/// Do-file written by Carlos Goes (andregoes@gmail.com)
'/// for use at Dr Prakash Loungani's Macroeconometrics course
'/// at Johns Hopkins SAIS

'*** This do file aims at
'**** (a) introducing basic Eviews command lines
'**** (b) introducing Eviews workspace
'**** (b) running regressions
'**** (c) collecting fitted values and residuals
'**** (d) presenting log, lag, and difference operators

'''' Description of variables

	'F10: the yield to maturity of 10-year sovereign local currency yield of zero-coupon bonds;
	'T10:  the yield to maturity of the U.S. Treasury 10-year bond, which conceptually includes the world real interest rate, the US inflation and a term premium;
	'CDS: the spread, in basis points, of the 5-year Credit Default Swap USD contract for the emerging country, which measures investors’ perception of country risk – i.e. the absolute risk of investing in a given country;
	'EMBIG: the difference between the EMBIG stripped spread for emerging country and the EMBIG Global stripped spread, which captures the opportunity costs for investors who usually invest in emerging markets – i.e. the relative risk of the country in comparison to other emerging markets;
	'POLICY: the annualized short term policy rate set by the local central bank for overnight interbank loans, which, combined with other variables, provides measures for term premium inflation differential;
	'VIX: the Chicago Board Options Exchange Market Volatility Index (VIX) for bid-ask quotes of options that have the S&P 500 index as underlying, which is a proxy for global risk aversion;
	'IMVOL: is the one-month implied volatility of the forward exchange rate, which is meant to capture the short-term currency risk;

'' // 1. Prepare the Workspace

cd "U:\Macroeconometrics\Eviews\Introduction"
close example.wf1
wfcreate(wf=example,page=five) d5 1/1/2000 10/24/2013
read(t=txt) "mexico.txt" 18
delete date f3 f5 fedeffect embig mexembig mxn1m mxn1yr mxn3m mxnspot move

''' To import from Excel, use
''	import "L:\file.xls" range="Worksheet!A1:Z1000"
''	or wfopen(type=excel) filename.xls     

'' // 2. Create new series with log, lag, and difference opperators, create a group of variables and plot graph

	' //' 2.1 Create log differences series

	for %x t10 vix cds policy f10 imvol
		series dl{%x} = dlog({%x})
	next

	' //' 2.2 Create a differenced series using the lag operator, delete it than use the diff operator

	%list = "t10 vix cds spread policy f10 imvol"

	for %x {%list}
		series d{%x} = {%x} - {%x}(-1)
		delete d{%x}
		series d{%x} = d({%x})
	next

	' // 2.3 Create a group of variables and plot graph

	group g1 f10 t10
	g1.line

'' // 3. Run simple regressions, collect fitted values and residuals

equation eq1.ls f10 c t10
'show eq1
eq1.fit f10_fit
eq1.makeresid eq1_res
group fitted1 f10 f10_fit
fitted1.line

equation eq2.ls f10 c t10 cds spread policy
eq2.fit f10_fit2
eq2.makeresid eq2_res
group fitted2 f10 f10_fit2
fitted2.line

show eq1
show eq2

