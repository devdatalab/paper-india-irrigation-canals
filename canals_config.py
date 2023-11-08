import os

# Extract gloals set in the stata config file so they can be accessed in python
# get the current directory
current_dir = os.path.dirname(os.path.abspath(__name__))

# open the stata config file
with open("canals_config.do", 'r') as file:
    # read the contents of the file
    configtext = file.read()

# get just the text we need from the config file
text = [x for x in configtext.split("\n") if "global" in x and "/*" not in x ]

# extract the filepaths we need
ccode = [x.split("ccode")[1].strip() for x in text if "global ccode" in x][0]
cdata = [x.split("cdata")[1].strip() for x in text if "global cdata" in x and "cdata_all" not in x][0]
out = "~" + [x.split("out ~")[1].strip() for x in text if "global out" in x][0] 
tmp = [x.split("tmp")[1].strip() for x in text if "global tmp" in x][0]

# ensure all filepaths are absolute without the home directory ~
ccode = os.path.expanduser(ccode)
cdata = os.path.expanduser(cdata)
out = os.path.expanduser(out)
tmp = os.path.expanduser(tmp)


import pandas as pd
import os

def output_data_html(data, using):
    """
    data: filepath to dta file saved out of stata
    using: filepath for html log file
    """
    # ensure home directory is expanded
    using = os.path.expanduser(using)

    # read in the data
    if data.split(".")[-1] == "dta":
        df = pd.read_stata(data)
    elif data.split(".")[-1] == "csv":
        df = pd.read_csv(data)
    elif (data.split(".")[-1] == "xls") | (data.split(".")[-1] == "xlsx"):
        df = pd.read_excel(data)
    else:
        raise ValueError("Data must be csv, dta, or excel.")

    # write out the data to a temporary html file
    table = os.path.join(os.environ["TMP"], "temp_table.html")
    df.to_html(table)

    # copy the table into the logfile
    with open(table,"r") as firstfile, open(using, "a") as secondfile:

        # read content from first file
        for line in firstfile:

            # append content to second file
            secondfile.write(line)

allvars_labels = {
    "irr_share11": "Total irrigated area \n (share of ag. land)",
    "ag_share11": "Agricultural land \n (share of total village area)",
    "irr_share_canal": "Canal irrigated area \n (share of ag. land)",
    "irr_share_tubewell": "Tubewell irrigated area \n (share of ag. land)",
    "irr_share_tl": "Tank or lake irrigated area \n (share of ag. land)",
    "irr_share_oth": "Other irrigated area \n (share of ag. land)",
    "any_water_crop": "Water intensive \n crops grown (any)",
    "count_water_crop": "Water intensive \n crops grown (count)",
    "evi_delta_k_ln_mean": "Kharif agricultural production, \n EVI-derived (log)",
    "evi_delta_r_ln_mean": "Rabi agricultural production, \n EVI-derived (log)",
    "mech_farm_equip": "Mechanized farming equipment \n (share of all HHs)",
    "popdens_poly11_log": "Population density \n (log)",
    "secc_cons_pc_log": "Consumption pc \n (log)",
    "ec13_emp_pc": "Total nonfarm employment \n (share of adult pop.)",
    "ec13_emp_serv_pc": "Services employment \n (share of adult pop.)",
    "ec13_emp_manuf_pc": "Manufacturing employment \n (share of adult pop.)",
    "ec13_agro_pc": "Agroprocessing employment \n (share of adult pop.)",
    "ed_primary_adult": "Primary school ed attained \n (share of adult pop.)",
    "ed_middle_adult": "Middle school ed attained \n (share of adult pop.)",
    "ed_secondary_adult": "Secondary school ed attained \n (share of adult pop.)",
    "pc11_pca_p_lit_pc": "Literacy rate \n (literate share of pop.)",
    "pc11_vd_tar_road": "Paved road \n (any)",
    "pc11_vd_power_all": "Power for all users \n (share of pop.)",
    "pc11_vd_m_sch": "Middle school \n (any)",
    "pc11_vd_all_hosp": "Hospital \n (any)",
    "age0_9_share": "Age 0-9 \n (SECC Share)",
    "age10_19_share": "Age 10-19 \n (SECC Share)",
    "age20_29_share": "Age 20-29 \n (SECC Share)",
    "age30_39_share": "Age 30-39 \n (SECC Share)",
    "age40_49_share": "Age 40-49 \n (SECC Share)",
    "age50_59_share": "Age 50-59 \n (SECC Share)",
    "age60_69_share": "Age 60-69 \n (SECC Share)",
    "age70_79_share": "Age 70-79 \n (SECC Share)",
    "age80_share": "Age 80+ \n (SECC Share)",
    "age0_5_ratio_20_40": "Age 0-5 to 20-40 \n (SECC Ratio)",
    "age70_ratio_20_40": "Age 70+ to 20-40 \n (SECC Ratio)",
    "pop_share_06": "Age 0-6 \n (PC Share)",
    "age25_30_land1": "Age 25-30 Land-owning HHs \n (Share of allland-owning HHs)",
    "age25_30_land0": "Age 25-30 Landless HHs \n (Share of all landless HHs)",
    "age55_64_land1": "Age 55-64 Land-owning HHs \n (Share of all land-owning HHs)",
    "age55_64_land0": "Age 55-64 Landless HHs \n (Share of all landless HHs)",
    "cons_pc_land_own0_log": "Consumption pc \n (log, landless HHS)",
    "cons_pc_land_own1_log": "Consumption pc \n (log, land-owning HHs)",
    "ed_m_full_land_own0": "Middle School \n (share of landless pop.)",
    "ed_m_full_land_own1": "Middle School \n (share of land-owning pop.)",
}


