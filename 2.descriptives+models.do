//First models with all controlls 
clear

//set working directory to where the dataset is saved
cd ""

use "full_combined_clean_data.dta"

*frequency tables for all variables 
dtable i.sex i.age_group i.qimd i.nssec8 i.mental_disorder i.alcohol_freq i.gam_freq gam_freq_c2 pgsisc, by(pgsi_cat, tests) export(Tables\Table3.docx) 

////////////////////PGSI CATEGORY AS THE DEPENDENT VARIABLE\\\\\\\\\\\\\\\\\\\\\

*ORDERED LOGISTIC REGRESSION with gambling frequency as categorical

//ologit pgsi_cat gam_freq_or age_group sex nssec8 alcohol_freq mental_disorder qimd
//brant //to test proportional hazards- violates the assumption

//ologit pgsi_cat gam_freq_or age_group sex qimd
//brant //to test proportional hazards- violates the assumption

*repeating the above but using continuous gambling frequency (method 1)
//ologit pgsi_cat gam_freq_c1 age_group sex nssec8 alcohol_freq mental_disorder qimd
//brant //to test proportional hazards- violates the assumption

//ologit pgsi_cat gam_freq_c1 age_group sex qimd
//brant //to test proportional hazards- violates the assumption

*repeating the above but using continuous gambling frequency (method 2)

//ologit pgsi_cat gam_freq_c2 age_group sex nssec8 alcohol_freq mental_disorder qimd
//brant //to test proportional hazards- violates the assumption

//ologit pgsi_cat gam_freq_c2 age_group sex qimd
//brant //to test proportional hazards- violates the assumption

*Since the proportional odds assumption is violated then we used a multinomial logit model instead.
//MODEL 1
*MULTINOMIAL LOGIT MODEL with gambling frequency categorical
mlogit pgsi_cat i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, rrr
est sto mlogit_categorical
estimates save "Models/mlogit_categorical", replace

margins gam_freq_or, predict(outcome(2)) predict(outcome(3)) predict(outcome(4)) 

marginsplot, ///
    xlabel(1 "Once or twice`=char(10)'a year" 2 "Every 2-3`=char(10)'months" 3 "Once a month" ///
           4 "Less than once`=char(10)'a week, more `=char(10)'than once a month" 5 "Once a week" 6 "2 or more time`=char(10)'a week", ///
           labsize(vsmall)) ///
    ylabel(, labsize(vsmall)) ///
    ytitle("Predicted Probability", size(small)) ///
    xtitle("Gambling Frequency", size(small)) ///
    legend(order(1 "PGSI Low-Risk" 2 "PGSI Moderate-Risk" 3 "PGSI High-Risk") size(small)) ///
    title("") ///
    graphregion(margin(zero zero 15 zero))
	
*This is the first table for the results in the paper
esttab mlogit_categorical ///
    using "Tables/Table4.rtf", replace ///
    eform label wide se stats(r2_p) ///
    mtitles("Categorical Model")

//Continuous variable - results on OSF
*MULTINOMIAL LOGIT MODEL with gambling frequency continuous method 1 
mlogit pgsi_cat gam_freq_c1 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, rrr
est sto mologit_continuous1

*MULTINOMIAL LOGIT MODEL with gambling frequency continuous method 2
mlogit pgsi_cat gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, rrr
est sto mologit_continuous2
estimates save "Models/mlogit_continuous2", replace

//Model for OSF continuous method 1 and 2
esttab mologit_continuous1 mologit_continuous2 ///
    using "Tables/OSF_table1_95.rtf", replace ///
    eform label wide ci stats(N r2_p) ///
    mtitles("Continuous Model- method 1" "Continuous Model- method 2")
	
///////////////////////PGSI SCORE AS THE DEPENDENT VARIABLE\\\\\\\\\\\\\\\\\\\\\
//poisson pgsisc gam_freq_or age_group sex nssec8 alcohol_freq mental_disorder qimd, vce(robust) //CHECKING POISSON MODEL SHOULD NOT BE USED
//predict muhat, n
//quietly generate ystar= ((pgsisc-muhat)^2-pgsisc)/muhat
//regress ystar muhat, noconstant noheader //this indicates significant overdispersion
//estat gof

//negative binomial vs zero-inflated 
countfit pgsisc i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) nbreg zinb // zero-inflated is recommended.

*remove temporary  variables so can run the same code with the different model
drop NBRMval NBRMobeq NBRMoble NBRMpreq NBRMprle NBRMob_pr NBRMdif NBRMpearson ZINBval ZINBobeq ZINBoble ZINBpreq ZINBprle ZINBob_pr ZINBdif ZINBpearson NBRMabsdif ZINBabsdif

countfit pgsisc gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) nbreg zinb

*ZERO INFLATED NEGATIV BINOMIAL MODEL with gambling frequecy as categorical variable
zinb pgsisc i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_categorical
estimates save "Models/zinb_categorical", replace
//margins
//margins gam_freq_or
//marginsplot

*Table 4 in paper
esttab zinb_categorical ///
    using "Tables/Table5_check.rtf", replace ///
    eform label wide se ///
    mtitles("Categorical Model")	

//Continuous variable - results on OSF

*ZERO INFLATED NEGATIV BINOMIAL MODEL with gambling frequency continous method 1 
zinb pgsisc gam_freq_c1 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_c1 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_continuous1
//margins, at (gam_freq_c1=(1(1)365))
//marginsplot

*ZERO INFLATED NEGATIV BINOMIAL MODEL with gambling frequency continous method 2
zinb pgsisc gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_continuous2

//Table 2 for OSF
esttab zinb_continuous1 zinb_continuous2 ///
    using "Tables/OSF_table2_pvalue.rtf", replace ///
    eform label wide p stats(r2_p) ///
    mtitles("Continuous Model- method 1" "Continuous Model- method 2")	

	
//MODELS WITH REDUCED COVARIATES 
clear 

cd ""

use "full_combined_clean_data.dta"

//MODEL 1B
//removed alcohol frequency, nssec and mental health from the models
mlogit pgsi_cat i.gam_freq_or i.age_group i.sex i.qimd, rrr
est sto reduced_mlogit_categorical


*Table 2 supplementary table
esttab reduced_mlogit_categorical reduced_mlogit_continuous2 ///
    using "Tables/TableS2.rtf", replace ///
    eform label wide se ///
    mtitles("Reduced Categorical Model")

//MODEL 2B
//removed alcohol frequency, nssec and mental health from the models
zinb pgsisc i.gam_freq_or i.age_group i.sex i.qimd, inflate(i.gam_freq_or i.age_group i.sex i.qimd) irr
est sto reduced_zinb_categorical


*Table 3 supplementary table
esttab reduced_zinb_categorical reduced_zinb_continuous2 ///
    using "Tables/TableS3.rtf", replace ///
    eform label wide se ///
    mtitles("Reduced Categorical Model")


	
	
