# report
library(rmarkdown)
library(kableExtra)

# data import/export
library(haven)
library(openxlsx)

# general dm
library(purrr)
library(dplyr)
library(tidyr)
library(tibble)
library(stringr)
library(lubridate)
library(forcats)
library(hfmisc)
library(here)

# desk stat
library(tableone)

# plots
library(ggplot2)
library(ggrepel)
library(patchwork)
library(scales)
library(tidysdm) # split violin

# outcomes
library(survival)
library(cmprsk)
library(epitools)
library(survminer) # check assumptions
library(splines)
library(nnet) # for multinominal regression

# imputation
library(mice)
library(miceadds)
library(parallel)
library(doParallel)
library(foreach)
