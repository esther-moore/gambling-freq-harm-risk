clear
cd "file path for where you have saved the data set with those who only use lotteries excluded" 

use combined_clean_data_nolottery

dtable i.sex i.age_group i.qimd i.nssec8 i.mental_disorder i.alcohol_freq i.gam_freq gam_freq_c2 pgsisc, by(pgsi_cat, tests) export(Tables/TableACT1.docx) 

////////////////////////////PGSI CATEGORIES///////////////////////////////////
eststo: mlogit pgsi_cat i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, rrr
est sto mlogit_categorical_nolott

//margins gam_freq_or
//marginsplot
//graph export model3_no_lottery.png, replace
eststo: mlogit pgsi_cat gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, rrr
est sto mologit_continuous2_nolott

//margins
//margins, at (gam_freq_c2=(3(1)234.5))
//marginsplot
//graph export model5_no_lottery.png, replace

esttab mlogit_categorical_nolott mologit_continuous2_nolott ///
    using "Tables/TableACT2.rtf", replace ///
    eform label wide se stats(r2_p) ///
    mtitles("Categorical Model" "Continuous Model")

//////////////////////////////////PGSI SCORE////////////////////////////////////

*gambling frequecy as categorical variable
zinb pgsisc i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_cat_nolot

*gam frequecy continous method 2 
zinb pgsisc gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(gam_freq_c2 i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_con2_nolot

esttab zinb_cat_nolot zinb_con2_nolot ///
    using "Tables/TableACT3.rtf", replace ///
    eform label wide se ///
    mtitles("Categorical Model" "Continuous Model")

