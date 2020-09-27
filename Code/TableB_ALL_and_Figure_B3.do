
*******************************************************************************
*********           ESTIMATING THE EFFECT OF USING GLAD              **********
*********          	INCLUDE ALL TABLES FROM SUPPLEMENT B             **********
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


*** globals of outcomes and controls
global outcome					bin_defor perc_defor_w perc_defor		
global Cont_Year_FE				i.yearAsia i.yearSA 
global time_var_controls		av_prec Temp 
global time_inv_controls		c.perc_PA##i.year c.lnDistPort##i.year c.lnDistRoad##i.year c.lnDistUrban##i.year 
																								
																								
*** globals for tables
global prec				3f
global yr_premean       2008!=1
global sample 			w_intent_sample wo_intent_sample

*======================================================================*
* First section: Effects of subcriptions to GLAD
* With intent to monitor
* Table B1: Effect of the subscriptions on the probability of deforestation
* Table B6: Robustness with winsorized outcome: effect of the subscriptions
* Table B7: Robustness with percent deforestation: effect of the subscriptions
* Without intent to monitor
* Table B8: Effect of subscription without intent to monitor on deforestation probability
* Table B9: Robustness with winsorized outcome: Effect of subscription without intent to monitor
* Table B10: Robustness with percent deforestation: Effect of subscription without intent to monitor
*======================================================================*

foreach samp of global sample {
foreach y of global outcome {
 eststo: reg `y' Subscription [pw=sampling_w] if `samp' == 1, r cluster(state_co)
 eststo: xtreg `y' Subscription [pw=sampling_w] if `samp' == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription i.year [pw=sampling_w] if `samp' == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1, fe r cluster(state_co)
 
tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_avg_subs`y'`samp'.dta", replace
lincom Subscription 
post `dydx' (r(estimate)) (r(se)) (1) (e(df_r))
postclose `dydx'

 
 esttab using TableB_Subscriptions_`y'_st_`samp'.tex,  prehead(\textbf{Panel A} \\ ) fragment replace label  ///
	keep(Subscription) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles noobs 
	
	eststo clear

 eststo: reg `y'   Subscription SubsAsia SubsSouthAmerica [pw=sampling_w] if `samp' == 1, r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia SubsSouthAmerica [pw=sampling_w] if `samp' == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia SubsSouthAmerica i.year [pw=sampling_w] if `samp' == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia SubsSouthAmerica i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia SubsSouthAmerica $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia SubsSouthAmerica $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1, fe r cluster(state_co) 

 tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_het_subs`y'`samp'.dta", replace
 lincom Subscription
 post `dydx' (r(estimate)) (r(se)) (2) (e(df_r))
 lincom Subscription + SubsAsia
 post `dydx' (r(estimate)) (r(se)) (3) (e(df_r))
 lincom Subscription + SubsSouthAmerica
 post `dydx' (r(estimate)) (r(se)) (4) (e(df_r))
 
 postclose `dydx'
 
 
 esttab using TableB_Subscriptions_`y'_st_`samp'.tex,  prehead(\hline \textbf{Panel B} \\ ) fragment append label  ///
	keep(Subscription SubsAsia SubsSouthAmerica)  nonum ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles 
	
	eststo clear	

}
}

*======================================================================*
* Second section: Pre-trends subscriptions
* With intent to monitor
* Table B3: Pre-trends for probability of deforestation: subscriptions with intent to monitor
* Table B4: Robustness with winsorized outcome – pre-trends: subscriptions with intent to monitor
* Table B5: Robustness with percent deforestation - pre-trends: subscriptions with intent to monitor
* Without intent to monitor
* Table B11: Pre-trends for probability of deforestation: subscriptions without intent to monitor
* Table B12: Robustness with winsorized outcome – pre-trends: subscriptions without intent to monitor
* Table B13: Robustness with percent deforestation - pre-trends: subscriptions without intent to monitor
*======================================================================*
	
