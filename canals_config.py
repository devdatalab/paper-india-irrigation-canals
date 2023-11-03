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
ccode = [x.split("ccode")[1].strip() for x in text if "ccode" in x][0]
cdata = [x.split("cdata")[1].strip() for x in text if "cdata" in x and "cdata_all" not in x][0]
cdata_all = [x.split("cdata_all")[1].strip() for x in text if "cdata_all" in x][0]
out = [x.split("out")[1].strip() for x in text if "out" in x][0]
tmp = [x.split("tmp")[1].strip() for x in text if "tmp" in x][0]

# ensure all filepaths are absolute without the home directory ~
ccode = os.path.expanduser(ccode)
cdata = os.path.expanduser(cdata)
cdata_all = os.path.expanduser(cdata_all)
out = os.path.expanduser(out)
tmp = os.path.expanduser(tmp)
