'/// Do-file written by Carlos Goes (andregoes@gmail.com)
'/// for use at Dr Prakash Loungani's Macroeconometrics course
'/// at Johns Hopkins SAIS

'*** This do file aims at
'**** (a) Run unit root tests and Granger-Causality Tests
'**** (b) Run VAR
'**** (c) Run VECM
'**** (d) Compare IRFs from VAR and VECM


'''' Description of variables

	'F10: the yield to maturity of 10-year sovereign local currency yield of zero-coupon bonds;
	'T10:  the yield to maturity of the U.S. Treasury 10-year bond, which conceptually includes the world real interest rate, the US inflation and a term premium;
	'CDS: the spread, in basis points, of the 5-year Credit Default Swap USD contract for the emerging country, which measures investors’ perception of country risk – i.e. the absolute risk of investing in a given country;
	'EMBIG: the difference between the EMBIG stripped spread for emerging country and the EMBIG Global stripped spread, which captures the opportunity costs for investors who usually invest in emerging markets – i.e. the relative risk of the country in comparison to other emerging markets;
	'POLICY: the annualized short term policy rate set by the local central bank for overnight interbank loans, which, combined with other variables, provides measures for term premium inflation differential;
	'VIX: the Chicago Board Options Exchange Market Volatility Index (VIX) for bid-ask quotes of options that have the S&P 500 index as underlying, which is a proxy for global risk aversion;
	'IMVOL: is the one-month implied volatility of the forward exchange rate, which is meant to capture the short-term currency risk;

'' // 1. Prepare the Workspace and Consolidate Daily Data into Weekly Data

	cd "U:\Macroeconometrics\Eviews\VAR and VECM"
	close vecm.wf1
	wfcreate(wf=vecm,page=five) d5 1/1/2000 10/24/2013
	read(t=txt) "mexico.txt" 18
	delete date f3 f5 fedeffect embig mexembig mxn1m mxn1yr mxn3m mxnspot move
	%list = "t10 vix cds spread policy f10 imvol"


	'// 1.1. Loop to consolidate daily data into weekly

		pagecreate(page=weekly) w  1/1/2000 10/24/2013
		pageselect five

		for %a {%list}
			copy(c=a) five\{%a} weekly\{%a} 
			pageselect five
		next

		pageselect weekly

	'// 2.1 Select sample and add scalar

		%t0 = "7/27/2010"
		%T = "10/24/2013"
		smpl %t0 %T

		!T1 = 26 ' (number of periods in our VAR IRFs)

'' // 2. Perform Unit Root Tests and Granger Causality Tests

	' // 2.1 Unit Root Tests - Augmented DF (ADF)

		for %a {%list}
			freeze(uroot_{%a}) {%a}.uroot(adf,t,const,lag=26,info=aic)
		next

	' // 2.2 Granger Causality Tests

		group all {%list}
		freeze(granger) all.cause(26)

'' // 3. Run VAR

	var var1
	var1.ls 1 5  {%list}
	smpl %t0 %T

	freeze(impulsef10var) var1.impulse(!T1, mg) f10 @ t10 policy cds f10@ {%list}

	freeze(cointegration) var1.coint(c,5)

'' // 4. Run VECM

	var vecm1
	vecm1.append(coint) b(1,6) = 1
	vecm1.append(coint) b(1,2) = 0 
	vecm1.append(coint) b(1,7) = 0 

	vecm1.ec(restrict,1) 1 5 {%list}

	freeze(impulsef10) vecm1.impulse(!T1, mg)  f10 @ t10 policy cds f10 @ {%list}
	freeze(decompf10)  vecm1.decomp(!T1,mg) f10

	show impulsef10
	show impulsef10var
