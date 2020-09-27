*======================================================================*
* Figure B2: Percent of the forests covered by subscriptions
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

cd "${user}"
use "${data}GLAD_monthly_panel", clear
cd "${outputs}"

drop if w_intent_sample != 1

* To have the total number of grid cells that ever had a subscription with intent to monitor
gen Tot = 1

fcollapse (sum) Subscription Tot (first) smdate [pw=sampling_w], by(mdate year_num month_num) 

gen perc_cell_with_subsc = (Subscription / Tot ) * 100

la var Subscription "Percent with subscriptions" 

 global label     ylabel(0(10)100) 
 
 twoway line perc_cell_with_subsc mdate,  ytitle("Global evolution of subscriptions") ///
 graphregion(color(white)) bgcolor(white) xtitle("") $label  xline(`=tm(2017m4)')
 
 graph export  FigureB2_Evolution_of_subscriptions.png, replace
 