foreach samp of global sample {
foreach y of global outcome {
 eststo: reg `y' y2012subs_2017-y2015subs_2018 [pw=sampling_w] if `samp' == 1 & year < 2016, r cluster(state_co) 
 eststo: xtreg `y' y2012subs_2017-y2015subs_2018 [pw=sampling_w] if `samp' == 1 & year < 2016, fe r cluster(state_co)
 eststo: xtreg `y' y2012subs_2017-y2015subs_2018 i.year [pw=sampling_w] if `samp' == 1 & year < 2016, fe r cluster(state_co)
 eststo: xtreg `y' y2012subs_2017-y2015subs_2018 i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1 & year < 2016, fe r cluster(state_co)
 eststo: xtreg `y' y2012subs_2017-y2015subs_2018 $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1 & year < 2016, fe r cluster(state_co)
  eststo: xtreg `y' y2012subs_2017-y2015subs_2018 $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if `samp' == 1 & year < 2016, fe r cluster(state_co)
   
  if "`samp'"=="w_intent_sample" {  	
 esttab using TableB_Subscriptions_pre_trends_`y'_st.tex,  prehead() fragment replace label  ///
	keep(y2012subs_2017 y2012subs_2018 y2013subs_2017 y2013subs_2018 y2014subs_2017 y2014subs_2018 y2015subs_2017 y2015subs_2018) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles
	
	eststo clear
	}
  if "`samp'"=="wo_intent_sample" {  
 esttab using TableB_Subscriptions_pre_trends_`y'_st_wo_intent.tex,  prehead() fragment replace label  ///
	keep(y2012subs_2017 y2012subs_2018 y2013subs_2017 y2013subs_2018 y2014subs_2017 y2014subs_2018 y2015subs_2017 y2015subs_2018) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles
	
	eststo clear
  }
}
}

*======================================================================*
* Third section: Heterogneous effects of subscriptions
* Table B2: Heterogeneous effects of subscriptions on deforestation probability
* Table B17: Robustness with winsorized outcome - heterogeneous effects of subscriptions
* Table B18: Robustness with percent deforestation: heterogeneous effects of subscriptions
* Table B19: Heterogeneous effects of subscriptions by continent on deforestation probability
* Table B20: Robustness with winsorized outcome - heterogeneous effects of subscriptions by continent
* Table B21: Robustness with percent deforestation: heterogeneous effects of subscriptions by continent
*======================================================================*

global time_inv_controls		c.lnDistPort##i.year c.lnDistRoad##i.year c.lnDistUrban##i.year 

gen binPA = perc_PA > 50
gen binconcessions = (logging_ha + oil_palm_h + woodfiber_ha) > 50 

*** Create sample for countries with concessions: 
gen Country_Cons = 1 if country == "Brunei" | country == "Cameroon" | country == "Central African Republic" | country == "Democratic Republic of the Congo" | country == "Equatorial Guinea" | country == "Gabon" | country == "Indonesia" | country == "Malaysia" | country == "Papua New Guinea" | country == "Republic of Congo" 

gen Subs_PA = Subscription * binPA
gen Subs_PA_Asia = SubsAsia * binPA
gen Subs_PA_SA = SubsSouthAmerica * binPA

la var Subs_PA "Subs x Prot. areas" 
la var Subs_PA_Asia "Subs x Prot. areas x Asia"
la var Subs_PA_SA "Subs x Prot. areas x South Am."

gen Subs_cons = Subscription * binconcessions
gen Subs_cons_Asia = SubsAsia * binconcessions
gen Subs_cons_SA = SubsSouthAmerica * binconcessions

la var Subs_cons "Subs x Concessions" 
la var Subs_cons_Asia "Subs x Concessions x Asia"
la var Subs_cons_SA "Subs x Concessions x South Am."

gen Subs_PA_cons = Subscription * binPA * binconcessions
la var Subs_PA_cons "Subs x Prot. areas x Concessions" 

foreach y of global outcome {
 eststo: reg `y' Subscription Subs_PA Subs_cons  [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, r cluster(state_co)
 eststo: xtreg `y' Subscription Subs_PA Subs_cons  [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription Subs_PA Subs_cons  i.year [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription Subs_PA Subs_cons  i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription Subs_PA Subs_cons  $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co)
 eststo: xtreg `y' Subscription Subs_PA Subs_cons  $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co)
 
 tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_PAw_intent_sample`y'.dta", replace
 lincom Subscription 
 post `dydx' (r(estimate)) (r(se)) (1) (e(df_r))
 lincom Subscription + Subs_PA
 post `dydx' (r(estimate)) (r(se)) (2) (e(df_r))
 lincom Subscription + Subs_cons
 post `dydx' (r(estimate)) (r(se)) (3) (e(df_r))

 postclose `dydx' 

 
 esttab using TableB_Hetero_PA_Cons_Subscriptions_`y'_w_intent_sample.tex, fragment replace label  ///
	keep(Subscription Subs_PA Subs_cons ) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles noobs 
	
	eststo clear
}


foreach y of global outcome {
 eststo: reg `y' Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, r cluster(state_co) 	
 eststo: xtreg `y' Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia i.year [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co) 
 eststo: xtreg `y' Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1 & Country_Cons == 1, fe r cluster(state_co) 

  tempname dydx
postfile `dydx' dydx sedydx cont df using "${data}mfx_PA_and_cons_Asia_Africa_w_intent_sample_`y'.dta", replace
 lincom Subscription 
 post `dydx' (r(estimate)) (r(se)) (1) (e(df_r))
 lincom Subscription + Subs_PA
 post `dydx' (r(estimate)) (r(se)) (2) (e(df_r))
 lincom Subscription + Subs_cons
 post `dydx' (r(estimate)) (r(se)) (3) (e(df_r))
 lincom Subscription + SubsAsia 
 post `dydx' (r(estimate)) (r(se)) (4) (e(df_r))
 lincom Subscription + SubsAsia + Subs_PA + Subs_PA_Asia
 post `dydx' (r(estimate)) (r(se)) (5) (e(df_r))
 lincom Subscription + SubsAsia + Subs_cons + Subs_cons_Asia
 post `dydx' (r(estimate)) (r(se)) (6) (e(df_r))
 
 postclose `dydx' 

 
 
 esttab using Hetero_PA_and_cons_Asia_Africa_subscriptions_`y'.tex,  fragment replace label  ///
	keep(Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia) ///
	order(Subscription SubsAsia Subs_PA Subs_PA_Asia Subs_cons Subs_cons_Asia) ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles 

	eststo clear	

}



*======================================================================*
* Fourth section: Effects of the using GLAD (lagged)
* Table B14: Effect of subscriptions (lagged) on deforestation probability
* Table B15: Effect of subscriptions (lagged) on winsorized outcome
* Table B16: Effect of subscriptions (lagged) on percent deforestation
*======================================================================*
sort Unique_ID year 

foreach samp of global sample {
foreach y of global outcome {
 eststo: reg `y' L.Subscription [pw=sampling_w] if w_intent_sample == 1, r cluster(state_co)
 eststo: xtreg `y' L.Subscription [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co)
 eststo: xtreg `y' L.Subscription i.year [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co)
 eststo: xtreg `y' L.Subscription i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co)
 eststo: xtreg `y' L.Subscription $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co)
 eststo: xtreg `y' L.Subscription $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co)
 
 esttab using TableB_Subscriptions_`y'_st_w_intent_sample_Lag.tex,  prehead(\textbf{Panel A} \\ ) fragment replace label  ///
	keep(L.Subscription) coeflabels(L.Subscription "Lag subscription") ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles noobs 
	
	eststo clear

 eststo: reg `y'   L.Subscription L.SubsAsia L.SubsSouthAmerica [pw=sampling_w] if w_intent_sample == 1, r cluster(state_co) 
 eststo: xtreg `y' L.Subscription L.SubsAsia L.SubsSouthAmerica [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co) 
 eststo: xtreg `y' L.Subscription L.SubsAsia L.SubsSouthAmerica i.year [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co) 
 eststo: xtreg `y' L.Subscription L.SubsAsia L.SubsSouthAmerica i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co) 
 eststo: xtreg `y' L.Subscription L.SubsAsia L.SubsSouthAmerica $time_var_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co) 
 eststo: xtreg `y' L.Subscription L.SubsAsia L.SubsSouthAmerica $time_var_controls $time_inv_controls i.year $Cont_Year_FE [pw=sampling_w] if w_intent_sample == 1, fe r cluster(state_co) 
	
 esttab using TableB_Subscriptions_`y'_st_w_intent_sample_Lag.tex,  prehead(\hline \textbf{Panel B} \\ ) fragment append label  ///
	keep(L.Subscription L.SubsAsia L.SubsSouthAmerica) nonum ///
	coeflabels(L.Subscription "Lag subscription" L.SubsAsia "Lag subs x Asia" L.SubsSouthAmerica "Lag subs x South America") ///
	starlevels(* 0.10 ** 0.05 *** 0.01 )  nonotes b(%12.$prec) se(%12.$prec)  ///
	style(tex)  nomtitles 

	eststo clear	

}
}



*======================================================================*
* Fifth section: Effects of the using GLAD 
* Figure B3: Heterogeneous effect of subscriptions by continent
*======================================================================*

***************** HETEROGENEOUS EFFECTS OF SUBSCRIPTIONS IN PAs AND CONCESSIONS IN ASIA AND AFRICA
use "${data}mfx_PA_and_cons_Asia_Africa_w_intent_sample_bin_defor.dta", clear

la var dydx "Marginal effect"
gen LBdydx = dydx-invttail(500000,.025)*sedydx
gen UBdydx = dydx+invttail(500000,.025)*sedydx


twoway (bar dydx cont,  color(dknavy)  barwidth(.75)) (rcap UBdydx LBdydx cont, color(teal)),  scheme( plotplainblind)  ///
xlabel(1 "Africa" 2 "Africa PA" 3 "Africa concession" 4 "Asia" 5 "Asia PA" 6 "Asia concession" , noticks) ///
ytitle("Marginal effect of Subscriptions") xtitle(" " "Location") legend(off) 

graph export "${outputs}PAConcessionAsiaAfrica.eps", replace
