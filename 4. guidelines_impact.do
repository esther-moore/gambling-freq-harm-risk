//This will use the saved models to make predictions about the impact of the population sticking to the lower-risk gambling guidelines
clear
//set CD to the file that the models have been saved in
cd ""

use "full_combined_clean_data.dta"

//only look at people who will be impacted by the guidelines

keep if gam_freq_or == 6

dtable i.pgsi_cat, export(Tables/sample_pgsi_cat.docx)

//Firsly use the saved models to predict the probabilities 
//1.Using mlogit with gambling frequency as categorical
*predict probability of being in each category based on original gambling frequency
estimates use "Models/mlogit_categorical"
predict prob_1 prob_2 prob_3 prob_4

//Convert the probabilities to integers which add up to 100 for each person
gen count_1 = prob_1*100
gen count_2 = prob_2*100
gen count_3 = prob_3*100
gen count_4 = prob_4*100

recast int count_1, force
recast int count_2, force
recast int count_3, force
recast int count_4, force

gen count_total = count_1 + count_2 + count_3 + count_4
sum count_total

replace count_1 = count_1 + 1 if count_total < 100
replace count_2 = count_2 + 1 if count_total < 99
replace count_3 = count_3 + 1 if count_total < 98

gen count_totalb = count_1 + count_2 + count_3 + count_4
sum count_totalb
assert r(mean) == 100

//reshape the data
reshape long count_, i(ref age_group sex gam_freq_or qimd) j(category)

//expand the dataset so each row is multiplied by the probability indicated by the count_ variables
expand count_

//Look at the percetnage of people who are each PGSI category by looking at the category variable. 
tab category

dtable i.category, export(Tables/mlogit_cat_before_guide.docx)

//repeat for the reduced frequency 
clear
use "full_combined_clean_data.dta"

//only look at people who will be impacted by the guidelines

keep if gam_freq_or == 6

*change gambling frequency value in the dataset so everyone adheres to the guidelines (no more than once a week or 4 times a month)
replace gam_freq_or = 5 if gam_freq_or ==6

*now predict the probabilities again using the same model
estimates use "Models/mlogit_categorical"
predict guide_prob_1 guide_prob_2 guide_prob_3 guide_prob_4

//Convert the probabilities to integers which add up to 100 for each person
gen count_guide_1 = guide_prob_1*100
gen count_guide_2 = guide_prob_2*100
gen count_guide_3 = guide_prob_3*100
gen count_guide_4 = guide_prob_4*100

recast int count_guide_1, force
recast int count_guide_2, force
recast int count_guide_3, force
recast int count_guide_4, force

gen count_total_guide = count_guide_1 + count_guide_2 + count_guide_3 + count_guide_4
sum count_total_guide

replace count_guide_1 = count_guide_1 + 1 if count_total_guide < 100
replace count_guide_2 = count_guide_2 + 1 if count_total_guide < 99
replace count_guide_3 = count_guide_3 + 1 if count_total_guide < 98

gen count_total_guideb = count_guide_1 + count_guide_2 + count_guide_3 + count_guide_4
sum count_total_guideb
assert r(mean) == 100

//reshape the data
reshape long count_guide_, i(ref age_group sex gam_freq_or qimd) j(category_guide)

//expand the dataset so each row is multiplied by the probability indicated by the count_ variables
expand count_guide_

//Look at the percetnage of people who are each PGSI category by looking at the category variable. 
tab category_guide

dtable i.category_guide, export(Tables/mlogit_cat_after_guide.docx)

*plot the means of the probabilities before and after applying the guidelines

//reshape long prob_ guide_prob_, i(ref) j(category)
//keep ref category prob_ guide_prob_
//graph bar (mean) prob_ guide_prob_, over(category) blabel(total) title("Gambling frequency Categorical")
//graph export probs_categorical_comparision_affected.png, replace

//2. Using mlogit with gambling frequency as continuous (method 2)
clear
//set CD to the file that the models have been saved in
cd ""
use "full_combined_clean_data.dta"

keep if gam_freq_c2 >52

*predict probability of being in each category based on original gambling frequency
estimate use "Models/mlogit_continuous2"
predict prob_1 prob_2 prob_3 prob_4

//Convert the probabilities to integers which add up to 100 for each person
gen count_1 = prob_1*100
gen count_2 = prob_2*100
gen count_3 = prob_3*100
gen count_4 = prob_4*100

recast int count_1, force
recast int count_2, force
recast int count_3, force
recast int count_4, force

gen count_total = count_1 + count_2 + count_3 + count_4
sum count_total

replace count_1 = count_1 + 1 if count_total < 100
replace count_2 = count_2 + 1 if count_total < 99
replace count_3 = count_3 + 1 if count_total < 98

