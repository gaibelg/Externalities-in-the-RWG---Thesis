if (!require("pacman")) # A useful package for loading and installing other packages
  install.packages("pacman")

# This may take a few minutes
pacman::p_load("readr",  # A packge for dealing with CSVs
               "haven",
               "stats",
               "ggplot2",
               "ggthemes",
               "lfe", # For easy OLS with clustered errors
               "StatMeasures",
               "DescTools",
               "broom",
               "knitr",
               "dplyr") # For data manipulation

Full_Data <- read_dta('travel_subsidies.dta')

max_spells <- max(Full_Data$spells)

Full_Data <- Full_Data[rep(1:nrow(Full_Data),each=max_spells),] %>%
  group_by(jskid) %>%
  mutate(t = row_number(), 
         alloc_monthyear = as.Date(as.character(alloc_monthyear*100 +1), format="%Y%m%d")) 

Full_Data$real_time <- AddMonths(Full_Data$alloc_monthyear,Full_Data$t - 1)

Full_Data <- Full_Data %>%
  group_by(t) %>%
  mutate(appeared = as.numeric(get(paste0("apr",t)))) %>%
  select(-c(starts_with("apr"))) %>%
  mutate(apr = appeared)

Full_Data <- Full_Data %>%
  group_by(jskid) %>%
  mutate(num_apr_12 = sum(apr[which(t<=12)]))

WF <- read_dta('locality_IES_merged.dta')
WF$month <- gsub("-", "",WF$month)
WF$real_time <- as.Date(as.character(as.numeric(WF$month)*100 +1), format="%Y%m%d")
WF$month <- NULL
WF$t <- NULL
WF$code <- as.numeric(WF$code)
Full_Data <- left_join(Full_Data,WF,by=c("real_time","code"))


save(Full_Data,file = "Program_Data.Rdata")