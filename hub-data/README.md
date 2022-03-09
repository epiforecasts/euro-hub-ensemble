Draft version = subproject commit e7a29254bd3984c3028506ca2074537b67afa2fe

Latest update = assess-ensembles branch

```
#=== Add submodule ===#

# Add submodule from a repo branch to directory:
##  add & init hub-data/assess-ensembles
git submodule add -b assess-ensembles https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe.git hub-data/assess-ensembles
git submodule update --init hub-data/assess-ensembles

## add & init hub-data/updated-evaluations
git submodule add -b updated-evaluations https://github.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe.git hub-data/updated-evaluations
git submodule update --init hub-data/updated-evaluations

# Fetch updates from remote branch
git submodule update --remote hub-data/updated-evaluations

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
```
