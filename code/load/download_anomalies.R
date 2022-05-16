# Download dataset of anomalies
library(readr)
here::i_am("code/load/download_anomalies.R")

download_anomalies <- function() {
  anomalies <- read_csv("https://raw.githubusercontent.com/covid19-forecast-hub-europe/covid19-forecast-hub-europe/main/data-truth/anomalies/anomalies.csv",
                        progress = FALSE, show_col_types = FALSE)
  return(anomalies)
}