allvars_order = {
    "irr_share11": 0,
    "irr_share_canal": 1,
    "irr_share_tubewell": 2,
    "irr_share_tl": 3,
    "irr_share_oth": 4,
    "ag_share11": 5,
    "evi_delta_k_ln_mean": 6,
    "evi_delta_r_ln_mean": 7,
    "any_water_crop": 8,
    "count_water_crop": 8.5,
    "mech_farm_equip": 9,
    "popdens_poly11_log": 10,
    "secc_cons_pc_log": 11,
    "ec13_emp_pc": 12,
    "ec13_emp_serv_pc": 13,
    "ec13_emp_manuf_pc": 14,
    "ec13_agro_pc": 15,
    "ed_primary_adult": 16,
    "ed_middle_adult": 17,
    "ed_secondary_adult": 18,
    "pc11_pca_p_lit_pc": 19,
    "pc11_vd_tar_road": 20,
    "pc11_vd_power_all": 21,
    "pc11_vd_m_sch": 22,
    "pc11_vd_all_hosp": 23,
    "pop_share_06": 35,
    "age0_9_share": 34,
    "age10_19_share": 33,
    "age20_29_share": 32,
    "age30_39_share": 31,
    "age40_49_share": 30,
    "age50_59_share": 29,
    "age60_69_share": 28,
    "age70_79_share": 27,
    "age80_share": 26,
    "age0_5_ratio_20_40": 25,
    "age70_ratio_20_40": 24,
    "age25_30_land1": 36,
    "age25_30_land0": 37, 
    "age55_64_land1": 38,
    "age55_64_land0": 39,
    "cons_pc_land_own1_log": 40,
    "cons_pc_land_own0_log": 41,
    "ed_m_full_land_own1": 42,
    "ed_m_full_land_own0": 43,
}

agestrcut_order = {
    "age0_9_ll_f_share": 8,
    "age10_19_ll_f_share": 7,
    "age20_29_ll_f_share": 6,
    "age30_39_ll_f_share": 5,
    "age40_49_ll_f_share": 4,
    "age50_59_ll_f_share": 3,
    "age60_69_ll_f_share": 2,
    "age70_79_ll_f_share": 1,
    "age80_ll_f_share": 0,
    "age0_9_ll_m_share": 17,
    "age10_19_ll_m_share": 16,
    "age20_29_ll_m_share": 15,
    "age30_39_ll_m_share": 14,
    "age40_49_ll_m_share": 13,
    "age50_59_ll_m_share": 12,
    "age60_69_ll_m_share": 11,
    "age70_79_ll_m_share": 10,
    "age80_ll_m_share": 9,
    "age0_9_lo_f_share": 26,
    "age10_19_lo_f_share": 25,
    "age20_29_lo_f_share": 24,
    "age30_39_lo_f_share": 23,
    "age40_49_lo_f_share": 22,
    "age50_59_lo_f_share": 21,
    "age60_69_lo_f_share": 20,
    "age70_79_lo_f_share": 19,
    "age80_lo_f_share": 18,
    "age0_9_lo_m_share": 35,
    "age10_19_lo_m_share": 34,
    "age20_29_lo_m_share": 33,
    "age30_39_lo_m_share": 32,
    "age40_49_lo_m_share": 31,
    "age50_59_lo_m_share": 30,
    "age60_69_lo_m_share": 29,
    "age70_79_lo_m_share": 28,
    "age80_lo_m_share": 27,
    "pop_share_06": 35,
    "age0_9_share": 34,
    "age10_19_share": 33,
    "age20_29_share": 32,
    "age30_39_share": 31,
    "age40_49_share": 30,
    "age50_59_share": 29,
    "age60_69_share": 28,
    "age70_79_share": 27,
    "age80_share": 26,
    "secc_hh_land_own0": 36,
    "secc_hh_land_own1": 37,
}

