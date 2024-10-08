# Cut outcomes at 1 years

rsdata <- cut_surv(rsdata, sos_out_hosphf, sos_outtime_hosphf, global_followup, cuttime = TRUE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_hospany, sos_outtime_hospany, global_followup, cuttime = TRUE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_deathcv, sos_outtime_death, global_followup, cuttime = FALSE, censval = "No")
rsdata <- cut_surv(rsdata, sos_out_death, sos_outtime_death, global_followup, cuttime = TRUE, censval = "No")

rsdata <- rsdata %>%
  mutate(
    censdtm = pmin(shf_indexdtm + global_followup, censdtm),
    shf_indexyear_cat = factor(case_when(
      shf_indexyear <= 2010 ~ "2000-2010",
      shf_indexyear <= 2015 ~ "2011-2015",
      shf_indexyear <= 2021 ~ "2016-2021"
    )),
    shf_bpsys_cat = factor(
      case_when(
        shf_bpsys < 140 ~ 1,
        shf_bpsys >= 140 ~ 2
      ),
      levels = 1:2, labels = c("<140", ">=140")
    ),
    shf_qol_cat = forcats::fct_rev(shf_qol_cat),
    shf_age_cat = factor(case_when(
      shf_age <= 75 ~ 0,
      shf_age > 75 ~ 1
    ), levels = 0:1, labels = c("<=75", ">75")),
    scb_education = factor(
      case_when(
        is.na(scb_education) ~ NA_real_,
        scb_education %in% c("Compulsory school", "Secondary school") ~ 1,
        scb_education %in% c("University") ~ 2
      ),
      levels = 1:2, labels = c("Compulsory/secondary school", "University")
    ),
    # comp risk outcomes
    sos_out_deathcv_cr = create_crevent(sos_out_deathcv, sos_out_death, eventvalues = c("Yes", "Yes")),
    sos_out_hosphf_cr = create_crevent(sos_out_hosphf, sos_out_death, eventvalues = c("Yes", "Yes")),
    sos_out_hospany_cr = create_crevent(sos_out_hospany, sos_out_death, eventvalues = c("Yes", "Yes"))
  )

## Create numeric variables needed for comp risk model
rsdata <- create_crvar(rsdata, "shf_qol_cat")

# income
inc <- rsdata %>%
  reframe(incsum = list(enframe(quantile(scb_dispincome,
    probs = c(0.50),
    na.rm = TRUE
  ))), .by = shf_indexyear) %>%
  unnest(cols = c(incsum)) %>%
  pivot_wider(names_from = name, values_from = value)

rsdata <- left_join(
  rsdata,
  inc,
  by = "shf_indexyear"
) %>%
  mutate(
    scb_dispincome_cat = factor(
      case_when(
        scb_dispincome < `50%` ~ 1,
        scb_dispincome >= `50%` ~ 2
      ),
      levels = 1:2,
      labels = c("<median within year", ">=median within year")
    )
  ) %>%
  select(-`50%`)

# ntprobnp

nt <- rsdata %>%
  reframe(ntmed = list(enframe(quantile(shf_ntprobnp,
    probs = c(0.50),
    na.rm = TRUE
  ))), .by = shf_ef_cat) %>%
  unnest(cols = c(ntmed)) %>%
  pivot_wider(names_from = name, values_from = value)

rsdata <- left_join(
  rsdata,
  nt,
  by = "shf_ef_cat"
) %>%
  mutate(
    shf_ntprobnp_cat = factor(
      case_when(
        shf_ntprobnp < `50%` ~ 1,
        shf_ntprobnp >= `50%` ~ 2
      ),
      levels = 1:2,
      labels = c("<median within EF", ">=median within EF")
    )
  ) %>%
  select(-`50%`)

rsdata <- rsdata %>%
  mutate(across(where(is_character), factor))


rsdataexclude <- rsdataexclude %>%
  mutate(
    shf_indexyear_cat = factor(case_when(
      shf_indexyear <= 2010 ~ "2000-2010",
      shf_indexyear <= 2015 ~ "2011-2015",
      shf_indexyear <= 2021 ~ "2016-2021"
    )),
    shf_bpsys_cat = factor(
      case_when(
        shf_bpsys < 140 ~ 1,
        shf_bpsys >= 140 ~ 2
      ),
      levels = 1:2, labels = c("<140", ">=140")
    ),
    shf_qol_cat = forcats::fct_rev(shf_qol_cat),
    shf_age_cat = factor(case_when(
      shf_age <= 75 ~ 0,
      shf_age > 75 ~ 1
    ), levels = 0:1, labels = c("<=75", ">75")),
    scb_education = factor(
      case_when(
        is.na(scb_education) ~ NA_real_,
        scb_education %in% c("Compulsory school", "Secondary school") ~ 1,
        scb_education %in% c("University") ~ 2
      ),
      levels = 1:2, labels = c("Compulsory/secondary school", "University")
    )
  )

rsdataexclude <- bind_rows(
  rsdata %>% mutate(incexc = 0),
  rsdataexclude %>% mutate(incexc = 1),
) %>%
  mutate(incexc = factor(incexc, levels = 0:1, labels = c("Included", "Excluded")))

# any(duplicated(rsdataexclude$lopnr))

# income
inc <- rsdataexclude %>%
  reframe(incsum = list(enframe(quantile(scb_dispincome,
                                         probs = c(0.50),
                                         na.rm = TRUE
  ))), .by = shf_indexyear) %>%
  unnest(cols = c(incsum)) %>%
  pivot_wider(names_from = name, values_from = value)

rsdataexclude <- left_join(
  rsdataexclude,
  inc,
  by = "shf_indexyear"
) %>%
  mutate(
    scb_dispincome_cat = factor(
      case_when(
        scb_dispincome < `50%` ~ 1,
        scb_dispincome >= `50%` ~ 2
      ),
      levels = 1:2,
      labels = c("<median within year", ">=median within year")
    )
  ) %>%
  select(-`50%`)

# ntprobnp

nt <- rsdataexclude %>%
  reframe(ntmed = list(enframe(quantile(shf_ntprobnp,
                                        probs = c(0.50),
                                        na.rm = TRUE
  ))), .by = shf_ef_cat) %>%
  unnest(cols = c(ntmed)) %>%
  pivot_wider(names_from = name, values_from = value)

rsdataexclude <- left_join(
  rsdataexclude,
  nt,
  by = "shf_ef_cat"
) %>%
  mutate(
    shf_ntprobnp_cat = factor(
      case_when(
        shf_ntprobnp < `50%` ~ 1,
        shf_ntprobnp >= `50%` ~ 2
      ),
      levels = 1:2,
      labels = c("<median within EF", ">=median within EF")
    )
  ) %>%
  select(-`50%`)

rsdataexclude <- rsdataexclude %>%
  mutate(across(where(is_character), factor))
