capture program drop weibull_leftcensor
program weibull_leftcensor
    version 12
    args lnfj alpha beta
    tempvar A B C D E 
    quietly {
      gen double `A' = ln(`beta') - ln(`alpha')
      gen double `B' = ($ML_y1/(`alpha'))^(`beta')
      gen double `C' = ln($ML_y1)-ln(`alpha')
      gen double `D' = 1 - $ML_y2
      gen double `E' = 1 - exp(-(($ML_y1/`alpha')^`beta'))
	  replace `lnfj' =  $ML_y2*(`A' + (`beta'-1)*`C' - `B')	+ (`D')*ln(`E')
	}
end
