clear all
set more off

cap log close
log using "./output/logs/log_d05.smcl", append

///////////////////////////////////////////////////
///WTO preferential trade agreements yearly data///
///////////////////////////////////////////////////

*Unzip file
cd "./data/WTO_data/"
unzipfile "WTO_data.zip", replace 
cd "../../"

*Open databases
forvalues year=1996(1)2019 {
	
	*Import database.
	import delimited "./data/WTO_data/WTO_`year'.csv",clear

	*Keep variables.
	keep reportingeconomyiso3acode partnereconomyiso3acode productsectorcode year value

	*Generate string variable for sector code.
	tostring productsectorcode, replace
	replace productsectorcode="0"+productsectorcode if strlen(productsectorcode)<6

	*Save database.
	compress
	save "./temp_files/WTO_`year'.dta",replace

}

*Append databases
clear
forvalues year=1996(1)2019 {

	append using "./temp_files/WTO_`year'.dta"

}

*Save database.
save  "./temp_files/WTO_PTA.dta", replace

*Erase databases.
forvalues year=1996(1)2019{

	erase "./temp_files/WTO_`year'.dta"

}

///////////////////////////////////////////////////
///WTO preferential trade agreements yearly data///
///////////////////////////////////////////////////

*Open database.
use "./temp_files/WTO_PTA.dta", clear

*Rename variables.
rename reportingeconomyiso3acode importer
rename partnereconomyiso3acode exporter
rename productsector hs6

*Generate flag for PTA.
gen PTA_flag=1

*Fix country name (Taiwan).
replace importer="TWN" if importer=="CHT"
replace exporter="TWN" if exporter=="CHT"

*Save database.
save  "./temp_files/WTO_PTA.dta", replace


*Update vintages of WTO PTA data.

use "./temp_files/WTO_PTA.dta", clear

gen hs_vintage_guess="H96" if year<=2001
replace hs_vintage_guess="H02" if year<=2007 & year>=2002
replace hs_vintage_guess="H07" if year<=2011 & year>=2007
replace hs_vintage_guess="H12" if year<=2016 & year>=2012
replace hs_vintage_guess="H17" if year>=2016

gen nomen_old=hs_vintage_guess

replace nomen_old="H17" if importer=="ALB" & year>=2017
replace nomen_old="H12" if importer=="ALB" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ALB" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="ALB" & year<=2008 & year>=2003
replace nomen_old="H96" if importer=="ALB" & year<=2002 & year>=2000

replace nomen_old="H17" if importer=="ARE" & year>=2019
replace nomen_old="H12" if importer=="ARE" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ARE" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ARE" & year<=2006 & year>=2002

replace nomen_old="H17" if importer=="ALB" & year>=2017
replace nomen_old="H12" if importer=="ALB" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ALB" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="ALB" & year<=2008 & year>=2003
replace nomen_old="H96" if importer=="ALB" & year<=2002 & year>=2000

replace nomen_old="H17" if importer=="ARG" & year<=2021 & year>=2019
replace nomen_old="H12" if importer=="ARG" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="ARG" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="ARG" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ARG" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="ARM" & year==2018
replace nomen_old="H12" if importer=="ARM" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="ARM" & year<=2012 & year>=2009
replace nomen_old="H02" if importer=="ARM" & year<=2008 & year>=2006
replace nomen_old="H96" if importer=="ARM" & year<=2005 & year>=2003

replace nomen_old="H07" if importer=="ATG" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="ATG" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="ATG" & year<=2009 & year>=1996

replace nomen_old="H17" if importer=="AUS" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="AUS" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="AUS" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="AUS" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="AUS" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="BDI" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BDI" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BDI" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="BDI" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="BDI" & year==2003
replace nomen_old="H92" if importer=="BDI" & year<=2002           ///!!!

replace nomen_old="H17" if importer=="BEN" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="BEN" & year<=2018 & year>=2015
replace nomen_old="H07" if importer=="BEN" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="BEN" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="BEN" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="BFA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BFA" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="BFA" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="BFA" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="BFA" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="BGD" & year==2018
replace nomen_old="H12" if importer=="BGD" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BGD" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BGD" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BGD" & year<=2001 & year>=1998

