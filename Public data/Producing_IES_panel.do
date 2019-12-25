use "C:\Users\Gilad Gaibel\Desktop\Thesis\Public data\locality_IES.dta", clear
merge m:1 code using "C:\Users\Gilad Gaibel\Desktop\Thesis\Travel_Subsidies\DATA\Data\localities_inf.dta"
keep if _merge==3

save "C:\Users\Gilad Gaibel\Desktop\Thesis\Public data\locality_IES_merged.dta", replace

use "C:\Users\Gilad Gaibel\Desktop\Thesis\Travel_Subsidies\DATA\Data\localities_inf.dta", clear
keep if munic_code != ""
joinby munic_code using "C:\Users\Gilad Gaibel\Desktop\Thesis\Public data\munic_IES.dta", unmatched(none)

gen t = monthly(month, "YM")
format t %tm
 
sort munic_code code t

gen one = 1
bysort munic_code t: egen N_m_t = count(one)

bysort munic_code t: egen pop_m = total(total_pop_2017)
gen weight = total_pop_2017/pop_m

gen job_seekers_locality = round(job_seekers_munic*weight, 1)
gen unemployment_rate_locality = round(unemployment_rate_munic*weight, 0.0001)
gen work_force_locality = round(work_force_munic*weight, 1)

drop job_seekers_munic unemployment_rate_munic work_force_munic t one N_m_t pop_m weight

append using "C:\Users\Gilad Gaibel\Desktop\Thesis\Public data\locality_IES_merged.dta", generate(a)

gen t = monthly(month, "YM")
format t %tm

sort code t

keep month t code job_seekers_locality unemployment_rate_munic men_jsk_* women_jsk_* unemployment_rate_locality work_force_locality religion total_pop_2017 d_Tel_Aviv d_occ_cities d_occ_loc in_program Avrg_dis_work soc_index_2015 soc_cluster_2015 soc_index soc_cluster soc_index_todate
order month t code job_seekers_locality unemployment_rate_munic men_jsk_* women_jsk_* unemployment_rate_locality work_force_locality

save "C:\Users\Gilad Gaibel\Desktop\Thesis\Public data\locality_IES_merged.dta", replace
