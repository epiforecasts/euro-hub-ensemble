# Get model metadata
library(gh)
library(purrr)
library(yaml)

# Get all model names
models <- gh("/repos/covid19-forecast-hub-europe/covid19-forecast-hub-europe/contents/data-processed?recursive=1")
models <- unlist(transpose(models)$name)
models <- models[!grepl("schema.+yml", models)] # exclude hub schema files

# Get paths for metadata files
model_metadata_paths <- map_chr(models, ~ paste0("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-processed/", .x, "/metadata-", .x, ".txt"))

# Download metadata into single data frame
metadata <- map_dfr(model_metadata_paths, ~ read_yaml(.x))

rm(models, model_metadata_paths)