gen count_totalb = count_1 + count_2 + count_3 + count_4
sum count_totalb
assert r(mean) == 100

//reshape the data
reshape long count_, i(ref age_group sex gam_freq_or qimd) j(category)

//expand the dataset so each row is multiplied by the probability indicated by the count_ variables
expand count_

//Look at the percetnage of people who are each PGSI category by looking at the category variable. 
tab category
dtable i.category, export(Tables/mlogit_continuous_before_guide.docx)

//Impact of guidelines
clear
use "full_combined_clean_data.dta"

*changing gambling frequency to guidelines
tabulate gam_freq_c2
replace gam_freq_c2 = 52 if gam_freq_c2 >52

estimate use "Models/mlogit_continuous2"
predict guide_prob_1 guide_prob_2 guide_prob_3 guide_prob_4
//Convert the probabilities to integers which add up to 100 for each person
gen count_guide_1 = guide_prob_1*100
gen count_guide_2 = guide_prob_2*100
gen count_guide_3 = guide_prob_3*100
gen count_guide_4 = guide_prob_4*100

recast int count_guide_1, force
recast int count_guide_2, force
recast int count_guide_3, force
recast int count_guide_4, force

gen count_total_guide = count_guide_1 + count_guide_2 + count_guide_3 + count_guide_4
sum count_total_guide

replace count_guide_1 = count_guide_1 + 1 if count_total_guide < 100
replace count_guide_2 = count_guide_2 + 1 if count_total_guide < 99
replace count_guide_3 = count_guide_3 + 1 if count_total_guide < 98

gen count_total_guideb = count_guide_1 + count_guide_2 + count_guide_3 + count_guide_4
sum count_total_guideb
assert r(mean) == 100

//reshape the data
reshape long count_guide_, i(ref age_group sex gam_freq_or qimd) j(category_guide)

//expand the dataset so each row is multiplied by the probability indicated by the count_ variables
expand count_guide_

//Look at the percetnage of people who are each PGSI category by looking at the category variable. 
tab category_guide
dtable i.category_guide, export(Tables/mlogit_continuous_after_guide.docx)

//reshape long prob_ guide_prob_, i(ref) j(category)
//keep ref category prob_ guide_prob_
//graph bar (mean) prob_ guide_prob_, over(category) blabel(total) title("Gambling Frequency Continuous")
//graph export probs_continuous2_comparision_affected.png, replace

//3. Using zero-inflated negative binomial with gambling frequency as categorical
clear
//set CD to the file that the models have been saved in
cd ""
use "full_combined_clean_data.dta"

keep if gam_freq_or == 6

*predict PGSI score
estimate use "Models\zinb_categorical"
predict before_pgsi
mean before_pgsi

*changing gambling frequency to guidelines
replace gam_freq_or = 5 if gam_freq_or ==6
estimate use "Models\zinb_categorical"
predict after_pgsi
mean after_pgsi

ttest before_pgsi == after_pgsi

sort before_pgsi
	   
twoway (histogram before_pgsi, color(blue%50) lcolor(blue)) ///
       (histogram after_pgsi, color(red%50) lcolor(red)) ///
       , legend(label(1 "Predicted PGSI score before guidelines") label(2 "Predicted PGSI score after applying guidelines")) ///
       note("Gambling frequency as a categorical variable") ///
	   yscale(range(0 6)) ylabel(0(1)6) xtitle("PGSI score")

graph save "Graph" "add file path", replace

//4. Using zero-inflated negative binomial with gambling frequency as continuous
clear
//set CD to the file that the models have been saved in
cd ""
use "full_combined_clean_data.dta"

keep if gam_freq_c2 > 52

*predict PGSI score
estimate use "Models/zinb_continuous2"
predict before_pgsi
mean before_pgsi

*changing gambling frequency to guidelines
replace gam_freq_c2 = 52 if gam_freq_c2 >52
estimate use "Models/zinb_continuous2"
predict after_pgsi
mean after_pgsi

ttest before_pgsi == after_pgsi

twoway (histogram before_pgsi, color(blue%50) lcolor(blue)) ///
       (histogram after_pgsi, color(red%50) lcolor(red)) ///
       , legend(label(1 "Predicted PGSI score before guidelines") label(2 "Predicted PGSI score after applying guidelines")) ///
       note("Gambling frequency as a continuous variable") ///
       yscale(range(0 6)) ylabel(0(1)6) xtitle("PGSI score")
	   
graph save "Graph" "set file path", replace

cd "set file path to where graphs have been saved"

grc1leg zinb_cat_guide.gph zinb_con_guide.gph
graph export "", replace

