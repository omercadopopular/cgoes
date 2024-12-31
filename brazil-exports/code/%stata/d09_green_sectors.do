clear
capture log close
log using "logs\d01.smcl", replace  					// chooses logfile

/// 1. import RAIS dataset

use "data\rais\RAIS_data_1995_2022_by_microregion_and_CNAE95_5digits.dta", clear