import os
import sys
import pandas as pd
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
    if (val - se > 0) and val > 0:
        return "#0058bd"
    elif (val + se <= 0) and val < 0:
        return "#9c0000"
    else:
        return "#c2c2c2"

def make_coefplot(vselect="All", fnsuffix="bal", figsize=[4,9], grplines=False):
    """
    vselect: the set of variables to be included in this coefplot
             (options defined in varlists, imported from tools)
    fnsuffix: the sample to be used
              (must match a sample set in prep_analysis_sample and gen_main_results)
    figsize: the dimensions (aspect ratio) of the plot,
             use wider plot for slides and longer plot for paper
    grplines: True to draw lines separating the groups of variables
              as we do in the full coefplot
    """
    # read in the data
    df = pd.read_csv(f"{out}/rd_coef_results_all_coefplot_appendix.csv", header=None)

    # split out the variable name from the measure
    df[["temp", "measure"]] = df[0].str.split("__", expand=True)

    # split out the sample
    df[["sample", "variable"]] = df["temp"].str.split("_", expand=True,n=1)

    # isolate just the sample we want
    df = df.loc[df["sample"]==fnsuffix].copy()

    # pivot table
    df = df.pivot_table(index=["variable"], values=1, columns="measure").reset_index()

    # drop the elev
    df['variable'] = df['variable'].apply(lambda x: x.replace("_elev", ""))
    df['variable'] = df['variable'].apply(lambda x: x.replace("_seg", ""))    

    # sort
    df['order'] = df['variable'].apply(lambda x: allvars_order.get(x))
    df = df.sort_values(by="order", ascending=False)
    df = df.drop("order", axis=1).reset_index(drop=True)

    # ensure values are numbers
    df['coef'] = df['coef'].astype(float)
    df['low95'] = df['low95'].astype(float)

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
    temp["coef"].plot(kind="barh", color="none", ax=ax)

    # plot the scatter plot and errorbars
    ax.scatter(y=np.arange(temp.shape[0]), x=temp["coef"], marker='o', s=40, color=color_list)
    ax.errorbar(x=temp["coef"], y=np.arange(temp.shape[0]), xerr=temp["ci"], fmt="none", ecolor="black", capsize=2, mew=0.5, linewidth=0.5)

    # draw outcome groupings
    if vselect == "All" and grplines is True:
        tirr = ax.text(ax.get_xlim()[1]-0.025, 16, "\emph{Irrigation}", fontsize=7, ha='center')
        tirr.set_bbox(dict(facecolor='white', edgecolor='none'))
        ax.axhline(14.5, linewidth=0.25, linestyle="-", color="gray")

        tag = ax.text(ax.get_xlim()[1]-0.025, 11.2, "\emph{Agriculture}", fontsize=7, ha='center')
        tag.set_bbox(dict(facecolor='white', edgecolor='none'))
        ax.axhline(9.5, linewidth=0.25, linestyle="-", color="gray")

        tec = ax.text(ax.get_xlim()[1]-0.025, 6, "\emph{Non-farm}\n\emph{activity}", fontsize=7, ha='center')
        tec.set_bbox(dict(facecolor='white', edgecolor='none'))
        ax.axhline(3.5, linewidth=0.25, linestyle="-", color="gray")

        ted = ax.text(ax.get_xlim()[1]-0.025, 1.5, "\emph{Education}", fontsize=7, ha='center')
        ted.set_bbox(dict(facecolor='white', edgecolor='none'))
    if vselect != "All":
        ax.set_title(f"{vselect} Outcomes")

    # axes settings
    labs = ax.set_yticklabels([allvars_labels[x] for x in list(temp["variable"])], fontsize=7, color="#383838", rotation=0, ha="right")
    ax.tick_params(axis='x', labelsize=6)
    ax.set_xlabel("Normalized treatment effect", color="#383838", fontsize=8)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.grid(axis="x", linewidth=0.5, linestyle="--")
    ax.axvline(0, linestyle="--", linewidth=0.75, color="k")

    # special settings for specific plots
    if fnsuffix == "s2l10":
        ax.set_xlim([-0.05, 0.35])
    elif vselect == "Age Structure":
        ax.set_xlim([-0.02, 0.02])
    else:
        ax.set_xlim([-0.05, 0.22])

    # get the title of the figure
    title = f"{fps[vselect]}_elev_outcomes_coefplot_{fnsuffix}.png"
    print(title)
    outfp = f"{out}/{title}"

    # save
    plt.savefig(outfp, bbox_inches="tight")
    plt.close("all")