replace nomen_old="H02" if importer=="BGR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BGR" & year<=2001 & year>=1997

replace nomen_old="H17" if importer=="BHR" & year<=2021 & year>=2018
replace nomen_old="H12" if importer=="BHR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BHR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BHR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BHR" & year==2001
replace nomen_old="H92" if importer=="BHR" & year<=2000

replace nomen_old="H17" if importer=="BLZ" & year<=2019 & year>=2018
replace nomen_old="H12" if importer=="BLZ" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="BLZ" & year<=2016 & year>=2015
replace nomen_old="H12" if importer=="BLZ" & year<=2014 & year>=2014
replace nomen_old="H07" if importer=="BLZ" & year<=2013 & year>=2012
replace nomen_old="H02" if importer=="BLZ" & year<=2011 & year>=2011
replace nomen_old="H07" if importer=="BLZ" & year<=2010 & year>=2009
replace nomen_old="H02" if importer=="BLZ" & year<=2008 & year>=2006
replace nomen_old="H96" if importer=="BLZ" & year<=2005 & year>=1999
replace nomen_old="H92" if importer=="BLZ" & year<=1996 & year>=1996 ///!!!

replace nomen_old="H17" if importer=="BOL" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BOL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BOL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BOL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BOL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="BRA" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="BRA" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="BRA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BRA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BRA" & year<=2001 & year>=1996

replace nomen_old="H07" if importer=="BRB" & year<=2014 & year>=2012
replace nomen_old="H02" if importer=="BRB" & year<=2011 & year>=2005
replace nomen_old="H96" if importer=="BRB" & year<=2004 & year>=2000
replace nomen_old="H92" if importer=="BRB" & year<=1999               ///!!!

replace nomen_old="H17" if importer=="BRN" & year<=2019 & year>=2017
replace nomen_old="H12" if importer=="BRN" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="BRN" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="BRN" & year<=2008 & year>=2004
replace nomen_old="H96" if importer=="BRN" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="BWA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="BWA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="BWA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="BWA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="BWA" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="BWA" & year<=1996

replace nomen_old="H12" if importer=="CAF" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="CAF" & year<=2013 & year>=2007
replace nomen_old="H02" if importer=="CAF" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CAF" & year==2001
replace nomen_old="H92" if importer=="CAF" & year<=1997               ///!!!

replace nomen_old="H17" if importer=="CAN" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CAN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CAN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CAN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CAN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CHE" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CHE" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CHE" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CHE" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CHE" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CHL" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CHL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CHL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CHL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CHL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CHN" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="CHN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CHN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CHN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CHN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="CIV" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="CIV" & year<=2017 & year>=2015
replace nomen_old="H07" if importer=="CIV" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="CIV" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="CIV" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="CMR" & year<=2019 & year>=2019
replace nomen_old="H12" if importer=="CMR" & year<=2014 & year>=2013
replace nomen_old="H07" if importer=="CMR" & year<=2012 & year>=2010
replace nomen_old="H02" if importer=="CMR" & year<=2009 & year>=2009
replace nomen_old="H07" if importer=="CMR" & year<=2008 & year>=2007
replace nomen_old="H02" if importer=="CMR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="CMR" & year<=2001 & year>=1996 ///!!!

replace nomen_old="H12" if importer=="COG" & year<=2014 & year>=2012
replace nomen_old="H07" if importer=="COG" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="COG" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="COG" & year<=2001 & year>=2007

replace nomen_old="H17" if importer=="CRI" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="CRI" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="CRI" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="CRI" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="CRI" & year<=2002 & year>=1997
replace nomen_old="H92" if importer=="CRI" & year<=1996 & year>=1996

replace nomen_old="H07" if importer=="DJI" & year<=2014 & year>=2011
replace nomen_old="H02" if importer=="DJI" & year==2009
replace nomen_old="H92" if importer=="DJI" & year<=2006               ///!!!

replace nomen_old="H07" if importer=="DMA" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="DMA" & year<=2011 & year>=2005
replace nomen_old="H96" if importer=="DMA" & year<=2004                   ///!!!

