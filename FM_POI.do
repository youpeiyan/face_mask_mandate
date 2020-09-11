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

gen lpoidc = log(poi_dc)
********************
*** POI Analysis ***
********************

** Only the policy-in-effect counties

foreach day in fmm fmmb {
eststo clear
foreach ind in 7225 7139 4471 4522 7121 4511 4451 ///
			   4461 4481 4539 4533 4532 4421 4483 ///
			   4531 4431 4482 7132 4512 7224 {
 eststo: qui reghdfe v`ind' fmm fmmb onb lpoidc sipe lday_sip $xcase $xncase $xctrl if day_`day' <= 14 & day_`day' >= -14, absorb(geoid) cluster(stateid)
}
esttab using $respath/POI_`day'.csv, replace se r2 drop(_cons $xctrl)
esttab using $respath/POI_`day'_bonf.csv, replace se star(* 0.0025 ** 0.0005 *** 0.00005) r2 drop(_cons $xctrl) // this is for the bonferroni corrected results under 20 hypotheses. 
}


eststo clear
foreach ind in 7225 7139 4471 4522 7121 4511 4451 ///
			   4461 4481 4539 4533 4532 4421 4483 ///
			   4531 4431 4482 7132 4512 7224 {
rename fmm fmm_`ind'
 eststo: qui reghdfe v`ind' fmm_`ind' fmmb onb lpoidc sipe lday_sip $xcase $xncase $xctrl if day_fmm <= 14 & day_fmm >= -14, absorb(geoid) cluster(stateid)
rename fmm_`ind' fmm
}
coefplot (est1) (est2) (est3)(est4) (est5) (est6)(est7) (est8) ///
		 (est9)(est10) (est11) (est12) (est13) (est14) (est15)(est16) ///
		 (est17)(est18)(est19)(est20), keep(fmm_*) xline(0) msymbol(o) msize(small) mcolor(white) levels(99.75 95) ///
		ciopts(lwidth(1 1) lcolor(gs12 gs7)) legend(off)  ///
		coeflabels(fmm_7225 = "Restaurants & other eating places" ///
				   fmm_7139 = "Other amusement & recreation industries" ///
				   fmm_4471 = "Gasoline stations" ///
				   fmm_4522 = "Department stores" ///
				   fmm_7121 = "Museums, historical sites, & similar" ///
				   fmm_4511 = "Sporting goods, hobby, & musical instrument stores" ///
				   fmm_4451 = "Grocery stores" ///
				   fmm_4461 = "Health & personal care stores" ///
				   fmm_4481 = "Clothing stores" ///
				   fmm_4539 = "Other miscellaneous store retailers" ///
				   fmm_4533 = "Used merchandise stores" ///
				   fmm_4532 = "Office supplies, stationery, & gift stores" ///
				   fmm_4421 = "Furniture stores" ///
				   fmm_4483 = "Jewelry, luggage, & leather goods stores" ///
				   fmm_4531 = "Florists" ///
				   fmm_4431 = "Electronics & appliance stores" ///
				   fmm_4482 = "Shoe stores" ///
				   fmm_7132 = "Gambling industries" ///
				   fmm_4512 = "Book stores & news dealers" ///
				   fmm_7224 = "Drinking places (alcoholic beverages)",wrap(36)) ///
		xtitle("increased visit times after the mask mandate (public)") ylabel(, labsize(small)) nooffsets graphregion(color(white)) bgcolor(white) 
graph export $mainpath/figure/POI_fmm.png, replace
		


eststo clear
foreach ind in 7225 7139 4471 4522 7121 4511 4451 ///
			   4461 4481 4539 4533 4532 4421 4483 ///
			   4531 4431 4482 7132 4512 7224 {
rename fmmb fmm_`ind'
 eststo: qui reghdfe v`ind' fmm fmm_`ind' onb lpoidc sipe lday_sip $xcase $xncase $xctrl if day_fmmb <= 14 & day_fmmb >= -14, absorb(geoid) cluster(stateid)
rename fmm_`ind' fmmb
}

coefplot (est1) (est2) (est3)(est4) (est5) (est6)(est7) (est8) ///
		 (est9)(est10) (est11) (est12) (est13) (est14) (est15)(est16) ///
		 (est17)(est18)(est19)(est20), keep(fmm_*) xline(0) msymbol(o) msize(small) mcolor(white) levels(99.75 95) ///
		ciopts(lwidth(1 1) lcolor(gs12 gs7)) legend(off)  ///
		coeflabels(fmm_7225 = "Restaurants & other eating places" ///
				   fmm_7139 = "Other amusement & recreation industries" ///
				   fmm_4471 = "Gasoline stations" ///
				   fmm_4522 = "Department stores" ///
				   fmm_7121 = "Museums, historical sites, & similar" ///
				   fmm_4511 = "Sporting goods, hobby, & musical instrument stores" ///
				   fmm_4451 = "Grocery stores" ///
				   fmm_4461 = "Health & personal care stores" ///
				   fmm_4481 = "Clothing stores" ///
				   fmm_4539 = "Other miscellaneous store retailers" ///
				   fmm_4533 = "Used merchandise stores" ///
				   fmm_4532 = "Office supplies, stationery, & gift stores" ///
				   fmm_4421 = "Furniture stores" ///
				   fmm_4483 = "Jewelry, luggage, & leather goods stores" ///
				   fmm_4531 = "Florists" ///
				   fmm_4431 = "Electronics & appliance stores" ///
				   fmm_4482 = "Shoe stores" ///
				   fmm_7132 = "Gambling industries" ///
				   fmm_4512 = "Book stores & news dealers" ///
				   fmm_7224 = "Drinking places (alcoholic beverages)",wrap(36)) ///
		xtitle("increased visit times after the mask mandate (business)") ylabel(, labsize(small)) nooffsets graphregion(color(white)) bgcolor(white) 
graph export $mainpath/figure/POI_fmmb.png, replace
