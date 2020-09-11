set more off
clear

global mainpath "/Users/youpei/Downloads/Yale/COVID19_FM"

global savepath "$mainpath/processed_data"
global respath "$mainpath/results"

use "$savepath/FM_data_final.dta", clear

global xcase lcc lcs lcn 
global xncase lncc lncs lncn
global xctrl precip rmax rmin srad tmin tmax wind_speed week_* memorial indep
global xopen odc ort ogy omt obr ohb org onr onb

*******************************************************************
*** Spillover effect from the neighboring counties for fmm/fmmb ***
*******************************************************************

gen keep = 1
merge m:1 geoid using "$savepath/neighbor_fm.dta", nogen
keep if keep == 1


foreach fm in fmm fmmb {
gen no_n`fm' = (n`fm'_cs == .)
gen n`fm' = (date >= n`fm'_cs)
gen day_n`fm' = date - n`fm'_cs
}

eststo clear
foreach fm in fmm fmmb {
foreach lhs in y logy {
 eststo: qui reghdfe `lhs' nfmm nfmmb lday_sip y_dc sipe onb $xcase $xncase $xctrl if no_`fm' == 1 & no_n`fm' == 0 & day_n`fm' <= 14 & day_n`fm' >= -14, absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' nfmm nfmmb lday_sip y_dc sipe $xopen $xcase $xncase $xctrl if no_`fm' == 1 & no_n`fm' == 0 & day_n`fm' <= 14 & day_n`fm' >= -14, absorb(geoid) cluster(stateid) 
}
}
esttab using $respath/spillover.csv, replace se r2 drop(_cons $xctrl)

*****************************************************************************
*** Replacing neighboring policy to state-average/earliest policy for fmm ***
*****************************************************************************

sort stateid
by stateid: egen mean_fmm_cs = mean(fmm_cs) 
by stateid: egen min_fmm_cs = min(fmm_cs) 

gen no_mean_fmm = (mean_fmm_cs == .)
gen mean_fmm = (date >= mean_fmm_cs)
gen day_mean_fmm = date - mean_fmm_cs

gen no_min_fmm = (min_fmm_cs == .)
gen min_fmm = (date >= min_fmm_cs)
gen day_min_fmm = date - min_fmm_cs

eststo clear
foreach lhs in y logy {
foreach method in mean min {
 eststo: qui reghdfe `lhs' `method'_fmm fmmb lday_sip y_dc sipe onb $xcase $xncase $xctrl if no_fmm == 1 & no_`method'_fmm == 0 & day_`method'_fmm <= 14 & day_`method'_fmm >= -14, absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' `method'_fmm fmmb lday_sip y_dc sipe $xopen $xcase $xncase $xctrl if no_fmm == 1 & no_`method'_fmm == 0 & day_`method'_fmm <= 14 & day_`method'_fmm >= -14, absorb(geoid) cluster(stateid) 
}
}
esttab using $respath/spillover2.csv, replace se r2 drop(_cons $xctrl)
