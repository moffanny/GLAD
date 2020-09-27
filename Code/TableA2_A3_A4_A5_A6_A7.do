
*******************************************************************************
*********        ESTIMATING THE EFFECT OF THE ACCESS TO GLAD         **********
*******************************************************************************

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
global 	outputs		"${user}Code\Results"


cd "${user}"
use "${data}GLAD_yearly_panel", clear
cd "${outputs}"

*======================================================================*
* First section: Effects of the access to GLAD
* Table A2: Effect of access to GLAD on the probability of deforestation
* Table A6: Robustness with winsorized outcome: effect of access to GLAD
* Table A7: Robustness with percent deforestation outcome: effect of access to GLAD
*======================================================================*

*** globals of outcomes and controls
global outcome					bin_defor perc_defor_w perc_defor 	
global Cont_Year_FE				i.yearAsia i.yearSA 
global time_var_controls		av_prec Temp 
global time_inv_controls		c.perc_PA##i.year c.lnDistPort##i.year c.lnDistRoad##i.year c.lnDistUrban##i.year 

																																								
*** globals for tables
global prec				3f
global yr_premean       2008!=1

drop GLAD_2017
gen GLAD_2017 = GLAD_2017m11 == 1 | GLAD_2017m2 == 1
replace country_co = "KAL" if Kalimantan == 1
gen count = 1

collapse (mean) perc_defor	bin_defor perc_defor_w	GLAD GLADAsia GLADSouthAmerica yearAsia yearSA av_prec Temp perc_PA lnDistPort lnDistRoad lnDistUrban GLAD_2016m3 GLAD_2016m8 GLAD_2017m2 GLAD_2017m11 GLAD_2017 ///
SouthAmerica Africa Asia  (sum) sampling_w, by(country_co year)

encode country_co, gen(countrycc)
xtset countrycc year