varlists = {
    "Agriculture_irrigation": ["irr_share11", "irr_share_canal", "irr_share_tubewell", "ag_share11", "evi_delta_k_ln_mean", "evi_delta_r_ln_mean", "any_water_crop", "mech_farm_equip"],
    "Irrigation": ["irr_share11", "irr_share_canal", "irr_share_tubewell", "irr_share_tl", "irr_share_oth"],
    "Agriculture": [ "ag_share11", "evi_delta_k_ln_mean", "evi_delta_r_ln_mean", "any_water_crop", "mech_farm_equip"],
    "Non-farm": ["popdens_poly11_log", "secc_cons_pc_log", "ec13_emp_pc", "ec13_emp_serv_pc", "ec13_emp_manuf_pc", "ec13_agro_pc"],
    "Education":["ed_primary_adult", "ed_middle_adult", "ed_secondary_adult", "pc11_pca_p_lit_pc"],
    "All" : ["irr_share11", "irr_share_canal", "irr_share_tubewell", "irr_share_tl", "irr_share_oth",
             "ag_share11", "evi_delta_k_ln_mean", "evi_delta_r_ln_mean", "any_water_crop", "mech_farm_equip",
             "popdens_poly11_log", "secc_cons_pc_log", "ec13_emp_pc", "ec13_emp_serv_pc", "ec13_emp_manuf_pc", "ec13_agro_pc",
             "ed_primary_adult", "ed_middle_adult", "ed_secondary_adult", "pc11_pca_p_lit_pc"],
    "Agriculture and Irrigation":["irr_share11", "irr_share_canal", "irr_share_tubewell", "ag_share11", "evi_delta_k_ln_mean", "evi_delta_r_ln_mean", "any_water_crop"],
    "Non-farm and Landownership": ["popdens_poly11_log", "ec13_emp_pc", "ec13_emp_serv_pc", "ec13_emp_manuf_pc", "secc_cons_pc_log", "cons_pc_land_own0_log", "cons_pc_land_own1_log", "ed_m_full_land_own0", "ed_m_full_land_own1"],
    "Infrastructure": ["pc11_vd_tar_road", "pc11_vd_power_all", "pc11_vd_m_sch", "pc11_vd_all_hosp"],
    "Age Structure": ["age0_9_share", "age10_19_share", "age20_29_share", "age30_39_share", "age40_49_share", "age50_59_share", "age60_69_share", "age70_79_share", "age80_share", "pop_share_06"],
    "Landless Female Age Structure":  ["age0_9_ll_female_share", "age10_19_ll_female_share", "age20_29_ll_female_share", "age30_39_ll_female_share", "age40_49_ll_female_share", "age50_59_ll_female_share", "age60_69_ll_female_share", "age70_79_ll_female_share", "age80_ll_female_share"],
    "Landless Male Age Structure":  ["age0_9_ll_male_share", "age10_19_ll_male_share", "age20_29_ll_male_share", "age30_39_ll_male_share", "age40_49_ll_male_share", "age50_59_ll_male_share", "age60_69_ll_male_share", "age70_79_ll_male_share", "age80_ll_male_share"],
    "Landowner Female Age Structure":  ["age0_9_lo_female_share", "age10_19_lo_female_share", "age20_29_lo_female_share", "age30_39_lo_female_share", "age40_49_lo_female_share", "age50_59_lo_female_share", "age60_69_lo_female_share", "age70_79_lo_female_share", "age80_lo_female_share"],
    "Landowner Male Age Structure":  ["age0_9_lo_male_share", "age10_19_lo_male_share", "age20_29_lo_male_share", "age30_39_lo_male_share", "age40_49_lo_male_share", "age50_59_lo_male_share", "age60_69_lo_male_share", "age70_79_lo_male_share", "age80_lo_male_share"],    
}

