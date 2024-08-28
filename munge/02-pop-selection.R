# Inclusion/exclusion criteria --------------------------------------------------------

flow <- flow[c(1:8, 10), 1:2]

names(flow) <- c("Criteria", "N")

flow <- rbind(c("General inclusion/exclusion criteria", ""), flow)

flow <- rbind(flow, c("Project specific inclusion/exclusion criteria", ""))

rsdata <- rsdata412 %>%
  filter(!is.na(shf_qol))
flow <- rbind(flow, c("Exclude posts with missing QoL", nrow(rsdata)))

rsdata <- rsdata %>%
  filter(!is.na(shf_ef_cat))
flow <- rbind(flow, c("Exclude posts with missing EF", nrow(rsdata)))

rsdata <- rsdata %>%
  group_by(lopnr) %>%
  arrange(shf_indexdtm) %>%
  slice(1) %>%
  ungroup()

flow <- rbind(flow, c("First post / patient", nrow(rsdata)))

rsdataexclude <- anti_join(rsdata412, rsdata, by = "lopnr")
rsdataexclude <- rsdataexclude %>%
  group_by(lopnr) %>%
  arrange(shf_indexdtm) %>%
  slice(1) %>%
  ungroup()

rm(rsdata412)
gc()
