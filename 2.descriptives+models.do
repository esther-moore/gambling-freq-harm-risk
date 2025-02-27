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


//MODEL 2
*MULTINOMIAL LOGIT MODEL with gambling frequency continuous method 2
mlogit pgsi_cat gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, rrr
est sto mologit_continuous2
estimates save "Models/mlogit_continuous2", replace


*This is the first table for the results in the paper
esttab mlogit_categorical mologit_continuous2 ///
    using "Tables/Table4.rtf", replace ///
    eform label wide se stats(r2_p) ///
    mtitles("Categorical Model" "Continuous Model")
	
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

*ZERO INFLATED NEGATIV BINOMIAL MODEL with gambling frequency continous method 1 
zinb pgsisc gam_freq_c1 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_c1 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_continuous1
//margins, at (gam_freq_c1=(1(1)365))
//marginsplot

*ZERO INFLATED NEGATIV BINOMIAL MODEL with gambling frequency continous method 2
zinb pgsisc gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_continuous2
estimates save "Models/zinb_continuous2", replace

est table zinb_continuous1 zinb_continuous2, stats(r2 aic bic) //method 2 is lower

esttab zinb_continuous1 zinb_continuous2 ///
    using "Tables/zinb_comparison_of_methods.rft", ///
    replace ///
    stats(r2 aic bic) ///
    title("zinb_Comparing method 1 and method 2 of the continuous gambling frequency variable") ///
    label 

*Table 5 in paper
esttab zinb_categorical zinb_continuous2 ///
    using "Tables/Table5.rtf", replace ///
    eform label wide se ///
    mtitles("Categorical Model" "Continuous Model")	
	
//MODELS WITH REDUCED COVARIATES 
clear 

cd ""

use "full_combined_clean_data.dta"

//MODEL 1B
//removed alcohol frequency, nssec and mental health from the models
mlogit pgsi_cat i.gam_freq_or i.age_group i.sex i.qimd, rrr
est sto reduced_mlogit_categorical

//MODEL 2B
//removed alcohol frequency, nssec and mental health from the models
mlogit pgsi_cat gam_freq_c2 i.age_group i.sex i.qimd, rrr
est sto reduced_mlogit_continuous2

*Table 3 supplementary table
esttab reduced_mlogit_categorical reduced_mlogit_continuous2 ///
    using "Tables/TableABT1.rtf", replace ///
    eform label wide se ///
    mtitles("Reduced Categorical Model" "Reduced Continuous Model")

//MODEL 3B
//removed alcohol frequency, nssec and mental health from the models
zinb pgsisc i.gam_freq_or i.age_group i.sex i.qimd, inflate(i.gam_freq_or i.age_group i.sex i.qimd) irr
est sto reduced_zinb_categorical

//MODEL 4B	
//removed alcohol frequency, nssec and mental health from the models
zinb pgsisc gam_freq_c2 i.age_group i.sex i.qimd, inflate(gam_freq_c2 i.age_group i.sex i.qimd) irr	
est sto reduced_zinb_continuous2

*Table 4 supplementary table
esttab reduced_zinb_categorical reduced_zinb_continuous2 ///
    using "Tables/TableABT2.rtf", replace ///
    eform label wide se ///
    mtitles("Reduced Categorical Model" "Reduced Continuous Model")


	
	
