*! 1.0.1  Pablo A. Mitnik, April 2009
*! d2(exp) is an egen function that returns the mean absolute deviation
*! from the median (within varlist) of exp; d2 accepts weights.
*! Requires that _gwpctile (which is part of egenmore) be installed, 

program define _gd2
        
        version 10.1
        syntax newvarname = /exp [if] [in] [, Weights(varname) BY(varlist)] 
        
        tempvar med d2 x w sumw wadev touse 
        marksample touse, novarlist
                     
        quietly {
        
        if "`weights'"=="" {
	     gen `w' = 1
	     local weights `w'
        }
                
        bysort `touse' `by': egen double `sumw' = total(`weights')
        gen `x' = `exp' if `touse'
        egen double `med' = wpctile(`x'), p(50) weights(`weight') by(`by')
        gen double `wadev' = abs(`x' - `med') * (`weights'/`sumw') 
        egen double `d2' = total(`wadev') if `touse', missing by(`by') 
        gen `typlist' `varlist' = `d2'  
        
        }
end

