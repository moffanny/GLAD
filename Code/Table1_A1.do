*======================================================================*
* TABLE 1: Summary statistics: simple means, standard deviations and 
* normalized differences for subscriptions
* TABLE A1: Summary statistics: simple means and standard deviations
* for the full population of grid-cells
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


cd "${user}"
use "${data}GLAD_yearly_panel", clear
cd "${outputs}"


********************************************************************************
************ Summary statistics for The Impact of Subscriptions ****************
************      				Table 1     	     			****************
********************************************************************************

* Look at pre-2016 deforestation rates
foreach i of varlist bin_defor perc_defor perc_defor_w {
gen `i'_pre2016 = `i'
replace `i'_pre2016 = . if year > 2015
}

la var perc_defor_pre2016 "~~~~\% deforestation (pre-2016)"
la var perc_defor_w_pre2016 "~~~~\% deforestation winsorized (pre-2016)"
la var bin_defor_pre2016 "~~~~Deforestation (0/1) (pre-2016)" 
la var av_prec "~~~~Average precipitation/day (mm)"
la var Temp "~~~~Average temperature"
la var perc_PA "~~~~Protected areas (\%)"
la var DistPort "~~~~Dist to nearest port w/i country (km)"
la var DistRoad "~~~~Dist to nearest road (km)"
la var DistUrban "~~~~Dist to city > 100,000 (km)"

global outcomes						bin_defor_pre2016 perc_defor_pre2016 perc_defor_w_pre2016
global Var_time_variant 			av_prec Temp	
global Var_time_invariant			perc_PA DistPort DistRoad 

* From the sample of grid-cells that ever had a subscription, half of them
* were registered before or by 2017m4
gen early_subsc_temp = 1 if Subscription > 0 & year == 2016 
replace early_subsc_temp = 1 if	Subscription >= 9/12 & year == 2017  
bys Unique_ID: egen early_subsc = min(early_subsc_temp)
replace early_subsc = 0 if early_subsc == .

* Normalized differences (Imbens and Wooldridge 2007)
eststo early: estpost sum $outcomes if early_subsc == 1 & w_intent_sample == 1
eststo late: estpost sum $outcomes if early_subsc == 0 & w_intent_sample == 1
eststo never: estpost sum $outcomes if w_intent_sample != 1
preserve
foreach var in $outcomes {
ttest `var' if w_intent_sample == 1, by(early_subsc)
replace `var' = . 
replace `var' = (r(mu_2) - r(mu_1))/(sqrt(r(sd_2)^2 + r(sd_1)^2)) 
}
eststo Norm_diff: estpost sum $outcomes 
restore

esttab early late never Norm_diff using "Table1_Norm_diff_Subscription_early_VS_late.tex", prehead("\textbf{Outcomes} \\") ///
replace f cells("mean(fmt(2)) sd(par fmt(2))") la style(tex) ///
collabels(none) nomtitle nonumbers nolines noobs

eststo clear

* Normalized differences (Imbens and Wooldridge 2007)
eststo early: estpost sum $Var_time_variant $Var_time_invariant if early_subsc == 1 & w_intent_sample == 1 
eststo late: estpost sum $Var_time_variant $Var_time_invariant if early_subsc == 0 & w_intent_sample == 1 
eststo never: estpost sum $Var_time_variant $Var_time_invariant if w_intent_sample != 1 
preserve
foreach var in $Var_time_variant $Var_time_invariant {
ttest `var' if w_intent_sample == 1, by(early_subsc)
replace `var' = . 
replace `var' = (r(mu_2) - r(mu_1))/(sqrt(r(sd_2)^2 + r(sd_1)^2)) if w_intent_sample == 1 
}
eststo Norm_diff: estpost sum $Var_time_variant $Var_time_invariant 
restore

esttab early late never Norm_diff using "Table1_Norm_diff_Subscription_early_VS_late.tex", prehead("\textbf{Controls} \\") ///
append f cells("mean(fmt(2)) sd(par fmt(2))") la style(tex) ///
collabels(none) nonumbers nolines nomtitles noobs

eststo clear

* Normalized differences (Imbens and Wooldridge 2007)
eststo early: estpost sum DistUrban if early_subsc == 1 & w_intent_sample == 1  & year == 2015
eststo late: estpost sum DistUrban if early_subsc == 0 & w_intent_sample == 1  & year == 2015
eststo never: estpost sum DistUrban if w_intent_sample != 1  & year == 2015
preserve
foreach var in DistUrban {
ttest `var' if w_intent_sample == 1 & year == 2015, by(early_subsc)
replace `var' = . 
replace `var' = (r(mu_2) - r(mu_1))/(sqrt(r(sd_2)^2 + r(sd_1)^2)) if w_intent_sample == 1 & year == 2015
}
eststo Norm_diff: estpost sum DistUrban
restore

esttab early late never Norm_diff using "Table1_Norm_diff_Subscription_early_VS_late.tex",  ///
append f cells("mean(fmt(2)) sd(par fmt(2))") la style(tex) ///
collabels(none) nonumbers nolines nomtitles 

eststo clear

********************************************************************************
****************** Summary statistics for The Impact of GLAD *******************
****************** 		        	Table A1   		 		 *******************
********************************************************************************
global samples						Pooled SouthAmerica Africa Asia
global outcomes						bin_defor perc_defor perc_defor_w 
global alerts						bin_Alerts Alerts
global Var_time_variant 			av_prec Temp	
global Var_time_invariant			perc_PA DistPort DistRoad DistUrban

la var bin_defor "~~~~Deforestation (0/1)"
la var perc_defor "~~~~\% deforestation"
la var perc_defor_w "~~~~\% deforestation winsorized"

la var Alerts "~~~~\% forest cover with alerts"
la var bin_Alerts "~~~~Alerts (0/1)"

foreach var of global samples {
eststo: estpost sum $outcomes if `var' == 1
}

esttab using "TableA1_sum_stats_GLAD.tex", prehead("\textbf{Outcomes} \\") replace ///
	fragment cells("mean(fmt(2))" "sd(par fmt(2))") la  style (tex)  ///
	collabels(none) noobs nomtitles nonumber nolines 

eststo clear
 
 
foreach var of global samples {
eststo: estpost sum $alerts if `var' == 1
}


esttab using "TableA1_sum_stats_GLAD.tex", prehead("\textbf{GLAD alerts} \\") append ///
fragment cells("mean(fmt(2))" "sd(par fmt(2))") la  style (tex)  ///
collabels(none) noobs nomtitles nonumber nolines

eststo clear
 
	
foreach var of global samples {
eststo: estpost sum $Var_time_variant $Var_time_invariant if `var' == 1
}

esttab using "TableA1_sum_stats_GLAD.tex", prehead("\textbf{Controls} \\") append ///
	fragment cells("mean(fmt(2))" "sd(par fmt(2))") la  style (tex)  ///
	collabels(none) nomtitles nonumber nolines

eststo clear
 




 
 
