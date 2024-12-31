*! version 1.0.0  01sep1998
program define newey2_p 
	version 6

		/* Step 1:
			place command-unique options in local myopts
			Note that standard options are
			LR:
				Index XB Cooksd Hat 
				REsiduals RSTAndard RSTUdent
				STDF STDP STDR noOFFset
			SE:
				Index XB STDP noOFFset
		*/

	local myopts XB Index STDP REsiduals


		/* Step 2:
			call _propts, exit if done, 
			else collect what was returned.
		*/
			/* takes advantage that -myopts- produces error
			 * if -eq()- specified w/ other that xb and stdp */

	_pred_se "`myopts'" `0'
        if `s(done)' { exit }
        local vtyp  `s(typ)'
        local varn `s(varn)'
        local 0 `"`s(rest)'"'



		/* Step 3:
			Parse your syntax.
		*/

	syntax [if] [in] [, `myopts' noOFFset]


		/* Step 4:
			Concatenate switch options together
		*/

	local type  `xb'`index'`stdp'`residuals'
	local args


		/* Step 5:
			quickly process default case if you can 
			Do not forget -nooffset- option.
		*/

	if "`type'" == "" | "`type'" == "index" | "`type'" == "xb" | "`type'" == "REsiduals" {
		if "`type'" == "" {
			di in gr "(option xb assumed; fitted values)"
		}
                _predict `vtyp' `varn' `if' `in', `offset'
                label var `varn' "Fitted values"
		exit
	}


		/* Step 6:
			mark sample (this is not e(sample)).
		*/
	marksample touse


		/* Step 7:
			handle options that take argument one at a time.
			Comment if restricted to e(sample).
			Be careful in coding that number of missing values
			created is shown.
			Do all intermediate calculations in double.
		*/



		/* Step 8:
			handle switch options that can be used in-sample or 
			out-of-sample one at a time.
			Be careful in coding that number of missing values
			created is shown.
			Do all intermediate calculations in double.
		*/

	if "`type'" == "stdp" {
                display "_predict `vtyp' `varn' `if' `in', `offset' stdp"
                _predict `vtyp' `varn' `if' `in', `offset' stdp
                label var `varn' "S.E. of prediction of `e(depvar)'"
		exit
	}

	if "`type'" == "residuals" {
		
                tempvar yhat
		    quietly _predict `vtyp' `yhat' `if' `in', `offset' xb
		    gen `vtyp' `varn' = `e(depvar)' - `yhat' `if' `in'
                label var `varn' "Residuals"
		exit
	}


		/* Step 9:
			handle switch options that can be used in-sample only.
			Same comments as for step 8.
		*/


			/* Step 10.
				Issue r(198), syntax error.
				The user specified more than one option
			*/
	error 198
end

