set more off
clear

global mainpath "/Users/youpei/Downloads/Yale/COVID19_FM"

/*

***************************************************
*** Create a list of folders in the main folder ***
***************************************************

mkdir $mainpath/raw_data
mkdir $mainpath/processed_data
mkdir $mainpath/figures
mkdir $mainpath/results
*/

global path "$mainpath/raw_data"
global savepath "$mainpath/processed_data"


******************************************
*** Import New York Times Case Reports ***
******************************************
import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv", encoding(ISO-8859-1) clear // Note: the data only report cases after the first case occured in a county
gen time = date(date,"YMD")
drop date
rename time date
format date %td
bysort fips: egen first_c_county = min(date)
format first_c_county %td // provide the date of the first case report in a county
rename fips geoid
replace geoid = 36061 if county == "New York City" & state == "New York" & geoid == . 
drop if geoid == .

rename cases case_county
rename deaths death_county
drop county state
save "$savepath/NYT.dta", replace


***********************************
*** Import Weather & Dwell Time ***
***********************************

* Download daily-updated data using data_import.R from google drive.

** Weather Import
import delimited "$path/weather.csv", encoding(ISO-8859-1) clear
rename date time
gen date = date(time, "YMD")
format date %td
rename county geoid
drop time
order date, after(geoid)
xtset geoid date
save "$savepath/weather.dta", replace

** Dwell Time Import
import delimited "$path/all_counties_current.csv", encoding(ISO-8859-1) clear
rename date time
gen date = date(time, "YMD")
format date %td
order date, after(geoid)
rename device_count y_dc
rename median_home_dwell_time y
rename median_non_home_dwell_time ny
keep geoid date y_dc y ny
save "$savepath/dwell_time.dta", replace


***********************
*** Import Policies ***
***********************

** SIP
import excel "$path/sip.xlsx", sheet("Sheet2") clear
rename A state
rename B county
rename C sip
drop D
duplicates drop
sort county state
by county state: egen sip_c2 = min(sip)
drop sip
duplicates drop
format sip_c2 %td
merge 1:1 state county using "$path/county_fips.dta", keep(match) nogen
drop state county
save "$path/county_sip.dta", replace

