# india-irrigation-canals-paper

This is the replication repository for <a href="https://paulnovosad.com/pdf/acgn-canals.pdf">"The Long-Run Development Impacts of Agricultural Productivity Gains: Evidence from Irrigation Canals in India" (Asher, Campion, Gollin, Novosad)</a>

This repository contains the code required to replicate all tables and figures from the paper. Replication data can be found in this Google Drive folder: [link](https://drive.google.com/drive/folders/10iH6dpTZC6664dBKxwym3ivUJihohGyr). 

## Dataset list
- `canals_analysis_data.dta`: main analysis dataset at the village and town level
- `canals_spillovers.dta`: additional variables used for the spillovers analysis at the village and town level
- `canal_construction_data.dta`: canal data on construction, at the canal segment level (matching to the GIS data)
- `pc81_canals_working.dta`: National Sample Survey data on migration at the individual level, with district-level variation in canal coverage
- `pc51_balance_data.dta`: subset of main data matched to 1951 villages with canals constructed after 1951
- `town_panel_equal_area.dta`: town panel data

## Replication Instructions 
1. Open `canals_config.do`
2. Change the following filepaths saved as globals:

| Filepath | Description                                                                |
|----------|----------------------------------------------------------------------------|
| ccode    | the base filepath for the repository                                       |
| cdata    | the folder where the data files (from Google Drive link above) are saved   |
| out      | the folder where you want all outputs saved                                |
| tmp      | a scratch folder where intermediate outputs can be saved                  |

3. Run `canals_config.do` in Stata. This will set all configurations, no need to change any other files.
4. Open `make_canals_analysis.do` and run in Stata.

## Computational requirements
Most code is run in Stata, with the relevant packages included in the `ado` folder in this repository.

The exception are the coefficient plots which are created using python. Only a very few basic packages are required: `pandas`, `matplotlib`, and `numpy`. Ensure that whatever python environment you are using is activated (i.e. Stata knows where to access the environment) before running the `make_canals_analysis.do` file in Stata, as it will call the code requiring python.

Or, if you do not want to run the python-dependent code, comment out the lines in the Figures section of the `make_canals_analysis.do` file before running it. 

## Figures and Tables

Main Text: 

| Exhibit   | Filename                               | Created by                       |
|-----------|----------------------------------------|----------------------------------|
| Table 1   | sample_description.tex                 | a/gen_sample_description.do      |
| Table 2   | rd_elev_balance.tex                    | a/gen_balance_table.do           |
| Table 3   | rd_elev_results_irr_bal.tex            | a/gen_main_results.do            |
|           | rd_elev_results_ag_bal.tex             |                                  |
|           | rd_elev_results_ec_bal.tex             |                                  |
|           | rd_elev_results_ed_bal.tex             |                                  |
| Table 4   | rd_land_ownership_results.tex          | a/gen_landownership.do           |
| Table 5   | spillovers_table_irr.tex               | a/spillovers_analysis.do         |
|           | spillovers_table_ag.tex                |                                  |
|           | spillovers_table_ec.tex                |                                  |
|           | spillovers_table_ls.tex                |                                  |
| Table 6   | town_did_growth.tex                    | a/analyze_town_diff_in_diff.do   |
|           | town_did_appear.tex                    | a/analyze_town_diff_in_diff.do   |
| Figure 1  | canal_completion_time.png              | a/plot_canal_completion_time.py  |
| Figure 2  | rel_elev_results_bal.pdf               | a/gen_rd_result_grid.do          |
| Figure 3  | all_elev_outcomes_coefplot_bal.png     | a/make_all_coefplots.py          |
| Figure 4  | land_ownership_coefplot.png            | a/land_ownership_coefplot.py     |
| Figure 5  | main_ln_pop_fill_20.pdf                | a/analyze_town_diff_in_diff.do   |
|           | sfe_ln_pop_fill_20.pdf                 |                                  |
|           | main_appeared5000_20.pdf               |                                  |
|           | sfe_appeared5000_20.pdf                |                                  |

Appendix:

| Exhibit   | Filename                          | Created by
|-----------|-----------------------------------|---------------------------------|
| Table A2  | pc51_balance.tex                  | a/gen_pc51_balance_table.do     |
| Table A3  | rd_additional_outcomes_bal.tex    | a/gen_main_results.do           |
| Table A4  | rd_comm_balance.tex               | a/gen_balance_table.do          |
| Table A5  | appendix_irr.tex                  | a/gen_appendix_tables.do        |
| Table A6  | appendix_ag.tex                   | a/gen_appendix_tables.do        |
| Table A7  | appendix_ec.tex                   | a/gen_appendix_tables.do        |
| Table A8  | appendix_ed.tex                   | a/gen_appendix_tables.do        |
| Table A9  | rd_comm_results_irr_bal.tex       | a/gen_main_results.do           |
|           | rd_comm_results_ag_bal.tex        |                                 |
|           | rd_comm_results_ec_bal.tex        |                                 |
|           | rd_comm_results_ed_bal            |                                 |
| Table A10 | sinuosity_table.tex               | a/gen_appendix_tables.do        |
| Table A11 | sensitivity_table.tex             | a/make_sensitivity_table.do     |
| Table A12 | spillovers_table_irr_ebal_app.tex | a/spillovers_analysis.do        |
| Table A13 | spillovers_table_ag_ebal_app.tex  | a/spillovers_analysis.do        |
| Table A14 | spillovers_table_ec_ebal_app.tex  | a/spillovers_analysis.do        |
| Table A15 | spillovers_table_ls_ebal_app.tex  | a/spillovers_analysis.do        |
| Table A16 | town_did_robust.tex               | a/analyze_town_diff_in_diff.do  |
| Table A17 | nss_migration_table.tex           | a/migration_nss.do              |
| Figure A3 | main_ln_pop_fill_10.pdf           | a/analyze_town_diff_in_diff.do  |
|           | sfe_ln_pop_fill_10.pdf            |                                 |
|           | main_appeared5000_10.pdf          |                                 |
|           | sfe_appeared5000_10.pdf           |                                 |
|           | main_ln_pop_fill_30.pdf           |                                 |
|           | sfe_ln_pop_fill_30.pdf            |                                 |
|           | main_appeared5000_30.pdf          |                                 |
|           | sfe_appeared5000_30.pdf           |                                 |
