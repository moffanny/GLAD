
*******************************************************************************
*********        ESTIMATING THE EFFECT OF THE LAGGED GLAD           **********
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
global 	outputs		"${user}Do_Files\Results"


*======================================================================*
* Effects of the access to GLAD (lagged)
* Table A8: Effect of access to GLAD (lagged) on the probability of deforestation
* Table A9: Effect of access to GLAD (lagged) on winsorized outcome 
* Table A10: Effect of access to GLAD (lagged) on percent deforestation
*======================================================================*

cd "${user}"
use "${data}GLAD_yearly_panel" 
cd "${outputs}"


*** globals of outcomes and controls
global outcome					bin_defor perc_defor_w perc_defor 
global Cont_Year_FE				i.yearAsia i.yearSA 
global time_var_controls		av_prec Temp 
global time_inv_controls		c.perc_PA##i.year c.lnDistPort##i.year c.lnDistRoad##i.year c.lnDistUrban##i.year 
																																										
*** globals for tables
global prec				3f
global yr_premean       2008!=1

replace country_co = "KAL" if Kalimantan == 1
gen count = 1
collapse (mean) perc_defor	bin_defor perc_defor_w	GLAD GLADAsia GLADSouthAmerica yearAsia yearSA av_prec Temp perc_PA lnDistPort lnDistRoad lnDistUrban SouthAmerica Africa Asia  (sum) sampling_w, by(country_co year)

encode country_co, gen(countrycc)
xtset countrycc year