fps = {
    "Agriculture": "ag",
    "Irrigation": "irr",
    "Non-farm": "ec",
    "Education": "ed",
    "All": "all",
    "Infrastructure": "infra",
    "Age Structure": "age",
    "Landowner Age Structure": "landown_age_2",
    "Agriculture and Irrigation": "ag_irr",
    "Non-farm and Landownership": "ec_ed",
}

landown_labels = {
    "land_own1": "Land-owning HHs \n (share of all HHs)",
    "land_hold_land_own1_log": "Land holdings size \n in log hectares \n (land-owning HHs)",
    "land_hold_all_log":  "Land holdings size \n in log hectares \n (all HHs)",
    "cons_pc_land_own1_log": "Land-owning HHs \n (all)",
    "cons_pc_land_own0_log": "Landless HHs \n (all)",
    "cons_pc_landhold_q201_log": "$\mathrm{1^{st}}$ quintile \n land-owning HHs",
    "cons_pc_landhold_q401_log": "$\mathrm{2^{nd}}$ quintile \n land-owning HHs",
    "cons_pc_landhold_q601_log": "$\mathrm{3^{rd}}$ quintile \n land-owning HHs",
    "cons_pc_landhold_q801_log": "$\mathrm{4^{th}}$ quintile \n land-owning HHs",
    "cons_pc_landhold_q1001_log": "$\mathrm{5^{th}}$ quintile \n land-owning HHs",
    "ed_p_full_land_own1": "At least primary \n (share of land-owning pop.)",
    "ed_p_full_land_own0": "At least primary \n (share of landless pop.)",
    "ed_m_full_land_own1": "At least middle \n (share of land-owning pop.)",
    "ed_m_full_land_own0": "At least middle \n (share of landless pop.)",
    "ed_s_full_land_own1": "At least secondary \n (share of land-owning pop.)",
    "ed_s_full_land_own0": "At least secondary \n (share of landelss pop.)",
    "cons_pc_lh_qrt251_log": "$\mathrm{1^{st}}$ quartile \n land-owning HHs",
    "cons_pc_lh_qrt501_log": "$\mathrm{2^{nd}}$ quartile \n land-owning HHs",
    "cons_pc_lh_qrt751_log": "$\mathrm{3^{rd}}$ quartile \n land-owning HHs",
    "cons_pc_lh_qrt1001_log": "$\mathrm{4^{th}}$ quartile \n land-owning HHs",
    "cons_pc_landhold_t331_log": "$\mathrm{1^{st}}$ third \n land-owning HHs",
    "cons_pc_landhold_t661_log": "$\mathrm{2^{nd}}$ third \n land-owning HHs",
    "cons_pc_landhold_t1001_log": "$\mathrm{3^{rd}}$ third \n land-owning HHs",
}

landown_order = {
    "land_own1": 0,
    "land_hold_land_own1_log": 1,
    "land_hold_all_log":  2,
    "cons_pc_land_own0_log": 6,
    "cons_pc_land_own1_log": 5,
    "cons_pc_landhold_q201_log": 4,
    "cons_pc_landhold_q401_log": 3,
    "cons_pc_landhold_q601_log": 2,
    "cons_pc_landhold_q801_log": 1,
    "cons_pc_landhold_q1001_log": 0,
    "ed_p_full_land_own1": 0,
    "ed_p_full_land_own0": 1,
    "ed_m_full_land_own1": 2,
    "ed_m_full_land_own0": 3,
    "ed_s_full_land_own1": 4,
    "ed_s_full_land_own0": 5,
    "cons_pc_lh_qrt251_log": 4,
    "cons_pc_lh_qrt501_log": 3,
    "cons_pc_lh_qrt751_log": 2,
    "cons_pc_lh_qrt1001_log": 1,
    "cons_pc_landhold_t331_log": 4,
    "cons_pc_landhold_t661_log": 3,
    "cons_pc_landhold_t1001_log": 2,
}
