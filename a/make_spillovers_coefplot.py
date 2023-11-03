import os
import sys
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

# local imports, temporarily add the working directoy to your PYTHONPATH
sys.path.insert(0, os.getcwd())
from canals_config import out, allvars_order, allvars_labels, varlists, fps

# set some master parameters to make the font look good
mpl.rcParams['mathtext.fontset'] = 'custom'
mpl.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
mpl.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
mpl.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
mpl.rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
mpl.rc('text', usetex=True)
mpl.rcParams['figure.dpi'] = 300

# define function to assign color based on sign of coefficient
def define_color(val, se):
    if (val - se > 0.0001) and val > 0:
        return "#0058bd"
    elif (val + se < 0.0001) and val < 0:
        return "#9c0000"
    else:
        return "#c2c2c2"

def make_spill_coefplot(vselect="All", fnsuffix="main", bal="webal", grp="below", w_rescale="dist", band="b0", rug_bal=True, outliers=2.5, figsize=[4,9], grplines=False):
    """
    vselect: the set of variables to be included in this coefplot
             (options defined in varlists, imported from plotting_labels)
    fnsuffix: the sample to be used
              (must match a sample set in prep_analysis_sample and gen_main_results)
    figsize: the dimensions (aspect ratio) of the plot,
             use wider plot for slides and longer plot for paper
    bal: "ebal" for entropy balance, "cem" for coarsened exact match
    grp: "dist" to compare to villages distant from the canal, "below" to compare to villages below
    w_resacle: "dist" for rescaling weights within district
    rug_bal: True for enforcing ruggedness balance, False for not
    outliers: The percentile of outliers excluded, 2.5 is the default. Can also do 0, 1, 4.
    grplines: True to draw lines separating the groups of variables
              as we do in the full coefplot
    """
    # identify the sample we want from the function inputs
    if rug_bal:
        rbal = "rug"
    else:
        rbal = "nrug"
    pout = int(outliers * 10)

    # construct the sample string
    # samp_specs = f"{bal}_{w_rescale}_{rbal}_p{pout}"
    samp_specs = f"webal_{band}"

    # set the grp
    if grp == "distant":
        grpn = "n2"
    if grp == "below":
        grpn = "n1"

    # read in the data
    df = pd.read_csv(f"{out}/spillovers_entropy_balance.csv")

    # split out the variable name from the rest of the information
    df[["variable", "temp"]] = df["1"].str.split("__", expand=True)

    # split out the above vs. below
    df[["measure", "temp2"]] = df["temp"].str.split("_", expand=True,n=1)

    # split out the measure from the sample info
    df[["group", "sample"]] = df["temp2"].str.split("_", expand=True,n=1)

    # split out the measure from the sample info
    df[["group", "sample"]] = df["temp2"].str.split("_", expand=True,n=1)

    # isolate just the sample we want
    df = df.loc[df['sample']==samp_specs].copy()

    # get just the above or below canals
    df = df.loc[df["group"]==grpn].copy()

    # isolate values as numbers
    df["value"] = df["2"].str.strip("*")
    df["value"] = df["value"].astype(float)

    # pivot table
    df = df.pivot_table(index=["variable"], values="value", columns="measure").reset_index()

    # sort
    df['order'] = df['variable'].apply(lambda x: allvars_order.get(x))
    df = df.sort_values(by="order", ascending=False)
    df = df.drop("order", axis=1).reset_index(drop=True)

    # get CI
    df['ci'] = df['coef'] - df['low95']

    # keep just the variables we want
    temp = df.loc[df['variable'].isin(varlists[vselect])].copy()

    # get colors
    color_list = temp.apply(lambda row: define_color(row['coef'], row['ci']), axis=1)
    color_list = tuple(list(color_list))

    # define the figure
    f, ax = plt.subplots(figsize=figsize)

    # plot to get the index
    temp["coef"].plot(kind="barh", color="none", ax=ax, linewidth=0.25)

    # plot the scatter plot and errorbars
    ax.scatter(y=np.arange(temp.shape[0]), x=temp["coef"], marker='o', s=40, color=color_list)
    ax.errorbar(x=temp["coef"], y=np.arange(temp.shape[0]), xerr=temp["ci"], fmt="none", ecolor="black", capsize=2, mew=0.5, linewidth=0.5)
    ax.set_xlim([-0.2, 0.2])
    
    # draw outcome groupings
    if vselect == "Agriculture and Irrigation" and grplines is True:
        tirr = ax.text(ax.get_xlim()[1]-0.025, 5, "\emph{Irrigation}", fontsize=7, ha='center')
        tirr.set_bbox(dict(facecolor='white', edgecolor='none'))
        ax.axhline(3.5, linewidth=0.25, linestyle="-", color="gray")

        tag = ax.text(ax.get_xlim()[1]-0.025, 1.5, "\emph{Agriculture}", fontsize=7, ha='center')
        tag.set_bbox(dict(facecolor='white', edgecolor='none'))


    elif vselect == "Non-farm and Landownership" and grplines is True:
        tec = ax.text(ax.get_xlim()[1]-0.025, 6, "\emph{Non-farm}\n\emph{activity}", fontsize=7, ha='center')
        tec.set_bbox(dict(facecolor='white', edgecolor='none'))
        ax.axhline(3.5, linewidth=0.25, linestyle="-", color="gray")

        ted = ax.text(ax.get_xlim()[1]-0.025, 1.5, "\emph{Landownership} \n \emph{effects}", fontsize=7, ha='center')
        ted.set_bbox(dict(facecolor='white', edgecolor='none'))
        
    if vselect != "All":
        ax.set_title(f"{str.capitalize(grp)} vs. Above-canal settlements", fontsize=14)

    # set axes labels
    labs = ax.set_yticklabels([allvars_labels[x] for x in list(temp["variable"])], fontsize=7, color="#383838", rotation=0, ha="right")
    ax.tick_params(axis='x', labelsize=6)
    ax.set_xlabel("Normalized treatment effect", color="#383838", fontsize=8)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.grid(axis="x", linewidth=0.5, linestyle="--")
    ax.axvline(0, linestyle="--", linewidth=0.75, color="k")

    # set the title of the plot
    title = f"{fps[vselect]}_spillovers_coefplot_{grp}_{fnsuffix}.png"
    print(title_
    outfp = f"{out}/{title}"

    # save
    plt.savefig(outfp, bbox_inches="tight")
    plt.close("all")