replace nomen_old="H17" if importer=="DOM" & year<=2019 & year>=2017
replace nomen_old="H12" if importer=="DOM" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="DOM" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="DOM" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="DOM" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="ECU" & year<=2018 & year>=2018
replace nomen_old="H12" if importer=="ECU" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="ECU" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="ECU" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="ECU" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="EGY" & year<=2019 & year>=2019
replace nomen_old="H12" if importer=="EGY" & year<=2018 & year>=2013
replace nomen_old="H07" if importer=="EGY" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="EGY" & year<=2006 & year>=2004
replace nomen_old="H96" if importer=="EGY" & year<=2003 & year>=1999
replace nomen_old="H92" if importer=="EGY" & year<=1998

replace nomen_old="H02" if importer=="EST" & year<=2003 & year>=2002
replace nomen_old="H96" if importer=="EST" & year<=2001 & year>=1996 ///!!!

replace nomen_old="H07" if importer=="GAB" & year<=2019 & year>=2008
replace nomen_old="H02" if importer=="GAB" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="GAB" & year<=2001 & year>=2000
replace nomen_old="H92" if importer=="GAB" & year<=1998               ///!!!

replace nomen_old="H12" if importer=="GEO" & year<=2020 & year>=2012
replace nomen_old="H02" if importer=="GEO" & year<=2011 & year>=2006
replace nomen_old="H96" if importer=="GEO" & year<=2005 & year>=2001

replace nomen_old="H17" if importer=="EEC" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="EEC" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="EEC" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="EEC" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="EEC" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="GHA" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="GHA" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="GHA" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="GHA" & year<=2007 & year>=2004
replace nomen_old="H96" if importer=="GHA" & year<=2003 & year>=2001

replace nomen_old="H17" if importer=="GIN" & year<=2020 & year>=2017
replace nomen_old="H02" if importer=="GIN" & year<=2013 & year>=2005
replace nomen_old="H92" if importer=="GIN" & year<=2004               ///!!!

replace nomen_old="H17" if importer=="GMB" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="GMB" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="GMB" & year<=2013 & year>=2010
replace nomen_old="H92" if importer=="GMB" & year<=2009               ///!!!

replace nomen_old="H17" if importer=="GNB" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="GNB" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="GNB" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="GNB" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="GNB" & year<=2002               ///!!!

replace nomen_old="H12" if importer=="GRD" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="GRD" & year<=2014 & year>=2012
replace nomen_old="H02" if importer=="GRD" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="GRD" & year<=2009 & year>=2000
replace nomen_old="H92" if importer=="GRD" & year<=1996

replace nomen_old="H12" if importer=="GTM" & year<=2012 & year>=2012
replace nomen_old="H07" if importer=="GTM" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="GTM" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="GTM" & year<=2002 & year>=1997

replace nomen_old="H07" if importer=="GUY" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="GUY" & year<=2011 & year>=2010
replace nomen_old="H07" if importer=="GUY" & year<=2009 & year>=2007
replace nomen_old="H96" if importer=="GUY" & year<=2003 & year>=1999
replace nomen_old="H92" if importer=="GUY" & year<=1996

replace nomen_old="H17" if importer=="HND" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="HND" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="HND" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="HND" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="HND" & year<=2002 & year>=1996

replace nomen_old="H12" if importer=="HRV" & year<=2013 & year>=2012
replace nomen_old="H07" if importer=="HRV" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="HRV" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="HRV" & year<=2001

replace nomen_old="H02" if importer=="HUN" & year<=2002 & year>=2002
replace nomen_old="H96" if importer=="HUN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="IDN" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="IDN" & year<=2015 & year>=2013
replace nomen_old="H07" if importer=="IDN" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="IDN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="IDN" & year<=2001 & year>=1998
replace nomen_old="H92" if importer=="IDN" & year<=1997 & year>=1996

replace nomen_old="H17" if importer=="IND" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="IND" & year<=2016 & year>=2011
replace nomen_old="H07" if importer=="IND" & year<=2010 & year>=2007
replace nomen_old="H02" if importer=="IND" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="IND" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="ISL" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="ISL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ISL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ISL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ISL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="ISR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="ISR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ISR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ISR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ISR" & year<=2001 & year>=1999

