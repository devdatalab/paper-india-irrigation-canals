import os
import sys
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

# local imports, add the working directoy to your PYTHONPATH
# (working directory should be main folder with all code)
sys.path.insert(0, os.getcwd())
from canals_config import cdata, out, landown_order, landown_labels

# set some visual settings
mpl.rcParams['mathtext.fontset'] = 'custom'
mpl.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
mpl.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
mpl.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
mpl.rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
mpl.rc('text', usetex=True)

# define function to assign color based on sign of coefficient
def define_color(val, se):
    if (val - se > 0) and val > 0:
        return "#0058bd"
    elif (val + se <= 0) and val < 0:
        return "#9c0000"
    else:
        return "#c2c2c2"

# read in coefficient resutls from rd
df = pd.read_csv(f"{out}/land_ownership_bal.csv", header=None)

# split of variable name from measure
df[["variable", "measure"]] = df[0].str.split("__",expand=True,)

# pivot table
df = df.pivot_table(index="variable", values=1, columns="measure")

# reset index
df = df.reset_index()

# calculate ci - same as coef - low95
df["ci"] = df["up95"] - df["coef"]
df['color'] = df.apply(lambda row: define_color(row['coef'], row['ci']), axis=1)

# remove "elev" from all the variables
df["variable"] = df["variable"].apply(lambda x: x.split("_elev")[0])

f, axes = plt.subplots(figsize=[12, 4], ncols=3, constrained_layout=True)

# simple landholding variables
v1_list = ["land_own1", "land_hold_land_own1_log", "land_hold_all_log"]

# quintile breaks
v2_list = ["cons_pc_land_own0_log", "cons_pc_landhold_q201_log", "cons_pc_landhold_q401_log", "cons_pc_landhold_q601_log", "cons_pc_landhold_q801_log", "cons_pc_landhold_q1001_log", "cons_pc_land_own1_log"]

# education X land ownership
v3_list = ["ed_p_full_land_own1", "ed_p_full_land_own0", "ed_m_full_land_own1", "ed_m_full_land_own0", "ed_s_full_land_own1", "ed_s_full_land_own0"]

# quartile breaks
v4_list = ["cons_pc_land_own0_log", "cons_pc_lh_qrt251_log", "cons_pc_lh_qrt501_log", "cons_pc_lh_qrt751_log", "cons_pc_lh_qrt1001_log", "cons_pc_land_own1_log"]

# thirds breaks
v5_list = ["cons_pc_landhold_t331_log", "cons_pc_landhold_t661_log", "cons_pc_landhold_t1001_log"]

# -------- #
# Figure 1 #
# -------- #
# extract the variables we want 
temp = df.loc[df['variable'].isin(v1_list)].reset_index(drop=True)

# sort the variables in the correct order
temp['order'] = temp['variable'].apply(lambda x: landown_order.get(x))
temp = temp.sort_values(by="order", ascending=False).reset_index(drop=True)

# select the first plot
ax = axes[0]

# for each coefficient, plot the point and errorbar
for i in np.arange(temp["coef"].shape[0]):
    ax.scatter(y=i, x=temp.loc[i, "coef"], s=40, marker="o", color=temp.loc[i, "color"])
    ax.errorbar(x=temp["coef"], y=np.arange(temp["coef"].shape[0]),
                xerr=temp["ci"], fmt="none", ecolor="black", capsize=2, mew=0.5, linewidth=0.5)

# axes settings
ax.set_xlim([-0.1, 0.1])
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.axvline(0, linestyle="--", linewidth=0.75, color="k")
ax.grid(axis="x", linewidth=0.5, linestyle="--")
ax.set_yticks(np.arange(temp["coef"].shape[0]))
labs = ax.set_yticklabels([landown_labels[x] for x in list(temp["variable"])], fontsize=9, color="#383838")
ax.set_title("A. Land Ownership")

# -------- #
# Figure 2 #
# -------- #
# extract the variables we want
temp = df.loc[df['variable'].isin(v4_list)].reset_index(drop=True)

# sort the variables in the correct order
temp['order'] = temp['variable'].apply(lambda x: landown_order.get(x))
temp = temp.sort_values(by="order", ascending=False).reset_index(drop=True)

# select the second plot
ax = axes[1]

# for each coefficient, plot the point and errorbar
for i in np.arange(temp["coef"].shape[0]):
    ax.scatter(y=i, x=temp.loc[i, "coef"], s=40, marker="o", color=temp.loc[i, "color"])
    ax.errorbar(x=temp["coef"], y=np.arange(temp["coef"].shape[0]),
                xerr=temp["ci"], fmt="none", ecolor="black", capsize=2, mew=0.5, linewidth=0.5)

# axes settings
ax.set_xlim([-0.05, 0.05])
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.axvline(0, linestyle="--", linewidth=0.75, color="k")
ax.axhline(1.5, linewidth=0.5, linestyle="-", color="black", zorder=5)
ax.grid(axis="x", linewidth=0.5, linestyle="--")
ax.set_yticks(np.arange(temp["coef"].shape[0]))
labs = ax.set_yticklabels([landown_labels[x] for x in list(temp["variable"])], fontsize=9, color="#383838")
ax.set_title("B. Consumption (log)")
ax.set_xlabel("Normalized treatment effect", fontsize=12, labelpad=10)

