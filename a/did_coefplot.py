import sys
import os
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt

sys.path.insert(0, os.getcwd())
from canals_config import out

# set some master parameters to make the font look good
mpl.rcParams['mathtext.fontset'] = 'custom'
mpl.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
mpl.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
mpl.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
mpl.rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
mpl.rc('text', usetex=True)

# read in the data
df = pd.read_csv(f"{out}/canal_did_ests_equal_area.csv")

# calculate confidence interval
df['ci'] = df['se']*1.96

# create the plot
f, ax = plt.subplots(figsize=[12,8])

# initiate counter
count_start = 0
xlocs = []

# first plot the "any canal" coefficients
temp = df.loc[df["x"]=="band_comm_per"].copy()

# cycle through each group to plot the results with the 5 different radii
for group in ["appeared5000", "appeared10000", "growth"]:

    # isolate data from this group
    to_plot = temp.loc[temp['y']==group].copy()

    # plot the errorbars
    ax.errorbar(
        y=to_plot["b"],
        x=np.arange(count_start, to_plot.shape[0]+count_start),
        yerr=to_plot["ci"],
        fmt="none",
        ecolor="#8a8987",
        capsize=2,
        mew=0.75,
        linewidth=0.75,
        linecolor="#8a8987"
    )

    # plot the coefficients
    ax.scatter(
        y=to_plot["b"],
        x=np.arange(count_start, to_plot.shape[0]+count_start),
        color="#bf7900"
    )

    # append these plotted locations to the xloc list
    xlocs.append(np.mean(np.arange(count_start, to_plot.shape[0]+count_start)))

    # iterate the counter
    count_start = count_start + to_plot.shape[0] + 2

# draw divider line between the two groups
ax.axvline(count_start, color="black", linewidth=0.75)
count_start = count_start + 2

# second, plot the "percent command are around town" coefficients
temp = df.loc[df["x"]=="comm_per"].copy()

# cycle through each group to plot the results with the 5 different radii
for group in ["appeared5000", "appeared10000", "growth"]:

    # isolate data from this group
    to_plot = temp.loc[temp['y']==group].copy()

    # plot the errorbars
    ax.errorbar(
        y=to_plot["b"],
        x=np.arange(count_start, to_plot.shape[0]+count_start),
        yerr=to_plot["ci"],
        fmt="none",
        ecolor="#8a8987",
        capsize=2,
        mew=0.75,
        linewidth=0.75,
        linecolor="#8a8987"
    )

    # plot the coefficients
    ax.scatter(y=to_plot["b"], x=np.arange(count_start, to_plot.shape[0]+count_start), color="#bf7900")

    # append the plotted locations to the xloc list
    xlocs.append(np.mean(np.arange(count_start, to_plot.shape[0]+count_start)))

    # iterate the counter
    count_start = count_start + to_plot.shape[0] + 2

# axes settings
ax.axhline(0, linestyle="--", linewidth=0.75, color="k")
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.set_ylabel("Difference in Difference Coefficient", fontsize=14)
ax.set_xticks(xlocs)
ax.set_xticks(xlocs)
ax.set_xticklabels(
    ["Exists (5k)", "Exists (10k)", "Growth", "Exists (5k)", "Exists (10k)", "Growth"],
    fontsize=12
)

# save
plt.savefig(f"{out}/town_did_band.png", bbox_inches="tight")
plt.close("all")
