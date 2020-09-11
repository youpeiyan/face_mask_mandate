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

****************************
*** Main Policy Analysis ***
****************************

** Only the policy-in-effect counties
foreach lhs in y logy {
eststo clear
foreach fatigue in lday_sip lday_cnb {


 foreach day in fmm fmmb {
 eststo: qui reghdfe `lhs' fmm fmmb `fatigue' y_dc sipe $xcase $xncase $xctrl if no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14, absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' fmm fmmb onb `fatigue' y_dc sipe $xcase $xncase $xctrl if no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14, absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' fmm fmmb $xopen `fatigue' y_dc sipe $xcase $xncase $xctrl if no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14, absorb(geoid) cluster(stateid) 
 }

}
esttab using $respath/main_`lhs'.csv, replace se r2 drop(_cons $xctrl)
}

** Use the mean date of the state-level mask policy for +/-14-day period for no-policy counties in the state. If the whole state has no policy, use the national mean date
sort stateid
by stateid: egen mean_fmm_cs = mean(fmm_cs) 
egen mean_fmm_cs2 = mean(fmm_cs) 
replace mean_fmm_cs = mean_fmm_cs2 if mean_fmm_cs == .
egen mean_fmmb_cs = mean(fmmb_cs) 

foreach day in fmm fmmb {
gen min_meandate_`day' = int(mean_`day'_cs) - 14
gen max_meandate_`day' = int(mean_`day'_cs) + 14
}

foreach lhs in y logy {
eststo clear
foreach fatigue in lday_sip lday_cnb {


 foreach day in fmm fmmb {
 eststo: qui reghdfe `lhs' fmm fmmb `fatigue' y_dc sipe $xcase $xncase $xctrl if (no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14) | (no_`day' == 1 & date <= max_meandate_`day' & date >= min_meandate_`day'), absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' fmm fmmb onb `fatigue' y_dc sipe $xcase $xncase $xctrl if (no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14) | (no_`day' == 1 & date <= max_meandate_`day' & date >= min_meandate_`day'), absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' fmm fmmb $xopen `fatigue' y_dc sipe $xcase $xncase $xctrl if (no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14) | (no_`day' == 1 & date <= max_meandate_`day' & date >= min_meandate_`day'), absorb(geoid) cluster(stateid) 
 }

}
esttab using $respath/main_`lhs'_mean.csv, replace se r2 drop(_cons $xctrl)
}


** Use the earliest date of the state-level mask policy for +/-14-day period for no-policy counties in the state
sort stateid
by stateid: egen min_fmm_cs = min(fmm_cs) 
egen min_fmm_cs2 = min(fmm_cs) 
replace min_fmm_cs = min_fmm_cs2 if min_fmm_cs == .
egen min_fmmb_cs = min(fmmb_cs) 

foreach day in fmm fmmb {
gen min_mindate_`day' = int(min_`day'_cs) - 14
gen max_mindate_`day' = int(min_`day'_cs) + 14
}

foreach lhs in y logy {
eststo clear
foreach fatigue in lday_sip lday_cnb {


 foreach day in fmm fmmb {
 eststo: qui reghdfe `lhs' fmm fmmb `fatigue' y_dc sipe $xcase $xncase $xctrl if (no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14) | (no_`day' == 1 & date <= max_mindate_`day' & date >= min_mindate_`day'), absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' fmm fmmb onb `fatigue' y_dc sipe $xcase $xncase $xctrl if (no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14) | (no_`day' == 1 & date <= max_mindate_`day' & date >= min_mindate_`day'), absorb(geoid) cluster(stateid) 
 eststo: qui reghdfe `lhs' fmm fmmb $xopen `fatigue' y_dc sipe $xcase $xncase $xctrl if (no_`day' == 0 & day_`day' <= 14 & day_`day' >= -14) | (no_`day' == 1 & date <= max_mindate_`day' & date >= min_mindate_`day'), absorb(geoid) cluster(stateid) 
 }

}
esttab using $respath/main_`lhs'_min.csv, replace se r2 drop(_cons $xctrl)
}

drop mean_fmm* min_m* max_m* min_fm*
