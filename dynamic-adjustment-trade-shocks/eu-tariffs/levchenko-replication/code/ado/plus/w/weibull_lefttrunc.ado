capture program drop weibull_lefttrunc
program weibull_lefttrunc
    version 12
    args lnfj alpha beta
    tempvar A B C
    quietly {
      gen double `A' = ln(`beta') - ln(`alpha')
	  gen double `B' = ln($ML_y1) - ln(`alpha')
	  gen double `C' = - ($ML_y1/`alpha')^`beta' + ($ML_y2/`alpha')^`beta' 
	  replace `lnfj' = `A' + (`beta'-1)*(`B') + `C'
	}
end
