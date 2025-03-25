#d;
clear;
********************************************************************************
*     PROGRAM NAME:   STATA SAMPLE CODE FOR COMPUTING A SINGLE CALENDAR YEAR   *
*                     WEIGHTED AGGREGATE EXPENDITURE FROM THE MTBI PUMD        *
*                                                                              *
*     WRITTEN BY:             Taylor J. Wilson - 26 October 2016               *
*     VERSION :               SE/15  (FOR STATA VERSION 11 OR HIGHER)          *
*	  EDITED: 				  24 August 2017								   *
*                                                                              *
*     The results of this program are intended to outline the procedures       *
*     for computing PUMD weighted estimates. Any errors are mine alone.        *
*                                                                              *
********************************************************************************
********************************************************************************
********************************************************************************
#d ;
global inPath = "PATHWAY";

global outPath = "PATHWAY";   

global ucc = "######";

********************************************************************************

#d ;
use "$inPath\fmli161x.dta" ; 
append using "$inPath\fmli162.dta" ;
append using "$inPath\fmli163.dta" ;
append using "$inPath\fmli164.dta" ;  
append using "$inPath\fmli171.dta" ;

save "$outPath\fmli16.dta", replace;

#d ;
clear;
use "$inPath\mtbi161x.dta" ; 
append using "$inPath\mtbi162.dta" ;
append using "$inPath\mtbi163.dta" ;
append using "$inPath\mtbi164.dta" ;  
append using "$inPath\mtbi171.dta" ;

save "$outPath\mtbi16.dta", replace;

#d; 
keep if ref_yr == "2016";
keep if ucc == "$ucc";
collapse(sum) cost, by(newid);

#d;
merge 1:1 newid using "$outPath\fmli16.dta";
keep if _merge == 3;

#d;
gen wtexp = finlwt21*cost;
collapse(sum) wtexp;
