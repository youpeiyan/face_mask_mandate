README

The following data and the code instruction are for the paper:</br>
Yan, Y., Bayham, J., Richter, A. et al. Risk compensation and face mask mandates during the COVID-19 pandemic. Sci Rep 11, 3174 (2021). https://doi.org/10.1038/s41598-021-82574-w


1. We use both public datasets and purchased datasets for this research. The step-by-step data importing and cleaning steps are shown in the files:

**FM_import.do** <br/>
(Data import file.)<br/>
**FM_clean.do** <br/>
(Data cleaning file.)<br/>

The data we use include:

(a) New York Times Case Reports<br/>
https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv<br/>
(b) Safegraph’s dwell time data at the county-level<br/>
(c) Safegraph’s point of interest visits by county<br/>
(d) County-level weather data<br/>
(e)County-level policies <br/>
https://ce.naco.org/?dset=COVID-19&ind=Emergency%20Declaration%20Types<br/>
And<br/>
https://docs.google.com/spreadsheets/d/133Lry-k80-BfdPXhlS0VHsLEUQh5_UutqAt7czZd7ek/edit#gid=0<br/>
(f)School closure data from MCH<br/>
(g)State-level policy<br/>
https://docs.google.com/spreadsheets/d/1zu9qEWI8PsOI_i8nI_S29HDGHlIp2lfVMsGxpQ5tvAQ/edit#gid=973655443<br/>

The cleaned dataset is named “**FM_data_final.dta**”. We only upload the cleaned dataset in google drive used in this study (please contact us for the google drive link). If you are interested in any intermediate datasets:<br/>
(a) the links updated on 9/1/2020 for public datasets.<br/>
(b) contact us for Safegraph datasets’ information.<br/>

2. You can run the master file **FM_master.do**, which includes 5 separate do files in the analysis:

(a) main mask-mandate policy effects for public and business mandates to the dwell time at home. (**FM_main_reg.do**)<br/>
(b) dynamic analysis for the pre/post-policy. (**FM_dynamic.do**)<br/>
(c) mask-mandate policy effects for public and business mandates to the points of interest visitation. (**FM_POI.do**)<br/>
(d) possible spillover effect analysis from the neighboring counties’ mask mandates (**FM_spillover.do**)<br/>
(e) examine of the fatigue from the stay-at-home policy without mask mandate as robustness checks. (**FM_fatigue.do**)<br/>

3. To start, change the mainpath directory to your local folder. In **FM_import.do**, the list of folders will be created under the mainpath for figures and table results.

4. For figures, run **data_plot.R**.

(a) The data-plotting datasets are derived from the original datasets and the regression coefficients. To save your time, please download **plot.zip** to get access to the cleaned datasets directly. <br/>
(b) Please change the *figpath* at the beginning of **data_plot.R** before proceeding. 