replace nomen_old="H12" if importer=="JAM" & year<=2016 & year>=2014
replace nomen_old="H07" if importer=="JAM" & year<=2013 & year>=2007
replace nomen_old="H02" if importer=="JAM" & year<=2006 & year>=2004
replace nomen_old="H96" if importer=="JAM" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="JOR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="JOR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="JOR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="JOR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="JOR" & year<=2001 & year>=2000

replace nomen_old="H17" if importer=="JPN" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="JPN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="JPN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="JPN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="JPN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="KAZ" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="KAZ" & year<=2016 & year>=2015

replace nomen_old="H17" if importer=="KEN" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="KEN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="KEN" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="KEN" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="KEN" & year<=2002 & year>=1998

replace nomen_old="H17" if importer=="KGZ" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="KGZ" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="KGZ" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="KGZ" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="KGZ" & year<=2002 & year>=1999

replace nomen_old="H17" if importer=="KHM" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="KHM" & year<=2016 & year>=2014
replace nomen_old="H07" if importer=="KHM" & year<=2012 & year>=2009
replace nomen_old="H02" if importer=="KHM" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="KHM" & year<=2003 & year>=2002

replace nomen_old="H07" if importer=="KNA" & year<=2016 & year>=2012
replace nomen_old="H02" if importer=="KNA" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="KNA" & year<=2009 & year>=1999
replace nomen_old="H92" if importer=="KNA" & year<=1996

replace nomen_old="H17" if importer=="KOR" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="KOR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="KOR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="KOR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="KOR" & year<=2001 & year>=1996

replace nomen_old="H12" if importer=="KWT" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="KWT" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="KWT" & year<=2006 & year>=2003
replace nomen_old="H92" if importer=="KWT" & year<=2002

replace nomen_old="H12" if importer=="LAO" & year<=2018 & year>=2014
replace nomen_old="H02" if importer=="LAO" & year<=2008 & year>=2008

replace nomen_old="H17" if importer=="LBR" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="LBR" & year<=2017 & year>=2012
replace nomen_old="H96" if importer=="LBR" & year<=2011

replace nomen_old="H12" if importer=="LCA" & year<=2021 & year>=2015
replace nomen_old="H07" if importer=="LCA" & year<=2014 & year>=2012
replace nomen_old="H02" if importer=="LCA" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="LCA" & year<=2007 & year>=2000
replace nomen_old="H92" if importer=="LCA" & year<=1996

replace nomen_old="H12" if importer=="LKA" & year<=2017 & year>=2013
replace nomen_old="H07" if importer=="LKA" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="LKA" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="LKA" & year<=2001 & year>=1998
replace nomen_old="H92" if importer=="LKA" & year<=1997

replace nomen_old="H17" if importer=="LSO" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="LSO" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="LSO" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="LSO" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="LSO" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="LSO" & year<=1996

replace nomen_old="H02" if importer=="LVA" & year<=2002 & year>=2002
replace nomen_old="H96" if importer=="LVA" & year<=2001 & year>=1998

replace nomen_old="H17" if importer=="MAR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MAR" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="MAR" & year<=2014 & year>=2003
replace nomen_old="H96" if importer=="MAR" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MDG" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="MDG" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MDG" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="MDG" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="MDG" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="MDV" & year<=2019 & year>=2017
replace nomen_old="H12" if importer=="MDV" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MDV" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="MDV" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MDV" & year<=2002 & year>=2000

replace nomen_old="H12" if importer=="MEX" & year<=2020 & year>=2013
replace nomen_old="H07" if importer=="MEX" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="MEX" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MEX" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MLI" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="MLI" & year<=2017 & year>=2015
replace nomen_old="H07" if importer=="MLI" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="MLI" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MLI" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MMR" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="MMR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MMR" & year<=2011 & year>=2009
replace nomen_old="H02" if importer=="MMR" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="MMR" & year<=2004 & year>=2004
replace nomen_old="H02" if importer=="MMR" & year<=2003 & year>=2003
replace nomen_old="H96" if importer=="MMR" & year<=2002 & year>=1996

replace nomen_old="H17" if importer=="MNE" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MNE" & year<=2016 & year>=2011

replace nomen_old="H17" if importer=="MNG" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MNG" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MNG" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="MNG" & year<=2007 & year>=2004
replace nomen_old="H96" if importer=="MNG" & year<=2003 & year>=1997
replace nomen_old="H92" if importer=="MNG" & year<=1996

