import os
import sys

# local imports, temporarily add the working directoy to your PYTHONPATH
sys.path.insert(0, os.getcwd())
from a.make_full_coefplot import make_coefplot
from a.make_spillovers_coefplot import make_spill_coefplot

# make_coefplot() builds the various coefplots we need for the paper and presentation. input arguments are:
#     - vselect: the list of variables to be plotted. options are stored in the
#                dictionary varlists in canals/a/plotting_labels.py. choose the
#                list of variables you want, passing the key as a string to vselect
#     - fnsuffix: the sample used to run the results. "bal" is our main, balanced,
#                 analysis sample. other options include "full", "donut", "median", "p25",
#                 "control", "hole", and "comm", corresponding to the different samples
#                 we report in our appendix robustness tables. these samples are defined in
#                 canals/a/prep_analysis_sample.do and then used in canals/a/gen_appendix_tables.do
#     - figsize: the aspect ratio of the plot, longer for paper figures and more square
#                for presentation figures
#     - grplines: True to plot lines separating variables grouped by type

# ----------------- #
# Figures for Paper #
# ----------------- #
# all variables, long plot, balanced analysis sample
make_coefplot(vselect="All", fnsuffix="bal", figsize=[4,9], grplines=True)

# ------------------------ #
# Figures for Presentation #
# ------------------------ #
# irrigation variables, square plot, balanced analaysis sample
make_coefplot(vselect="Irrigation", fnsuffix="bal", figsize=[4,4], grplines=True)

# agriculture variables, square plot, balanced analaysis sample
make_coefplot(vselect="Agriculture", fnsuffix="bal", figsize=[4,4], grplines=True)

# economic variables, square plot, balanced analaysis sample
make_coefplot(vselect="Non-farm", fnsuffix="bal", figsize=[4,4], grplines=True)

# education variables, square plot, balanced analaysis sample
make_coefplot(vselect="Education", fnsuffix="bal", figsize=[4,4], grplines=True)

# spillovers coefplot: distant vs. above-canal settlements for Ag and Irr
make_spill_coefplot(vselect="Agriculture and Irrigation", fnsuffix="main", grp="distant", figsize=[4,5], grplines=True)

# spillovers coefplot: distant vs. above-canal settlements
make_spill_coefplot(vselect="Non-farm and Landownership", fnsuffix="main", grp="distant", figsize=[4,5], grplines=True)

# spillovers coefplot: below vs. below-canal settlements for Ag and Irr
make_spill_coefplot(vselect="Agriculture and Irrigation", fnsuffix="main", grp="below", figsize=[4,5], grplines=True)

# spillovers coefplot: below vs. above-canal settlements
make_spill_coefplot(vselect="Non-farm and Landownership", fnsuffix="main", grp="below", figsize=[4,5], grplines=False)

# --------------------- # 
# Presentation Appendix #
# --------------------- # 
# all variables, long plot for full sample 
make_coefplot(vselect="All", fnsuffix="full", figsize=[4,6], grplines=True)

# all variables, long plot for donut sample
make_coefplot(vselect="All", fnsuffix="hole", figsize=[4,6], grplines=True)

# all variables, long plot for median elevation
make_coefplot(vselect="All", fnsuffix="median", figsize=[4,6], grplines=True)

# all variables, long plot for 25th percentile elevation
make_coefplot(vselect="All", fnsuffix="p25", figsize=[4,6], grplines=True)

# all variables, long plot for including the distance to canal control
make_coefplot(vselect="All", fnsuffix="control", figsize=[4,6], grplines=True)

# all variables, long plot for long, straight canals (sinuosity <1.2, length > 10)
make_coefplot(vselect="All", fnsuffix="s2l10", figsize=[4,6], grplines=True)

# all variables, long plot for including the distance to canal control
make_coefplot(vselect="All", fnsuffix="comm", figsize=[4,6], grplines=True)

# all variables, long plot for including the distance to canal control
make_coefplot(vselect="Age Structure", fnsuffix="bal", figsize=[4,6], grplines=False)

