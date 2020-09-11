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

************************
*** Dynamic Analysis ***
************************

** For policy-in-effect counties only

foreach lhs in y logy {
** fmm
//replace fmm_cs = 22145 if no_fmm == 1
cap drop dpol_*
forval i = 13(-1)2 {
gen dpol_n`i' = (date + `i' == fmm_cs)
}
forval i = 0/14 {
gen dpol_y`i' = (date - `i' == fmm_cs)
}

qui reghdfe `lhs' dpol_* fmmb lday_sip y_dc onb sipe $xcase $xncase $xctrl if no_fmm == 0 & day_fmm >= -14 & day_fmm <= 14, absorb(geoid) cluster(stateid)
estimates store group0
coefplot (group0, keep(dpol_n*) mcolor(navy) ciopts(color(navy))) ///
		 (group0, keep(dpol_y*) mcolor(maroon) ciopts(color(maroon))) ///
		 , keep(dpol_*) yline(0, lp(dash) lc(black)) vertical ///	
		 coeflabels(dpol_n13 = "-13" ///
					dpol_n12 = "-12" ///
					dpol_n11 = "-11" ///
					dpol_n10 = "-10" ///
					dpol_n9 = "-9" ///
					dpol_n8 = "-8" ///
					dpol_n7 = "-7" ///
					dpol_n6 = "-6" ///
					dpol_n5 = "-5" ///
					dpol_n4 = "-4" ///
					dpol_n3 = "-3" ///
					dpol_n2 = "-2" ///
					dpol_y0 = "0" ///
					dpol_y1 = "1" ///
					dpol_y2 = "2" ///
					dpol_y3 = "3" ///
					dpol_y4 = "4" ///
					dpol_y5 = "5" ///
					dpol_y6 = "6" ///
					dpol_y7 = "7" ///
					dpol_y8 = "8" ///
					dpol_y9 = "9" ///
					dpol_y10 = "10" ///
					dpol_y11 = "11" ///
					dpol_y12 = "12" ///
					dpol_y13 = "13" ///
					dpol_y14 = "14") ///
		 xtitle("days before and after the mask mandates (for public)") ytitle("public mask policy effects (stay home time in min)") xlabel(, labsize(small)) legend(off) nooffsets graphregion(color(white)) bgcolor(white) 
graph export $mainpath/figure/dyn_fmm_`lhs'.png, replace 

** fmmb
drop dpol_*
forval i = 13(-1)2 {
gen dpol_n`i' = (date + `i' == fmmb_cs)
}
forval i = 0/14 {
gen dpol_y`i' = (date - `i' == fmmb_cs)
}

qui reghdfe `lhs' dpol_* fmm lday_sip y_dc onb sipe $xcase $xncase $xctrl if no_fmmb == 0 & day_fmmb >= -14 & day_fmmb <= 14, absorb(geoid) cluster(stateid)
estimates store group0
coefplot (group0, keep(dpol_n*) mcolor(navy) ciopts(color(navy))) ///
		 (group0, keep(dpol_y*) mcolor(maroon) ciopts(color(maroon))) ///
		 , keep(dpol_*) yline(0, lp(dash) lc(black)) vertical ///	
		 coeflabels(dpol_n13 = "-13" ///
					dpol_n12 = "-12" ///
					dpol_n11 = "-11" ///
					dpol_n10 = "-10" ///
					dpol_n9 = "-9" ///
					dpol_n8 = "-8" ///
					dpol_n7 = "-7" ///
					dpol_n6 = "-6" ///
					dpol_n5 = "-5" ///
					dpol_n4 = "-4" ///
					dpol_n3 = "-3" ///
					dpol_n2 = "-2" ///
					dpol_y0 = "0" ///
					dpol_y1 = "1" ///
					dpol_y2 = "2" ///
					dpol_y3 = "3" ///
					dpol_y4 = "4" ///
					dpol_y5 = "5" ///
					dpol_y6 = "6" ///
					dpol_y7 = "7" ///
					dpol_y8 = "8" ///
					dpol_y9 = "9" ///
					dpol_y10 = "10" ///
					dpol_y11 = "11" ///
					dpol_y12 = "12" ///
					dpol_y13 = "13" ///
					dpol_y14 = "14") ///
		 xtitle("days before and after the mask mandates (for business)") ytitle("business mask policy effects (stay home time in min)") xlabel(, labsize(small)) legend(off) nooffsets graphregion(color(white)) bgcolor(white) 
graph export $mainpath/figure/dyn_fmmb_`lhs'.png, replace 
}