replace nomen_old="H17" if importer=="MOZ" & year<=2019 & year>=2018
replace nomen_old="H07" if importer=="MOZ" & year<=2016 & year>=2010
replace nomen_old="H02" if importer=="MOZ" & year<=2009 & year>=2009
replace nomen_old="H07" if importer=="MOZ" & year<=2008 & year>=2008
replace nomen_old="H02" if importer=="MOZ" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="MOZ" & year<=2001 & year>=2000
replace nomen_old="H92" if importer=="MOZ" & year<=1997

replace nomen_old="H17" if importer=="MUS" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MUS" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="MUS" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="MUS" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="MUS" & year<=2001 & year>=1996

replace nomen_old="H12" if importer=="MWI" & year<=2017 & year>=2014
replace nomen_old="H07" if importer=="MWI" & year<=2013 & year>=2008
replace nomen_old="H02" if importer=="MWI" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="MWI" & year<=2002 & year>=2000
replace nomen_old="H92" if importer=="MWI" & year<=1998

replace nomen_old="H17" if importer=="MYS" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="MYS" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="MYS" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="MYS" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="MYS" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="NAM" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NAM" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NAM" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NAM" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="NAM" & year<=2001 & year>=1997
replace nomen_old="H96" if importer=="NAM" & year<=1996

replace nomen_old="H17" if importer=="NER" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="NER" & year<=2018 & year>=2015
replace nomen_old="H07" if importer=="NER" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="NER" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="NER" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="NGA" & year<=2020 & year>=2020
replace nomen_old="H12" if importer=="NGA" & year<=2019 & year>=2015
replace nomen_old="H07" if importer=="NGA" & year<=2014 & year>=2009
replace nomen_old="H02" if importer=="NGA" & year<=2008 & year>=2005
replace nomen_old="H96" if importer=="NGA" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="NIC" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NIC" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NIC" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NIC" & year<=2006 & year>=2003
replace nomen_old="H96" if importer=="NIC" & year<=2002 & year>=1997
replace nomen_old="H92" if importer=="NIC" & year<=1996

replace nomen_old="H17" if importer=="NOR" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NOR" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NOR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NOR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="NOR" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="NPL" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="NPL" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="NPL" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="NPL" & year<=2006 & year>=2002

replace nomen_old="H17" if importer=="NZL" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="NZL" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="NZL" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="NZL" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="NZL" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="OMN" & year<=2017 & year>=2017
replace nomen_old="H12" if importer=="OMN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="OMN" & year<=2009 & year>=2007
replace nomen_old="H02" if importer=="OMN" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="OMN" & year<=2001

replace nomen_old="H17" if importer=="PAK" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="PAK" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="PAK" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="PAK" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="PAK" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="PER" & year<=2018 & year>=2017
replace nomen_old="H12" if importer=="PER" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="PER" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="PER" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="PER" & year<=2001 & year>=1998
replace nomen_old="H92" if importer=="PER" & year<=1997

replace nomen_old="H17" if importer=="PHL" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="PHL" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="PHL" & year<=2012 & year>=2008
replace nomen_old="H02" if importer=="PHL" & year<=2007 & year>=2004
replace nomen_old="H96" if importer=="PHL" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="QAT" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="QAT" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="QAT" & year<=2011 & year>=2005
replace nomen_old="H02" if importer=="QAT" & year<=2004 & year>=2002

replace nomen_old="H17" if importer=="RUS" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="RUS" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="RUS" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="RUS" & year<=2001

replace nomen_old="H17" if importer=="RWA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="RWA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="RWA" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="RWA" & year<=2007 & year>=2005
replace nomen_old="H96" if importer=="RWA" & year<=2004 & year>=2000

replace nomen_old="H17" if importer=="SAU" & year<=2020 & year>=2020
replace nomen_old="H07" if importer=="SAU" & year<=2018 & year>=2018
replace nomen_old="H17" if importer=="SAU" & year<=2017 & year>=2017
replace nomen_old="H07" if importer=="SAU" & year<=2016 & year>=2016
replace nomen_old="H12" if importer=="SAU" & year<=2015 & year>=2012
replace nomen_old="H07" if importer=="SAU" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="SAU" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="SAU" & year<=2001

