*======================================================================*
* Figure 3: Average and heterogeneous effects of GLAD availability
* Figure 4: Average and heterogeneous effects of subscriptions
* Figure 5: Heterogeneous effects of subscriptions in PAs and concessions
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
global 	outputs		"${user}Code\Results"


net install cleanplots, from("https://tdmize.github.io/data/cleanplots")

*=========================================================================*
****** AVERAGE AND HETEROGENEOUS EFFECTS OF GLAD AVAILABILITY *************
**************************** Figure 3  ************************************
*=========================================================================*

use "${data}mfx_avg_barbin_defor.dta", clear // data from do file "TableB2_B3_B4_B5_B6_B7"
append using "${data}mfx_het_barbin_defor.dta" // data from do file "TableB2_B3_B4_B5_B6_B7"

la var dydx "Marginal effect"
gen LBdydx = dydx-invttail(150,.025)*sedydx
gen UBdydx = dydx+invttail(150,.025)*sedydx

twoway (bar dydx cont, barwidth(.75) color(dknavy) ) (rcap UBdydx LBdydx cont, color(teal)),   scheme( cleanplots) ///
xlabel(1 "All continents" 2 "Africa" 3 "Asia" 4 "South America", noticks) ///
ytitle("Marginal effect of GLAD availability") xtitle( " " "Geographic coverage") legend(off) 

graph export "${outputs}GLADmfx.eps", replace


*=========================================================================*
********** AVERAGE AND HETEROGENEOUS EFFECTS OF SUBSCRIPTIONS *************
**************************** Figure 4  ************************************
*=========================================================================*

use "${data}mfx_avg_subsbin_deforw_intent_sample.dta", clear // data from do file "TableC_all"
append using "${data}mfx_het_subsbin_deforw_intent_sample.dta" // data from do file "TableC_all"

la var dydx "Marginal effect"
gen LBdydx = dydx-invttail(500000,.025)*sedydx
gen UBdydx = dydx+invttail(500000,.025)*sedydx

twoway (bar dydx cont, barwidth(.75) color(dknavy) ) (rcap UBdydx LBdydx cont, color(teal)),  scheme( cleanplots) ///
xlabel(1 "All continents" 2 "Africa" 3 "Asia" 4 "South America", noticks) ///
ytitle("Marginal effect of GLAD Subscriptions") xtitle( " " "Geographic coverage") legend(off) 

graph export "${outputs}Subsmfx.eps", replace

*=========================================================================*
******* HETEROGENEOUS EFFECTS OF SUBSCRIPTIONS IN PAs AND CONCESSIONS *****
**************************** Figure 5  ************************************
*=========================================================================*

use "${data}mfx_PAw_intent_samplebin_defor.dta", clear // data from do file "TableC_all"

la var dydx "Marginal effect"
gen LBdydx = dydx-invttail(500000,.025)*sedydx
gen UBdydx = dydx+invttail(500000,.025)*sedydx


twoway (bar dydx cont,  color(dknavy)  barwidth(.75)) (rcap UBdydx LBdydx cont, color(teal)),  scheme(cleanplots)  ///
xlabel(1 "Outside PA/concession" 2 "In PA" 3 "In concession" , noticks) ///
ytitle("Marginal effect of Subscriptions") xtitle(" " "Location") legend(off) 

graph export "${outputs}PAConcession.eps", replace