la var GLAD "GLAD availability"
la var GLADAsia "GLAD x Asia"
la var GLADSouthAmerica "GLAD x South America"


 foreach var of global outcome {
 *Run regression
 local reg1 = "reg1"
 eststo `reg1': reg `var' l.GLAD [aw=sampling_w], r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest l.GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,1,.)
 matrix boot_ci_ub = J(1,1,.)

 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = l.GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg1'
 matrix colnames boot_ci_ub = l.GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg1'

 
 *Run regression
 local reg2 = "reg2"
 eststo `reg2': xtreg `var' l.GLAD [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest l.GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = l.GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg2'
 matrix colnames boot_ci_ub = l.GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg2'
 
 *Run regression
 local reg3 = "reg3"
 eststo `reg3': xtreg `var' l.GLAD i.year [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest l.GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = l.GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg3'
 matrix colnames boot_ci_ub = l.GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg3'
 
  *Run regression
 local reg4 = "reg4"
 eststo `reg4': xtreg `var' l.GLAD i.year $Cont_Year_FE  [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest l.GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = l.GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg4'
 matrix colnames boot_ci_ub = l.GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg4'
 
 *Run regression
 local reg5 = "reg5"
 eststo `reg5': xtreg `var' l.GLAD i.year $Cont_Year_FE $time_var_controls [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest l.GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = l.GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg5'
 matrix colnames boot_ci_ub = l.GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg5'
 
 *Run regression
 local reg6 = "reg6"
 eststo `reg6': xtreg `var' l.GLAD i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest l.GLAD, small nograph
 
 *Store boottest output in e() matrices	
 matrix CI_temp = r(CI)
 matrix boot_ci_lb[1,1] = CI_temp[1,1]
 matrix boot_ci_ub[1,1] = CI_temp[1,2]
 
 matrix colnames boot_ci_lb = l.GLAD
 estadd matrix boot_ci_lb = boot_ci_lb: `reg6'
 matrix colnames boot_ci_ub = l.GLAD
 estadd matrix boot_ci_ub = boot_ci_ub: `reg6'
 
xtreg `var' l.GLAD i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co)
tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_avg_bar`var'.dta", replace
lincom l.GLAD 
post `dydx' (r(estimate)) (r(se)) (1) (e(df_r))
postclose `dydx'
 
*Save text file
esttab `reg1' `reg2' `reg3' `reg4' `reg5' `reg6' using TableA_GLAD_`var'_Lag_ctry_CIboot.tex,  prehead(\textbf{Panel A} \\ \\) fragment replace label  ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes cells(b(fmt(3)) boot_ci_lb(fmt(2) par(`"["' `","')) & boot_ci_ub(fmt(2) par(`""' `"]"'))) ///
	style(tex)  nomtitles nodepvars noobs keep(L.GLAD) coeflabels(L.GLAD "Lag GLAD") 


*Run regression
 local reg1 = "reg1"
 eststo `reg1': reg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica [aw=sampling_w], r cluster(country_co) 
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 local n_vars = 3
 local indep_hypotheses
 foreach j of varlist l.GLAD l.GLADAsia l.GLADSouthAmerica {
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

	matrix colnames boot_ci_lb = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg1'
	matrix colnames boot_ci_ub = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg1'
 

*Run regression
 local reg2 = "reg2"
 eststo `reg2': xtreg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica [aw=sampling_w], fe r cluster(country_co)
  
  *Run boottest to get bootstrapped CIs for l.GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg2'
	matrix colnames boot_ci_ub = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg2'

*Run regression
 local reg3 = "reg3"
 eststo `reg3': xtreg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica i.year [aw=sampling_w], fe r cluster(country_co)

  *Run boottest to get bootstrapped CIs for l.GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg3'
	matrix colnames boot_ci_ub = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg3'

*Run regression
 local reg4 = "reg4"
 eststo `reg4': xtreg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica i.year $Cont_Year_FE [aw=sampling_w], fe r cluster(country_co)

 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg4'
	matrix colnames boot_ci_ub = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg4'

*Run regression
 local reg5 = "reg5"
 eststo `reg5': xtreg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica i.year $Cont_Year_FE $time_var_controls [aw=sampling_w], fe r cluster(country_co)
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg5'
	matrix colnames boot_ci_ub = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg5'


*Run regression
 local reg6 = "reg6"
 eststo `reg6':  xtreg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co)
 
 *Run boottest to get bootstrapped CIs for l.GLAD
 boottest `indep_hypotheses', small nograph // bootest each coefficient
 
 *Store boottest output in e() matrices	
 matrix boot_ci_lb = J(1,3,.)
 matrix boot_ci_ub = J(1,3,.)
 forval k = 1/3 { // Loop through predictors, aka matrix columns
	matrix CI_temp = r(CI_`k')
	matrix boot_ci_lb[1,`k'] = CI_temp[1,1]
	matrix boot_ci_ub[1,`k'] = CI_temp[1,2]
 }

	matrix colnames boot_ci_lb = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_lb = boot_ci_lb: `reg6'
	matrix colnames boot_ci_ub = l.GLAD l.GLADAsia l.GLADSouthAmerica
	estadd matrix boot_ci_ub = boot_ci_ub: `reg6'

xtreg `var' l.GLAD l.GLADAsia l.GLADSouthAmerica i.year $Cont_Year_FE $time_var_controls $time_inv_controls [aw=sampling_w], fe r cluster(country_co)
 tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_het_bar`var'.dta", replace
 lincom l.GLAD
 post `dydx' (r(estimate)) (r(se)) (2) (e(df_r))
 lincom l.GLAD + l.GLADAsia
 post `dydx' (r(estimate)) (r(se)) (3) (e(df_r))
 lincom l.GLAD + l.GLADSouthAmerica
 post `dydx' (r(estimate)) (r(se)) (4) (e(df_r))
 
 postclose `dydx'
  
 esttab `reg1' `reg2' `reg3' `reg4' `reg5' `reg6' using TableA_GLAD_`var'_Lag_ctry_CIboot.tex,   prehead(\hline \textbf{Panel B} \\ ) fragment append label  ///
	keep(L.GLAD L.GLADAsia L.GLADSouthAmerica)  ///
	coeflabels(L.GLAD "Lag GLAD" L.GLADAsia "Lag GLAD x Asia" L.GLADSouthAmerica "Lag GLAD x South America") ///
	cells(b(fmt(3)) boot_ci_lb(fmt(2) par(`"["' `","')) & boot_ci_ub(fmt(2) par(`""' `"]"'))) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes  ///
	style(tex)  nomtitles nonum
	
	eststo clear
}