replace nomen_old="H17" if importer=="SEN" & year<=2020 & year>=2019
replace nomen_old="H12" if importer=="SEN" & year<=2018 & year>=2015
replace nomen_old="H07" if importer=="SEN" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="SEN" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="SEN" & year<=2002 & year>=2001

replace nomen_old="H17" if importer=="SGP" & year<=2021 & year>=2019
replace nomen_old="H12" if importer=="SGP" & year<=2018 & year>=2012
replace nomen_old="H07" if importer=="SGP" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="SGP" & year<=2007 & year>=2005
replace nomen_old="H96" if importer=="SGP" & year<=2004 & year>=1996

replace nomen_old="H12" if importer=="SLB" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="SLB" & year<=2013 & year>=2007
replace nomen_old="H92" if importer=="SLB" & year<=2006

replace nomen_old="H12" if importer=="SLB" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="SLB" & year<=2013 & year>=2007
replace nomen_old="H92" if importer=="SLB" & year<=2006

replace nomen_old="H17" if importer=="SLE" & year<=2020 & year>=2018
replace nomen_old="H07" if importer=="SLE" & year<=2016 & year>=2010
replace nomen_old="H02" if importer=="SLE" & year<=2006 & year>=2004

replace nomen_old="H17" if importer=="SLV" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="SLV" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="SLV" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="SLV" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="SLV" & year<=2001 & year>=1996

replace nomen_old="H07" if importer=="SRB" & year<=2010 & year>=2009
replace nomen_old="H02" if importer=="SRB" & year<=2005 & year>=2005

replace nomen_old="H02" if importer=="SVK" & year<=2003 & year>=2002
replace nomen_old="H96" if importer=="SVK" & year<=2001 & year>=1998

replace nomen_old="H17" if importer=="SWZ" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="SWZ" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="SWZ" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="SWZ" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="SWZ" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="SYC" & year<=2020 & year>=2018
replace nomen_old="H07" if importer=="SYC" & year<=2017 & year>=2015

replace nomen_old="H07" if importer=="TCD" & year<=2016 & year>=2014
replace nomen_old="H12" if importer=="TCD" & year<=2013 & year>=2013
replace nomen_old="H07" if importer=="TCD" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="TCD" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="TCD" & year<=2001 & year>=2001
replace nomen_old="H92" if importer=="TCD" & year<=1997

replace nomen_old="H17" if importer=="TGO" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="TGO" & year<=2017 & year>=2015
replace nomen_old="H07" if importer=="TGO" & year<=2014 & year>=2008
replace nomen_old="H02" if importer=="TGO" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="TGO" & year<=2002 & year>=1998
replace nomen_old="H92" if importer=="TGO" & year<=1997

replace nomen_old="H17" if importer=="THA" & year<=2021 & year>=2017
replace nomen_old="H12" if importer=="THA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="THA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="THA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="THA" & year<=2001 & year>=1999

replace nomen_old="H07" if importer=="TJK" & year<=2017 & year>=2011

replace nomen_old="H12" if importer=="TTO" & year<=2018 & year>=2018
replace nomen_old="H07" if importer=="TTO" & year<=2013 & year>=2007
replace nomen_old="H02" if importer=="TTO" & year<=2006 & year>=2004
replace nomen_old="H96" if importer=="TTO" & year<=2003 & year>=1999
replace nomen_old="H92" if importer=="TTO" & year<=1996

replace nomen_old="H12" if importer=="TUN" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="TUN" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="TUN" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="TUN" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="TUR" & year<=2019 & year>=2019
replace nomen_old="H12" if importer=="TUR" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="TUR" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="TUR" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="TUR" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="TWN" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="TWN" & year<=2016 & year>=2014
replace nomen_old="H07" if importer=="TWN" & year<=2013 & year>=2009
replace nomen_old="H02" if importer=="TWN" & year<=2008 & year>=2004
replace nomen_old="H96" if importer=="TWN" & year<=2003 & year>=1996

replace nomen_old="H17" if importer=="TZA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="TZA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="TZA" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="TZA" & year<=2007 & year>=2005
replace nomen_old="H96" if importer=="TZA" & year<=2004 & year>=1998

