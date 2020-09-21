*======================================================================*
* Figure A1: Deforestation rates across, with countries groups where those
* that receive the GLAD alert at the same moment are averaged together
* Figure A2: Percent of forest cover with alerts across, with countries 
* groups where those that receive the GLAD alert at the same moment are 
* averaged together
*======================================================================*

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
version 15              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
* --------------------------------------------------

global 	user		C:\Users\`c(username)'
global	data		"${user}Supporting_Datasets\"
global 	outputs		"${user}Do_Files\Results"


* Figure A1
cd "${user}"
use "${data}GLAD_yearly_panel", clear
cd "${outputs}"

fcollapse perc_defor [pw=sampling_w], by(GLAD_2016m3 GLAD_2016m8 GLAD_2017m2 GLAD_2017m11 year) 

la var perc_defor "% deforestation"

 twoway line perc_defor year if GLAD_2016m3 == 1, xline(2016) saving(GLAD_yearly_2016m3, replace)  ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") title("First wave (Mar 2016)") ///
  xlabel(2011(1)2018)
 
 twoway line perc_defor year if GLAD_2016m8 == 1, xline(2016) saving(GLAD_yearly_2016m8, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") title("Second wave (Aug 2016)") ///
  xlabel(2011(1)2018)
 
 twoway line perc_defor year if GLAD_2017m2 == 1, xline(2017) saving(GLAD_yearly_2017m2, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") title("Third wave (Feb 2017)") ///
  xlabel(2011(1)2018)
 
 twoway line perc_defor year if GLAD_2017m11 == 1, xline(2017) saving(GLAD_yearly_2017m11, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") title("Fourth wave (Nov 2017)") ///
  xlabel(2011(1)2018)

graph combine GLAD_yearly_2016m3.gph GLAD_yearly_2016m8.gph GLAD_yearly_2017m2.gph GLAD_yearly_2017m11.gph, graphregion(color(white)) ///
title("{bf: Percent deforestation}")

graph export Perc_defor_by_countries_wave.png, replace	


* Figure A2

cd "${user}"
use "${data}GLAD_monthly_panel", clear
cd "${outputs}"

fcollapse Alerts (first) smdate [pw=sampling_w], by(GLAD_2016m3 GLAD_2016m8 GLAD_2017m2 GLAD_2017m11 mdate year_num month_num) 

drop if smdate == "2011m1" | smdate == "2012m1" | smdate == "2013m1" | smdate == "2014m1"  

la var Alerts "Percent 2010 f.c. with alerts"
 
replace Alerts = . if GLAD_2017m11 == 1 & year < 2017
 
 global label    
 
 twoway line Alerts mdate if GLAD_2016m3 == 1, xline(`=tm(2016m3)') saving(GLAD_2016m3, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") $label  title("First wave (Mar 2016)")
 
   twoway line Alerts mdate if GLAD_2016m8 == 1, xline(`=tm(2016m8)') saving(GLAD_2016m8, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") $label  title("Second wave (Aug 2016)")
 
  twoway line Alerts mdate if GLAD_2017m2 == 1, xline(`=tm(2017m2)') saving(GLAD_2017m2, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") $label title("Third wave (Feb 2017)")
 
   twoway line Alerts mdate if GLAD_2017m11 == 1, xline(`=tm(2017m11)') saving(GLAD_2017m11, replace) ///
 graphregion(color(white)) bgcolor(white) ytitle("") xtitle("") $label title("Fourth wave (Nov 2017)")
 
graph combine GLAD_2016m3.gph GLAD_2016m8.gph GLAD_2017m2.gph GLAD_2017m11.gph, graphregion(color(white)) ///
title("Percent of forest cover with alerts")

graph export  Alerts_by_countries_wave.png, replace


