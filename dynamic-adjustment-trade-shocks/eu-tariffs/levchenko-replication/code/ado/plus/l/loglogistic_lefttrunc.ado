capture program drop loglogistic_lefttrunc
program loglogistic_lefttrunc
    version 12
    args lnfj alpha beta
	tempvar A B C  
    quietly {
      gen double `A' = 1+(($ML_y1/`alpha')^`beta')
      gen double `B' = ln(`beta')-ln(`alpha')
      gen double `C' = ln($ML_y1)-ln(`alpha')
      replace `lnfj' = `B' + (`beta'-1)*`C' - 2*ln(`A') + ln(1+(($ML_y2/`alpha')^`beta'))
	}      
end
