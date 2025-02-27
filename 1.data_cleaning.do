**Open all the datasets, clean and combine into one***

clear 

*set working directory
cd ""

*this is where the outputs will be saved
global outputdir ""

*Reading in the Health Survey for England and changing some variable names: You need to have saved the datasets with these names, or change the code to match what you've called them.
use HSE2015.dta
rename (SerialA GALFrq Age16g5 Sex complst3 dnoft3 qimd) (ref gam_freq age5 sex mental_disorder alcohol_freq qimd)
save "$outputdir/HSE2015.dta", replace

use HSE2016.dta
rename (SerialA GALFrq Age16g5 Sex complst3 dnoft3 qimd) (ref gam_freq age5 sex mental_disorder alcohol_freq qimd)
save "$outputdir/HSE2016.dta", replace

use HSE2018.dta
rename (Seriala PGSIsc GALFrq age16g5 Sex complst3 dnoft3 qimd) (ref pgsisc gam_freq age5 sex mental_disorder alcohol_freq qimd)
save "$outputdir/HSE2018.dta", replace

*Reading in the Scottish Health Survey and the variable names the same as they are in the health survey for england
use SHES2015.dta
rename (cpserialA GAMFRE Sex DrinkOft SIMD5_SGa NSSEC8 compm3) (ref gam_freq sex alcohol_freq sqimd nssec8 mental_disorder)
save "$outputdir/SHES2015.dta", replace

use SHES2016.dta
rename (cpserialA GAMFRE Sex DrinkOft SIMD16_SGa NSSEC8 compm3) (ref gam_freq sex alcohol_freq sqimd nssec8 mental_disorder)
save "$outputdir/SHES2016.dta", replace

use SHES2017.dta
rename (CPSerialA GAMFRE Sex DrinkOft SIMD16_SGa NSSEC8 compm3) (ref gam_freq sex alcohol_freq sqimd nssec8 mental_disorder)
save "$outputdir/SHES2017.dta", replace

*use the  HSE and SHeS which have been saved above with the correct variable names
cd ""
*Health Survey for England 2015, 2016, 2018- changing qimd to an imd measure which specifies that the imd is England specific
local years 2018 2016 2015

foreach year in `years' {
    use "HSE`year'.dta", clear
    keep ref pgsisc gam_freq age5 sex mental_disorder alcohol_freq nssec8 qimd GALA GALB GALC GALE GALD GALF GALG GALS GALH GALJ GALT GALU GALK GALLX GALM GALN GALO GALP GALQ
	gen country = "england"
	gen imd = ""
	replace imd = "1_eng" if qimd == 1
	replace imd = "2_eng" if qimd == 2
	replace imd = "3_eng" if qimd == 3
	replace imd = "4_eng" if qimd == 4
	replace imd = "5_eng" if qimd == 5
	drop qimd
    save "HSE`year'.dta", replace
}

*Scottish health survey 2015, 2016, 2017- changing qimd to an imd measure which specifies that the imd is Scotland specific. Also creating age groups to match the age groups in the HSE
local years 2018 2016 2015
local years 2015 2016 2017
 foreach year in `years' {
    use "SHES`year'.dta", clear
    keep ref pgsi gam_freq age sex mental_disorder alcohol_freq nssec8 sqimd GALA GALB GALC GALE GALD GALF GALG GALS GALH GALJ GALT GALU GALK GALLX GALM GALN GALO GALP GALQ
	gen country = "Scotland"
	gen age5 = .
    replace age5 = 1 if age==16 | age==17
    replace age5 = 2 if age==18 | age==19
    replace age5 = 3 if age>=20 & age<=24
    replace age5 = 4 if age>=25 & age<=29
    replace age5 = 5 if age>=30 & age<=34
    replace age5 = 6 if age>=35 & age<=39
    replace age5 = 7 if age>=40 & age<=44
    replace age5 = 8 if age>=45 & age<=49
    replace age5 = 9 if age>=50 & age<=54
    replace age5 = 10 if age>=55 & age<=59
    replace age5 = 11 if age>=60 & age<=64
    replace age5 = 12 if age>=65 & age<=69
    replace age5 = 13 if age>=70 & age<=74
    replace age5 = 14 if age>=75 & age<=79
    replace age5 = 15 if age>=80 & age<=84
    replace age5 = 16 if age>=85 & age<=89
    replace age5 = 17 if age>89
	drop age
	gen imd = ""
	replace imd = "1_scot" if sqimd == 1
	replace imd = "2_scot" if sqimd == 2
	replace imd = "3_scot" if sqimd == 3
	replace imd = "4_scot" if sqimd == 4
	replace imd = "5_scot" if sqimd == 5
	drop sqimd
	save "SHES`year'.dta", replace
}

