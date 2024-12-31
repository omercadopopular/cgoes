capture program drop lognormal_lefttrunc
program lognormal_lefttrunc
    version 12
    args lnfj mu var
    tempvar A B C 
    quietly {
      gen double `A' = normal((log($ML_y2) - `mu')/`var')      
      gen double `B' = ((2*_pi)^(1/2))*`var'*$ML_y1      
      gen double `C' = (((log($ML_y1)-`mu')/`var')^2)/2
      replace `lnfj' = -ln(1-`A') - `C' -ln(`B')
	} 
end	
