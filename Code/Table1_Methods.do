
*======================================================================*
* Table A1: Total population of forested grid cells, sample size, and 
*corresponding sampling percent by country
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
use "${data}Selected_sample", clear
cd "${outputs}"

sort Tot_obs
order Tot_obs n
fcollapse (mean) Tot_obs (sum) obs, by(continent country)	
replace continent = "South America" if continent == "SouthAmerica"

gen perc_sampled = (obs/Tot_obs) * 100
replace perc_sampled = round(perc_sampled, 0.1)
replace country = "Brazil (out of the Amazon)" in 15
replace Tot_obs = 532400 if country == "Brazil (out of the Amazon)"
replace obs = 53240 if country == "Brazil (out of the Amazon)"
sort Tot_obs

export delimited using "TableA1_Sampling", delimiter("&") replace