# -------- #
# Figure 3 #
# -------- #
# extract the variables we want
temp = df.loc[df['variable'].isin(v3_list)].reset_index(drop=True)

# sort the variables in the correct order
temp['order'] = temp['variable'].apply(lambda x: landown_order.get(x))
temp = temp.sort_values(by="order", ascending=False).reset_index(drop=True)

# select the third plot
ax = axes[2]

# for each coefficient, plot the point and errorbar
for i in np.arange(temp["coef"].shape[0]):
    ax.scatter(y=i, x=temp.loc[i, "coef"], s=40, marker="o", color=temp.loc[i, "color"])
    ax.errorbar(x=temp["coef"], y=np.arange(temp["coef"].shape[0]),
                xerr=temp["ci"], fmt="none", ecolor="black", capsize=2, mew=0.5, linewidth=0.5)

# axes settings
ax.set_xlim([-0.05, 0.05])
ax.spines["top"].set_visible(False)
ax.spines["right"].set_visible(False)
ax.axvline(0, linestyle="--", linewidth=0.75, color="k")
ax.grid(axis="x", linewidth=0.5, linestyle="--")
ax.set_yticks(np.arange(temp["coef"].shape[0]))
labs = ax.set_yticklabels([landown_labels[x] for x in list(temp["variable"])], fontsize=9, color="#383838")
ax.set_title("C. Education attainment")

# draw lines
ax.axhline(1.5, linewidth=0.5, linestyle="-", color="gray", zorder=5)
ax.axhline(3.5, linewidth=0.5, linestyle="-", color="gray", zorder=5)

# save
plt.savefig(f"{out}/land_ownership_coefplot.png", bbox_inches="tight", dpi=200)
plt.close("all")

# --------------------------------- #
# Figure 2 alone - for presentation #
# --------------------------------- #
fig = plt.figure()
spec = fig.add_gridspec(ncols=1, nrows=2, height_ratios=[4,1])
fig = plt.figure(figsize=[4, 6])
axes = [0,0]
axes[0] = fig.add_subplot(spec[1])
axes[1] = fig.add_subplot(spec[0], sharex=axes[0])

# select just the variables we want
temp = df.loc[df['variable'].isin(v4_list)].reset_index(drop=True)

# sort the variables in the correct order
temp['order'] = temp['variable'].apply(lambda x: landown_order.get(x))
temp = temp.sort_values(by="order", ascending=False).reset_index(drop=True)

# cycle through each coefficient to plot
for i in np.arange(temp["coef"].shape[0]):
    
    # put the first two coefficients in the smaller bottomt plot
    if i < 2:
        j = 0
        y = i

    # otherwise put the coefficient in the top plot
    else:
        j = 1
        y = i - 2

    # plot the coefficients
    axes[j].scatter(y=y, x=temp.loc[i, "coef"], s=40, marker="o", color=temp.loc[i, "color"])

# plot errorbars for the bottom plot
axes[0].errorbar(
    x=temp.loc[0:1,"coef"],
    y=np.arange(temp.loc[0:1,"coef"].shape[0]),
    xerr=temp.loc[0:1,"ci"],
    fmt="none",
    ecolor="black",
    capsize=2,
    mew=0.5,
    linewidth=0.5
)

# plot the errorbars for the top plot
axes[1].errorbar(
    x=temp.loc[2:temp.shape[0], "coef"],
    y=np.arange(temp.loc[2:temp.shape[0], "coef"].shape[0]),
    xerr=temp.loc[2:temp.shape[0],"ci"],
    fmt="none",
    ecolor="black",
    capsize=2,
    mew=0.5,
    linewidth=0.5
)

# axes settings
for i in [0,1]:
    axes[i].spines["top"].set_visible(False)
    axes[i].spines["right"].set_visible(False)
    axes[i].axvline(0, linestyle="--", linewidth=0.75, color="k")
    axes[i].grid(axis="x", linewidth=0.5, linestyle="--")

# plot-specific axes settings
axes[1].tick_params(axis='x', bottom=False, labelbottom=False)
axes[0].set_yticks(np.arange(temp.loc[0:1, "coef"].shape[0]))
axes[1].set_yticks(np.arange(temp.loc[2:temp.shape[0], "coef"].shape[0]))
axes[0].set_ylim([-0.25, 1.25])
axes[0].set_xlim([-0.05, 0.05])
axes[1].set_xlim([-0.05, 0.05])

# labels
labs = axes[0].set_yticklabels([landown_labels[x] for x in list(temp.loc[0:1, "variable"])], fontsize=9, color="#383838")
labs = axes[1].set_yticklabels([landown_labels[x] for x in list(temp.loc[2:temp.shape[0], "variable"])], fontsize=9, color="#383838")    

# titles
axes[1].set_title("Consumption (log)")
axes[0].set_xlabel("Normalized treatment effect", fontsize=12, labelpad=10)

# save
plt.savefig(f"{out}/land_ownership_coefplot_pres.png", bbox_inches="tight", dpi=200)
plt.close("all")
