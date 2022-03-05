Draft version: subproject commit e7a29254bd3984c3028506ca2074537b67afa2fe
Latest update = assess-ensembles branch

#=== Add submodule ===#

# Add submodule from a repo branch to directory: hub-data/assess-ensembles
git submodule add -b assess-ensembles https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe.git hub-data/assess-ensembles

# Initialise submodule
git submodule update --init

# Fetch updates from remote assess-ensembles branch
git submodule update --remote

# Edit submodule code
cd hub-data/assess-ensembles
git checkout main

# Commit changes fetched from remote
git add hub-data/assess-ensembles
git commit -m "Update submodule tracking to the latest commit"


#=== Remove submodule ===#
# Remove the submodule entry from .git/config
git submodule deinit -f hub-data\assess-ensembles

# Remove the submodule directory from the superproject's .git/modules directory
rm .git\modules\hub-data\assess-ensembles -r -f

# Remove the entry in .gitmodules and remove the submodule directory located at path/to/submodule
git rm -f hub-data\assess-ensembles

#======#
