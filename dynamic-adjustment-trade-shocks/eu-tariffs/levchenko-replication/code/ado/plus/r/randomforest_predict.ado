capture program drop randomforest_predict
program define randomforest_predict, eclass
	version 15.0
	syntax anything(id="argument name" name=arg) [if] [in], [pr]
	marksample touse, novarlist
	local numVars : word count `arg'
	if "`e(model_type)'" == "random forest regression"{
		if ("`pr'" == "pr"){
			di as error "Cannot predict class probabilities on a continuous y variable"
			exit 107
		}
		if (`numVars' > 1){
			di as error "Too many elements in the current varlist. Prediction can only be made one variable at a time."
			exit 103
		}
		javacall RF EvaluateModel if `touse', args(`arg') jars(randomforest.jar weka.jar)
		ereturn scalar MAE = MAE
		ereturn scalar RMSE = RMSE
	}
	else if "`e(model_type)'" == "random forest classification"{
		local lengthofString = udstrlen("`arg'")
		local lastChar = substr("`arg'", `lengthofString', `lengthofString')		
		if ("`lastChar'" == "*" & "`pr'" == "pr"){
			local mainStub = substr("`arg'", 1, `lengthofString' - 1)
			quietly levelsof `e(depvar)'
			local l = r(levels)
			local variable_list
			foreach value of local l{
				local varName = "`mainStub'" + "`value'"
				local variable_list `variable_list' `varName'
			}
			javacall RF EvaluateModel if `touse', args(`variable_list' `pr') jars(randomforest.jar weka.jar)
		}
		else {
			javacall RF EvaluateModel if `touse', args(`arg' `pr') jars(randomforest.jar weka.jar)
		}
		if ("`pr'" == ""){
			ereturn scalar correct_class = correctly_classified
			ereturn scalar incorrect_class = incorrectly_classified
			ereturn scalar error_rate = error_rate
			ereturn matrix fMeasure = fMeasure
			
			local transform = "true"
			quietly levelsof `e(depvar)'
			local l = r(levels)
			foreach value of local l{
				if ("`value'" == "0"){
					local transform = "false"
					break
				}
			}
			local classVarLabel = originalValueLabel
			if ("`transform'" == "true" && `numVars' == 1){
					quietly replace `arg' = `arg' + 1
				}
			if ("`classVarLabel'" != ""){
				local newLabel = newLabel
				label copy `classVarLabel' `newLabel'
			}
		}
	}
end
