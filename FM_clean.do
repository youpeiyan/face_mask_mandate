set more off
clear

global mainpath "/Users/youpei/Downloads/Yale/COVID19_FM"


global path "$mainpath/raw_data"
global savepath "$mainpath/processed_data"

use "$savepath/FM_data.dta", clear


******************************************	 
** generate log terms of cases & deaths **
******************************************	

** generate newly cases and deaths at the county, state, and national level
xtset geoid date
gen ncc = d.cc
gen ncs = d.cs
gen ncn = d.cn	 

gen ndc = d.dc
gen nds = d.ds
gen ndn = d.dn	

** since some are negative, we create a dummy to represent the negativity of them.
foreach var in ncc ncs ndc nds  {
gen l`var'_ng = (`var' < 0)
replace `var' = 0 if `var' < 0
}
	 
foreach case in cc dc cs ds cn dn ///
				ncc ndc ncs nds ncn ndn {
gen l`case' = log(`case' + 1)			
}

*****************************************
** generate log terms of dwelling time **
*****************************************
gen logy = log(y+1)
gen logny = log(ny+1)

**************************************************************
** generate policy dummies and days since the policy issued **
**************************************************************
rename fmmb_s fmmb_cs
rename sipe_s sipe_cs
foreach order in soe sip sipe cks cnb fmm fmmb {
gen no_`order' = (`order'_cs == .)
gen `order' = (date >= `order'_cs)
gen day_`order' = date - `order'_cs
}

foreach order in soe sip sipe cks cnb {
replace day_`order' = 0 if day_`order' < 0 | no_`order' == 1
gen lday_`order' = log(day_`order' + 1)
}

** Note: day_`order' == . if no_`order' == 1

**************************************************************************
** generate days since the first case at the county and the state level ** // later can be used to create epidemic day's daily fixed effects
**************************************************************************
gen epiday_c = (date - cc1 + 1)
gen epiday_s = (date - cs1 + 1)

****************************
** generate weekday dummy **
****************************
gen weekday = dow(date)
qui tabulate weekday, generate(week_)
drop weekday week_7

************************************
** drop obs. without weather data **
************************************
global weather precip rmax rmin srad tmin tmax wind_speed
drop if precip == .

***********************
** generate holidays **
***********************

gen memorial = (date == 22060 | date == 22059 | date == 22058)
gen indep = (date == 22099 | date == 22100 | date == 22101)

*************************
*** Data Modification ***
*************************
drop if y <=225 // drop the bottom 1% in case of data error
// xtile dbin=y_dc, nq(50)
//replace epiday_s = 0 if epiday_s < 0
//replace epiday_c = 0 if epiday_c < 0


***************************
*** Re-opening Policies ***
***************************
foreach order in odc onb ort ogy omt obr ohb org onr {
gen `order' = (date >= `order'_s)
}

save "$savepath/FM_data_final.dta", replace

