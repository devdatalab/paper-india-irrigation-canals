/* make NSS migration table */

/* open analysis file */
use $cdata/pc81_canals_working, clear

/* csv for results */
global fn_nssmig $out/nss_mig_results.csv
cap !rm -f $fn_nssmig

/* regressions for table */

/* PANEL A: Migration */

/* 1941 */
reg pl_enum_diff canal_gain_41_81 comm_per_1941 i.nss43_state_id [pw=wt], cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff) id(1941) tabfile($fn_nssmig) 

/* 1951 */
reg pl_enum_diff canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt], cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff) id(1951) tabfile($fn_nssmig)

/* 1961 */
reg pl_enum_diff canal_gain_61_81 comm_per_1961 i.nss43_state_id [pw=wt], cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff) id(1961) tabfile($fn_nssmig)

/* placebo: canal gain 1991-2021 */
reg pl_enum_diff canal_gain_91_2021 comm_per_1991 i.nss43_state_id [pw=wt], cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff) id(1991) tabfile($fn_nssmig) 

/* PANEL B: Origins of migrants */

/* outcome: migrated from a rural area */

/* full sample */
reg pl_enum_diff_rural canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt], cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff_rural) id(1951r) tabfile($fn_nssmig)

/* in rural destinations */
reg pl_enum_diff_rural canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt] if sector == 1, cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff_rural) id(1951rr) tabfile($fn_nssmig) sector(1)

/* in urban destinations */
reg pl_enum_diff_rural canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt] if sector == 2, cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff_rural) id(1951ru) tabfile($fn_nssmig) sector(2)

/* outcome: migrated from an urban area */

/* full sample */
reg pl_enum_diff_urban canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt], cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff_urban) id(1951u) tabfile($fn_nssmig)

/* in rural destinations */
reg pl_enum_diff_urban canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt] if sector == 1, cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff_urban) id(1951ur) tabfile($fn_nssmig) sector(1)

/* in urban destinations */
reg pl_enum_diff_urban canal_gain_51_81 comm_per_1951 i.nss43_state_id [pw=wt] if sector == 2, cluster(nss43_district_id)
save_nss_migration_results, varname(pl_enum_diff_urban) id(1951uu) tabfile($fn_nssmig) sector(2)

/* typeset table */
table_from_tpl, t($ccode/a/tpl/nss_migration_table_tpl.tex) r($fn_nssmig) o($out/nss_migration_table.tex)