*combine all the HSE and SHeS datasets togther
 use HSE2018.dta
 append using HSE2016.dta
 append using HSE2015.dta
 append using SHES2015.dta
 append using SHES2016.dta
 append using SHES2017.dta
 save combined_data.dta, replace
 use combined_data.dta
 describe //initial sample size 51, 667


*counting and removing children from sample as these will not have been asked the gambling questions
count if missing(age5) 
drop if missing(age5) //removes those under age 16
 
*count the number of people where gambling frequency is -1 (england) or -2/-6 (scotland) which is not applicable/not obtained- assume these people were not asked the gambling questions 
count if gam_freq== -1 | gam_freq ==-2 | gam_freq == -6

*remove these from the sample as these were not asked the gambling questions (none has -6 so not removed)
drop if gam_freq== -1 | gam_freq ==-2 //sample size down to 19, 727 after removing people who were not asked the questions 

*need to check the logic on the gambling questions, if all the questions before were answered no, then they should not have answered the gambling frequency question. 
* Step 1: Drop observations where all GAL* variables are 2
drop if GALA == 2 & GALB == 2 & GALC == 2 & GALE == 2 & GALD == 2 & GALF == 2 & GALG == 2 & GALS == 2 & GALH == 2 & GALJ == 2 & GALT == 2 & GALU == 2 & GALK == 2 & GALLX == 2 & GALM == 2 & GALN == 2 & GALO == 2 & GALP == 2 & GALQ == 2
*none were removed

 *change numbers which represent NAs to missing
ds, has(type numeric)
local numvars `r(varlist)'
foreach var of varlist `numvars' {
    replace `var' = . if `var' == -6 | `var' == -2 | `var' == -1 | `var' == -8 | `var' == -9
}

count if age5 == 1 //removes those under 18- legal gambling age
drop if age5 == 1 //sample size down to 19,526

drop if missing(pgsisc) //sample size down to 17, 901

 *rename gambling variables so they're easier to interpret
 rename GALA nat_lottery
 rename GALB scratchcard
 rename GALC other_lottery
 rename GALE football_pools
 rename GALD land_bingo
 rename GALF slots
 rename GALG virtual_gaming
 rename GALS table_games
 rename GALH poker_tournament
 rename GALJ online_gambling
 rename GALT online_betting
 rename GALU betting_exchange
 rename GALK horse_racing
 rename GALLX dog_racing
 rename GALM sports_events
 rename GALO spread_betting
 rename GALP private
 rename GALQ other_forms
 rename GALN other_events
 
*need imd to be categorical not string- needed for models 
encode imd, generate(qimd)
drop imd

*creating PGSI categories based on PGSI score 
generate pgsi_cat = .
replace pgsi_cat = 1 if pgsisc ==0
replace pgsi_cat = 2 if pgsisc ==1 | pgsisc ==2 
replace pgsi_cat = 3 if pgsisc >=3 & pgsisc <= 7
replace pgsi_cat = 4 if pgsisc >= 8
replace pgsi_cat =. if missing(pgsisc)

label define pgsi_cat_labels 1 "No Risk" 2 "Low Risk" 3 "Moderate Risk" 4 "High Risk"
label values pgsi_cat pgsi_cat_labels

generate gam_freq_or = .
replace gam_freq_or = 6 if gam_freq == 1
replace gam_freq_or = 5 if gam_freq == 2
replace gam_freq_or = 4 if gam_freq == 3
replace gam_freq_or = 3 if gam_freq == 4
replace gam_freq_or = 2 if gam_freq == 5
replace gam_freq_or = 1 if gam_freq == 6
replace gam_freq_or =. if missing(gam_freq)

label define gam_freq_or_labels 1 "Once or twice a year" 2 "Every 2-3 months" 3 "Once a month" 4 "Less than once a week, more than once a month" 5 "Once a week" 6 "2 or more times a week"
label values gam_freq_or gam_freq_or_labels

