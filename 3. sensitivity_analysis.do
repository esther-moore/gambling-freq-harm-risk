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

esttab mlogit_categorical_nolott ///
    using "Tables/TableS6.rtf", replace ///
    eform label wide se stats(r2_p) ///
    mtitles("Categorical Model")

//////////////////////////////////PGSI SCORE////////////////////////////////////

*gambling frequecy as categorical variable
zinb pgsisc i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd, inflate(i.gam_freq_or i.age_group i.sex i.nssec8 i.alcohol_freq i.mental_disorder i.qimd) irr
est sto zinb_cat_nolot

esttab zinb_cat_nolot ///
    using "Tables/TableS7.rtf", replace ///
    eform label wide se ///
    mtitles("Categorical Model")