la var GLAD "GLAD availability"
la var GLADAsia "GLAD x Asia"
la var GLADSouthAmerica "GLAD x South America"


 foreach var of global outcome {
 *Run regression
 local reg1 = "reg1"
 eststo `reg1': reg `var' GLAD [aw=sampling_w], r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,1,.)
 matrix boot_ci_ub = J(1,1,.)

 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg1'
 matrix colnames boot_ci_ub = GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg1'

 
 *Run regression
 local reg2 = "reg2"
 eststo `reg2': xtreg `var' GLAD [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg2'
 matrix colnames boot_ci_ub = GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg2'
 
 *Run regression
 local reg3 = "reg3"
 eststo `reg3': xtreg `var' GLAD i.year [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg3'
 matrix colnames boot_ci_ub = GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg3'
 
  *Run regression
 local reg4 = "reg4"
 eststo `reg4': xtreg `var' GLAD i.year $Cont_Year_FE  [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg4'
 matrix colnames boot_ci_ub = GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg4'
 
 *Run regression
 local reg5 = "reg5"
 eststo `reg5': xtreg `var' GLAD i.year $Cont_Year_FE $time_var_controls [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg5'
 matrix colnames boot_ci_ub = GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg5'
 
 *Run regression
 local reg6 = "reg6"
 eststo `reg6': xtreg `var' GLAD i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg6'
 matrix colnames boot_ci_ub = GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg6'
 
xtreg `var' GLAD i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co)
tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_avg_bar`var'.dta", replace
lincom GLAD 
post `dydx' (r(estimate)) (r(se)) (1) (e(df_r))
postclose `dydx'
 
*Save text file
esttab `reg1' `reg2' `reg3' `reg4' `reg5' `reg6' using TableA_GLAD_`var'ctry_CIboot.tex,  prehead(\textbf{Panel A} \\ \\) fragment replace label  ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes cells(b(fmt(3)) boot_ci_lb(fmt(2) par(`"["' `","')) & boot_ci_ub(fmt(2) par(`""' `"]"'))) ///
	style(tex)  nomtitles nodepvars noobs keep(GLAD) 


*Run regression
 local reg1 = "reg1"
 eststo `reg1': reg `var' GLAD GLADAsia GLADSouthAmerica [aw=sampling_w], r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 local n_vars = 3
 local indep_hypotheses
 foreach j of varlist GLAD GLADAsia GLADSouthAmerica {
	local indep_hypotheses = "`indep_hypotheses' {`j'}"
	}
  
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg1'
	matrix colnames boot_ci_ub = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg1'
 

*Run regression
 local reg2 = "reg2"
 eststo `reg2': xtreg `var' GLAD GLADAsia GLADSouthAmerica [aw=sampling_w], fe r cluster(country_co)
  
  *Run boottest to get bootstrapped CIs for GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg2'
	matrix colnames boot_ci_ub = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg2'

*Run regression
 local reg3 = "reg3"
 eststo `reg3': xtreg `var' GLAD GLADAsia GLADSouthAmerica i.year [aw=sampling_w], fe r cluster(country_co)

  *Run boottest to get bootstrapped CIs for GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg3'
	matrix colnames boot_ci_ub = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg3'

*Run regression
 local reg4 = "reg4"
 eststo `reg4': xtreg `var' GLAD GLADAsia GLADSouthAmerica i.year $Cont_Year_FE [aw=sampling_w], fe r cluster(country_co)

 *Run boottest to get bootstrapped CIs for GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg4'
	matrix colnames boot_ci_ub = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg4'

*Run regression
 local reg5 = "reg5"
 eststo `reg5': xtreg `var' GLAD GLADAsia GLADSouthAmerica i.year $Cont_Year_FE $time_var_controls [aw=sampling_w], fe r cluster(country_co)
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg5'
	matrix colnames boot_ci_ub = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg5'


*Run regression
 local reg6 = "reg6"
 eststo `reg6':  xtreg `var' GLAD GLADAsia GLADSouthAmerica i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co)
 
 *Run boottest to get bootstrapped CIs for GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg6'
	matrix colnames boot_ci_ub = GLAD GLADAsia GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg6'

xtreg `var' GLAD GLADAsia GLADSouthAmerica i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co)
 tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_het_bar`var'.dta", replace
 lincom GLAD
 post `dydx' (r(estimate)) (r(se)) (2) (e(df_r))
 lincom GLAD + GLADAsia
 post `dydx' (r(estimate)) (r(se)) (3) (e(df_r))
 lincom GLAD + GLADSouthAmerica
 post `dydx' (r(estimate)) (r(se)) (4) (e(df_r))
 
 postclose `dydx'
  
 esttab `reg1' `reg2' `reg3' `reg4' `reg5' `reg6' using TableA_GLAD_`var'ctry_CIboot.tex,   prehead(\hline \textbf{Panel B} \\ ) fragment append label  ///
	keep(GLAD GLADAsia GLADSouthAmerica)  cells(b(fmt(3)) boot_ci_lb(fmt(2) par(`"["' `","')) & boot_ci_ub(fmt(2) par(`""' `"]"'))) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes  ///
	style(tex)  nomtitles nonum
	
	eststo clear
}

*======================================================================*
* Second section: Pre-trends acess to GLAD
* Table A3: Pre-trends: access to GLAD on probability of deforestation
* Table A4: Robustness with winsorized outcome – pre-trends: access to GLAD
* Table A5: Robustness with percent deforestation outcome: pre-trends: access to GLAD
*======================================================================*

forval i = 2012/2015 {
gen GLAD_2017_y`i' = 0
replace GLAD_2017_y`i' = 1 if GLAD_2017 == 1 & year == `i'
}

la var GLAD_2017_y2012 "GLAD 3rd and 4th wave x year 2012"
la var GLAD_2017_y2013 "GLAD 3rd and 4th wave x year 2013"
la var GLAD_2017_y2014 "GLAD 3rd and 4th wave x year 2014"
la var GLAD_2017_y2015 "GLAD 3rd and 4th wave x year 2015"

foreach var of global outcome {
*Run regression
 local reg1 = "reg1"
 eststo `reg1': reg `var' GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 [aw=sampling_w] if  year < 2016, r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for GLAD
 local n_vars = 4
 local indep_hypotheses
 foreach j of varlist GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 {
	local indep_hypotheses = "`indep_hypotheses' {`j'}"
	}
  
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,4,.)
 matrix boot_ci_ub = J(1,4,.)
 forval k = 1/4 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_lb = boot_ci_lb: `reg1'
	matrix colnames boot_ci_ub = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_ub = boot_ci_ub: `reg1'
 
 *Run regression
 local reg2 = "reg2"
 eststo `reg2': xtreg `var' GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 [aw=sampling_w] if year < 2016, fe r cluster(country_co)
 
 *Run boottest to get bootstrapped CIs 
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,4,.)
 matrix boot_ci_ub = J(1,4,.)
 forval k = 1/4 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_lb = boot_ci_lb: `reg2'
	matrix colnames boot_ci_ub = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_ub = boot_ci_ub: `reg2'
 
 *Run regression
 local reg3 = "reg3"
 eststo `reg3': xtreg `var' GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 i.year [aw=sampling_w] if year < 2016, fe r cluster(country_co)
 
  *Run boottest to get bootstrapped CIs 
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,4,.)
 matrix boot_ci_ub = J(1,4,.)
 forval k = 1/4 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_lb = boot_ci_lb: `reg3'
	matrix colnames boot_ci_ub = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_ub = boot_ci_ub: `reg3'
 
 *Run regression
 local reg4 = "reg4"
 eststo `reg4': xtreg `var' GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 i.year $Cont_Year_FE [aw=sampling_w] if  year < 2016, fe r cluster(country_co)
 
  *Run boottest to get bootstrapped CIs 
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,4,.)
 matrix boot_ci_ub = J(1,4,.)
 forval k = 1/4 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_lb = boot_ci_lb: `reg4'
	matrix colnames boot_ci_ub = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_ub = boot_ci_ub: `reg4'

*Run regression
 local reg5 = "reg5"
 eststo `reg5': xtreg `var' GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 i.year $Cont_Year_FE $time_var_controls [aw=sampling_w] if year < 2016, fe r cluster(country_co)
 
  *Run boottest to get bootstrapped CIs 
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,4,.)
 matrix boot_ci_ub = J(1,4,.)
 forval k = 1/4 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_lb = boot_ci_lb: `reg5'
	matrix colnames boot_ci_ub = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_ub = boot_ci_ub: `reg5'
	
*Run regression	
 local reg6 = "reg6"
 eststo `reg6': xtreg `var' GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015 i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w] if year < 2016, fe r cluster(country_co)
 
  *Run boottest to get bootstrapped CIs 
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,4,.)
 matrix boot_ci_ub = J(1,4,.)
 forval k = 1/4 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_lb = boot_ci_lb: `reg6'
	matrix colnames boot_ci_ub = GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015
	estadd matrix boot_ci_ub = boot_ci_ub: `reg6'
 
 esttab `reg1' `reg2' `reg3' `reg4' `reg5' `reg6' using TableA_GLAD_pre_trends_`var'ctry_CIboot.tex,  prehead() fragment replace label  ///
	keep(GLAD_2017_y2012 GLAD_2017_y2013 GLAD_2017_y2014 GLAD_2017_y2015) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes cells(b(fmt(3)) boot_ci_lb(fmt(2) par(`"["' `","')) & boot_ci_ub(fmt(2) par(`""' `"]"')))  ///
	style(tex)  nomtitles
	
	
	eststo clear
	}