*creating new variable to indicate whether someone only gambles on the lottery, either national lottery or other lotteries 
generate only_lottery = "" 
replace only_lottery = "yes" if (scratchcard ==2 & football_pools ==2 & land_bingo ==2 & slots ==2 & virtual_gaming==2 & table_games==2 & poker_tournament==2 & online_gambling==2 & online_betting ==2 & betting_exchange==2 & horse_racing==2 & dog_racing==2 & sports_events==2 & spread_betting ==2 & private ==2 & other_forms ==2 ) & (nat_lottery ==1 | other_lottery ==1)

*letting only_lottery to no if only_lottery is missing and they do have values for the gambling questions
replace only_lottery = "no" if only_lottery == "" & ///
    !missing(scratchcard, football_pools, land_bingo, slots, virtual_gaming, table_games, poker_tournament, online_gambling, online_betting, ///
             betting_exchange, horse_racing, dog_racing, sports_events, spread_betting, private, other_forms, nat_lottery, other_lottery)

count if only_lottery== "yes" //6554 people only gamble on the lottery

*no longer need the variables on each gambling activity 
drop scratchcard football_pools land_bingo slots virtual_gaming table_games poker_tournament online_betting online_gambling betting_exchange horse_racing dog_racing sports_events spread_betting private other_forms nat_lottery other_lottery other_events

*creating the continous gambling frequency variables- number of days per 12 months 
*METHOD 1, see paper for details. This selects a random number within the range of the category and assumed a uniform distribution. Didn't end up using this method. 
set seed 6345
generate gam_freq_c1 = .
replace gam_freq_c1 = runiformint(1, 2) if gam_freq == 6
replace gam_freq_c1 = runiformint(4, 6) if gam_freq == 5
replace gam_freq_c1 = 12 if gam_freq == 4
replace gam_freq_c1 = runiformint(13, 51) if gam_freq == 3
replace gam_freq_c1 = 52 if gam_freq == 2
replace gam_freq_c1 = runiformint(104, 365) if gam_freq == 1

tabulate gam_freq_c1
 
*METHOD 2, see paper for details. This uses the midpoint from each category as is typical in alcohol research (see paper for reference) 
generate gam_freq_c2 = .
replace gam_freq_c2 = 1.5 if gam_freq == 6
replace gam_freq_c2 = 5 if gam_freq == 5
replace gam_freq_c2 = 12 if gam_freq == 4
replace gam_freq_c2 = 32 if gam_freq == 3
replace gam_freq_c2 = 52 if gam_freq == 2
replace gam_freq_c2 = 234.5 if gam_freq == 1

tabulate gam_freq_c2

*Creating new age variable which splits age into 4 categories to ensure a big enough sample in each group
gen age_group =.
replace age_group = 1 if age5 >=2 & age5 <6 //age 18-34
replace age_group = 2 if age5 >=6 & age5 <9 //age 35-49
replace age_group =3 if age5 >=9 & age5 < 12 //age 50-64
replace age_group = 4 if age5 >=12 //65+

label define age_group_labels 1 "Age 18-34" 2 "Age 35-49" 3 "Age 50-64" 4 "Age 65+"
label values age_group age_group_labels

*sorting out missing data 
save combined_data_missing, replace

*look at missing data 
mdesc

//this makes numeric variables so can use misstable patterns
foreach var of varlist * {
    // Generate a variable that is 1 if the original value is not missing, and remains missing if the original value is missing
    gen byte `var'_notmiss = cond(!missing(`var'), 1, .)
}

misstable patterns ref_notmiss sex_notmiss age5_notmiss mental_disorder_notmiss alcohol_freq_notmiss nssec8_notmiss gam_freq_notmiss pgsisc_notmiss country_notmiss qimd_notmiss gam_freq_notmiss  //only looking at variables used in the models

*7% of the data is missing so can do a complete case analysis
egen mcount = rowmiss(sex age5 mental_disorder alcohol_freq nssec8 gam_freq pgsisc country qimd) //only_lottery not included here as not used in the model only in the sensitivity analysis. 

drop if mcount //final sample size down to 16,648

*save the dataset for analysis, this is everyone with complete pgsi score and all predictor variables
save full_combined_clean_data, replace 

*remove people who only play the lottery and those who are missing this variable
count if missing(only_lottery)
drop if missing(only_lottery) //this removes 1230 and reduces sample size to 15,418
count if only_lottery == "yes" 
drop if only_lottery == "yes" //this removes 6, 098 people and reduces sample size to 9,320

*this saves the dataset for the sensitivity analysis
save combined_clean_data_nolottery, replace