** County-level Mask Policy (source: https://www.austinlwright.com/covid-research)
import excel "$path/earliestpolicy_08042020.xlsx", sheet("Sheet1") clear
rename A stateid
rename C geoid
gen mask_date = Q
format mask_date %td
keep stateid geoid mask_date
save "$path/fm_policy.dta", replace
export excel using "$path/fm_policy.xls", firstrow(variables) replace

** County SIP & SOE
import delimited "$path/County_Declaration_and_Policies.csv", encoding(ISO-8859-1) clear // We download this policy data from National Association of Counties. (https://ce.naco.org/?dset=COVID-19&ind=Emergency%20Declaration%20Types)
keep fips countyemergencydeclarationdate saferathomepolicydate businessclosurepolicydate county state
rename fips geoid
rename countyemergencydeclarationdate soe_c
rename saferathomepolicydate sip_c
rename businessclosurepolicydate cnb_c
replace soe_c = subinstr(soe_c," 00:00:00","",.)

foreach day in soe_c sip_c cnb_c {
gen t`day' = date(`day',"YMD")
format t`day' %td
drop `day'
rename t`day' `day'
} 

** Merge county policies

merge 1:1 geoid using "$path/county_sip.dta", nogen
gen sip_c0 = sip_c
replace sip_c0 = sip_c2 if sip_c2 < sip_c
format sip_c0 %td
drop sip_c sip_c2
rename sip_c0 sip_c

merge 1:1 geoid using "$path/fm_policy.dta", nogen
rename mask_date fmm_c
drop county state stateid

merge 1:1 geoid using "$path/scs_c.dta", nogen
rename scs_c cks_c
save "$savepath/county_policy.dta", replace

** Raifman // updated source link: https://github.com/USCOVIDpolicy/COVID-19-US-State-Policy-Database/blob/master/COVID-19%20US%20state%20policy%20database%208_20_2020.xlsx
import excel "$path/state_policy.xlsx", sheet("Sheet1") firstrow clear

drop STATE POSTCODE CLNURSHM RELIGEX FMFINE FMCITE FMNOENF FM_END FM_STP ALCOPEN ALCREST ALCDELIV GUNOPEN RSTOUTDR  ///
     QRSOMEST QR_ALLST QR_END EVICINTN EVICENF RNTGP UTILSO MORGFR EVICEND SNAPALLO SNAPEBT SNAPSUSP SNAPTLW ///
     MED1135W ACAENROL PREVTLHL TLHLAUD TLHLMED CHIPLKOT LKOTSUS TESTANY TESTMAR TESTAPR TESTMAY TESTJUN CASEANY ///
	 CASEMAR CASEAPR CASEMAY CASEJUN HOSPANY HOSPMAR HOSPAPR HOSPMAY HOSPJUN DEATHANY DEATHMAR DEATHAPR DEATHMAY DEATHJUN ///
	 TST_AIAN TST2_AIAN HOSPAIAN DTH_AIAN AIANRESN VISITPER VISITATT NOCOPAY NOPAYCOV NOPAYALL YESCOPAY ELECPRCR ENDELECP ///
	 WTPRD WV_WTPRD WV_WKSR UIQUAR UIHIRISK UICLDCR UIEXTND UIMAXAMT UIMAXEXT UIMAXDUR UIMAXCAR LMABRN TLHlBUPR EXTOPFL ///
	 HMDLVOP TLHLCL24 EXCEMORP WVDEAREQ PDSKLV MEDEXP POPDEN18 POP18 SQML HMLS19 UNEMP18 POV18 RISKCOV DEATH18 MH19
rename FIPS stateid
rename STEMERG soe_s
format soe_s %td
rename CLSCHOOL cks_s
rename STAYHOME sip_s
rename END_STHM sipe_s
rename CLDAYCR cdc_s // close day-care
rename OPNCLDCR odc_s //open day-care
rename CLBSNS cnb_s // close business
rename END_BSNS onb_s // open business
rename FM_ALL fmm_s // face mask for public
rename FM_EMP fmmb_s // face mask for business
rename CLREST crt_s //close restaurant
rename ENDREST ort_s // open restaurant
rename CLGYM cgy_s // close gym
rename ENDGYM ogy_s //open gym
rename CLMOVIE cmt_s // close movie theaters
rename END_MOV omt_s // open movie theaters
rename CLOSEBAR cbr_s // close bars
rename END_BRS obr_s // open bars
rename END_HAIR ohb_s // open hair salons & barber shop
rename END_RELG org_s // open religious gathering
rename ENDRETL onr_s // open non-essential retail

rename BCLBAR2 rcbr_s1 // re-close bars 1
rename CLBAR2 rcbr_s2 // re-close bars 2
 gen rcbr_s = rcbr_s1
 replace rcbr_s = rcbr_s2 if rcbr_s1 == -21915 
 drop rcbr_s1 rcbr_s2
 format rcbr_s %td
rename CLMV2 rcmt_s // re-close movie theaters
rename CLGYM2 rcgy_s // re-close gym
rename CLRST2 rcid_s // re-close indoor dining

drop if stateid == .
foreach var of varlist _all {
replace `var' = . if `var' == -21915
}

save "$savepath/state_policy.dta", replace


**********************************
*** Merge All Datasets for Use ***
**********************************

use "$savepath/NYT.dta", clear
merge 1:1 geoid date using "$savepath/dwell_time.dta", nogen
merge 1:1 geoid date using "$savepath/weather.dta", nogen
merge 1:1 geoid date using "$savepath/POI_indv.dta", nogen
merge m:1 geoid using "$savepath/county_policy.dta", nogen

gen stateid = int(geoid/1000)
merge m:1 stateid using "$savepath/state_policy.dta", nogen

rename case_county cc
rename death_county dc
bysort date stateid: egen cs = sum(cc) // create state-level cases and deaths
bysort date stateid: egen ds = sum(dc)
bysort date: egen cn = sum(cc) // create national-level cases and deaths
bysort date: egen dn = sum(dc)

foreach NYT_var in cc dc {
replace `NYT_var' = 0 if `NYT_var' == .
} // This step fills the case and death to 0 before the first reported case

bysort geoid: egen cc1 = mean(first_c_county) // fill the missing first-case report date in each county
format cc1 %td // cc1 is the first case reported in a county
bysort stateid: egen cs1 = min(cc1) // cs1 is the first case reported in a state
format cs1 %td
drop first_c_county

foreach var of varlist v* {
replace `var' = 0 if `var' == .
}

xtset geoid date

** Modify policies to get the earliest dates for each order (due to inconsistency among datasets)
foreach order in soe sip cks cnb fmm {
gen `order'_cs = `order'_s
replace `order'_cs = `order'_c if `order'_c < `order'_s
format `order'_cs %td
}

save "$savepath/FM_data.dta", replace

*************************************************
*** Export Key Dates and County Info for Maps ***
*************************************************

** export
use "$savepath/FM_data.dta", clear
keep geoid soe_cs sip_cs cks_cs cnb_cs fmm_cs sipe_s fmmb_s
duplicates drop
export excel using "$mainpath/figure/data_plot.xlsx", replace firstrow(variables)


******
*** Snapshot face mask wearing information
******

import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/mask-use/mask-use-by-county.csv", clear
rename countyfp geoid
gen index = 0*never + 1*rarely+2*sometimes+3*frequently+4*always
export excel using "/Users/youpei/Downloads/Yale/COVID19_FM/snapshot.xlsx", replace firstrow(variables)