replace nomen_old="H17" if importer=="UGA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="UGA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="UGA" & year<=2011 & year>=2008
replace nomen_old="H02" if importer=="UGA" & year<=2007 & year>=2002
replace nomen_old="H96" if importer=="UGA" & year<=2001 & year>=2000

replace nomen_old="H17" if importer=="URY" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="URY" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="URY" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="URY" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="URY" & year<=2001 & year>=1996

replace nomen_old="H17" if importer=="USA" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="USA" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="USA" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="USA" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="USA" & year<=2001 & year>=1996

replace nomen_old="H07" if importer=="VCT" & year<=2020 & year>=2012
replace nomen_old="H02" if importer=="VCT" & year<=2011 & year>=2010
replace nomen_old="H96" if importer=="VCT" & year<=2007 & year>=1999
replace nomen_old="H92" if importer=="VCT" & year<=1996

replace nomen_old="H12" if importer=="VEN" & year<=2016 & year>=2013
replace nomen_old="H02" if importer=="VEN" & year<=2012 & year>=2005
replace nomen_old="H96" if importer=="VEN" & year<=2004 & year>=1996

replace nomen_old="H17" if importer=="VNM" & year<=2020 & year>=2018
replace nomen_old="H12" if importer=="VNM" & year<=2017 & year>=2012
replace nomen_old="H07" if importer=="VNM" & year<=2010 & year>=2008
replace nomen_old="H02" if importer=="VNM" & year<=2007 & year>=2003
replace nomen_old="H96" if importer=="VNM" & year<=2002 & year>=2002

replace nomen_old="H17" if importer=="VUT" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="VUT" & year<=2016 & year>=2015
replace nomen_old="H07" if importer=="VUT" & year<=2012 & year>=2012
replace nomen_old="H02" if importer=="VUT" & year<=2007 & year>=2002

replace nomen_old="H12" if importer=="YEM" & year<=2016 & year>=2015
replace nomen_old="H02" if importer=="YEM" & year<=2009 & year>=2009

replace nomen_old="H17" if importer=="ZAF" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="ZAF" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ZAF" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ZAF" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ZAF" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="ZAF" & year<=1996 & year>=1996

replace nomen_old="H12" if importer=="ZMB" & year<=2016 & year>=2012
replace nomen_old="H07" if importer=="ZMB" & year<=2011 & year>=2007
replace nomen_old="H02" if importer=="ZMB" & year<=2006 & year>=2002
replace nomen_old="H96" if importer=="ZMB" & year<=2001 & year>=2001

replace nomen_old="H17" if importer=="ZWE" & year<=2020 & year>=2017
replace nomen_old="H12" if importer=="ZWE" & year<=2016 & year>=2013
replace nomen_old="H07" if importer=="ZWE" & year<=2012 & year>=2007
replace nomen_old="H02" if importer=="ZWE" & year<=2003 & year>=2002
replace nomen_old="H96" if importer=="ZWE" & year<=2001 & year>=1997
replace nomen_old="H92" if importer=="ZWE" & year<=1996

*Save database.
compress
save "./temp_files/WTO_PTA.dta", replace

*Open database.
use "./temp_files/WTO_PTA.dta", clear

*Change nomenclature (for consistency).
gen hs6_old=hs6
gen nomen=nomen_old
gen byte hs_change=0
	
foreach i in "92" "96" "02" "07" "12" { 
	
	foreach j in "96" "02" "07" "12" "17"{ 
		
		capture confirm file "./temp_files/HS`j'toHS`i'_1to1.dta" 
		
		if _rc==0 {
			dis("HS`j' to HS`i'")
			merge m:1 hs6 nomen using "./temp_files/HS`j'toHS`i'_1to1.dta", keep(master matched) 
			replace hs6=hs6_hs`i' if _merge==3
			replace nomen="H`i'" if _merge==3
			replace hs_change=1 if _merge==3
			drop _merge hs6_hs`i'
		}
		else {
			display "The file HS`j'toHS`i'_1to1.dta does not exist"
		}
		
	}
	
}

*Save database.
compress
save "./temp_files/WTO_PTA.dta", replace
