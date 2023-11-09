import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd

sys.path.insert(0, os.getcwd())
from canals_config import out, cdata, tmp

# set some master parameters to make the font look good
mpl.rcParams['mathtext.fontset'] = 'custom'
mpl.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
mpl.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
mpl.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
mpl.rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
mpl.rc('text', usetex=True)
mpl.rcParams['figure.dpi'] = 200

# import data
df = pd.read_stata(f"{cdata}/canal_construction_data.dta")

# cut data into years
bins = np.arange(1845, 2030, 5)
df['yr_grp'] = pd.cut(df["year_completed"], bins, labels=bins[1:len(bins)])

# replace endpoint
df.loc[df['year_completed'] <= 1850, 'yr_grp'] = 1850

# ongoing
df.loc[df['year_completed'] > 2013, 'yr_grp'] = 2025

# unknown
df.loc[df['year_completed'] == 9998, 'yr_grp'] = 2020
df.loc[df['year_completed'].isnull(), 'yr_grp'] = 2020

# groupby year group
df_plot = df.groupby("yr_grp").agg({"SHAPE_Leng": np.sum}).rename(columns={"SHAPE_Leng": "Total Length"})

# sort by project to get average length per project
temp = df.sort_values(by="yr_grp", ascending=False)
temp = temp.groupby("project_name").agg({"SHAPE_Leng": np.sum, "yr_grp": "first"})
temp["Number"] = 1
temp = temp.groupby("yr_grp").agg({"SHAPE_Leng": np.mean, "Number": np.sum}).rename(columns={"SHAPE_Leng": "Mean Length"})

#merge together
df_plot = df_plot.merge(temp, left_index=True, right_index=True)

# convert to km (from m)
df_plot["Total Length"] = df_plot["Total Length"] / 1000
df_plot["Mean Length"] = df_plot["Mean Length"] / 1000

# save
df_plot.to_csv(f"{tmp}/canal_length_time.csv")

# print percentage of canal length we don't know the date or is under construction
n_unknown = df_plot.loc[2020, "Total Length"].sum() / df_plot['Total Length'].sum()
n_ongoing = df_plot.loc[2025, "Total Length"].sum() / df_plot['Total Length'].sum()
print("{:.1%} canal length unknown completion date".format(n_unknown))
print("{:.1%} canal length ongoing as of 2013".format(n_ongoing))

# PLOT
df = pd.read_csv(f"{tmp}/canal_length_time.csv")
df = df.rename(columns={"yr_grp": "Year"})
df = df.drop(df.loc[df["Year"] > 2015].index)

f, ax = plt.subplots(figsize=[9,4])
ax.bar(x=df["Year"], height=df["Total Length"], width=5, color="#011652")

# axes settings
ax.set_xlim([1850, 2020])
ax.tick_params(axis='y', colors="#011652")
ax.set_ylabel('Total Length (km)', color="#011652", labelpad=15)
ax.set_xlabel("Year of Completion")

# set the title
title = "canal_completion_time.png"
outfp = f"{out}/{title}"
plt.savefig(outfp, bbox_inches="tight")
plt.close("all")
