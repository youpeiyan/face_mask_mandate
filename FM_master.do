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

do $mainpath/FM_main_reg.do  // with robustness checks

************************
*** Dynamic Analysis ***
************************

do $mainpath/FM_dynamic.do	 // policy-in-effect counties only

********************
*** POI Analysis ***
********************

do $mainpath/FM_POI.do 

*******************************************************************
*** Spillover effect from the neighboring counties for fmm/fmmb ***
*******************************************************************

do $mainpath/FM_spillover.do

******************************************
*** Without fmm policies, just fatigue ***
******************************************
do $mainpath/FM_fatigue.do
 

