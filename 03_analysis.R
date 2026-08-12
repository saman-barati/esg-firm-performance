# ═══════════════════════════════════════════════════════════
# Script 03 — Statistical Analysis
# Project: ESG Performance & Firm Financial Outcomes
# Author: Saman Barati Dastjerdi
# Institution: University of Hertfordshire
# Date: May 2025
# ═══════════════════════════════════════════════════════════

library(tidyverse)
library(psych)
library(broom)

dir.create("results", showWarnings = FALSE)

# ── Load clean data ──────────────────────────────────────────
clean_data <- read_csv("data/clean/esg_clean.csv",
                       show_col_types = FALSE) |>
  mutate(
    sector    = as.factor(sector),
    esg_level = as.factor(esg_level),
    log_employees = if_else(employees > 0, log(employees), NA_real_)
  )

cat("================================================================\n")
cat("Script 03 — Statistical Analysis\n")
cat("Companies:", nrow(clean_data), "\n")
cat("================================================================\n")

# ── Table 1: Descriptive Statistics ─────────────────────────
cat("\n--- TABLE 1: Descriptive Statistics ---\n")
desc_stats <- clean_data |>
  select(esg_total, esg_env, esg_gov, esg_soc) |>
  describe() |>
  as.data.frame() |>
  rownames_to_column("variable") |>
  select(variable, n, mean, sd, min, max, skew, kurtosis) |>
  mutate(across(where(is.numeric), \(x) round(x, 2)))
print(desc_stats)
write_csv(desc_stats, "results/table1_descriptives.csv")

# ── Table 2: ESG by Sector ───────────────────────────────────
cat("\n--- TABLE 2: Mean ESG Score by Sector ---\n")
sector_summary <- clean_data |>
  group_by(sector) |>
  summarise(
    n        = n(),
    mean_esg = round(mean(esg_total), 2),
    sd_esg   = round(sd(esg_total), 2),
    mean_env = round(mean(esg_env, na.rm = TRUE), 2),
    mean_gov = round(mean(esg_gov, na.rm = TRUE), 2),
    mean_soc = round(mean(esg_soc, na.rm = TRUE), 2)
  ) |>
  arrange(desc(mean_esg))
print(sector_summary, n = 20)
write_csv(sector_summary, "results/table2_sector_esg.csv")

# ── Assumption check: homogeneity of variance ────────────────
# Brown-Forsythe test: one-way ANOVA on absolute deviations
# from the group median. Robust to non-normality, unlike Bartlett.
cat("\n--- ASSUMPTION CHECK: homogeneity of variance ---\n")
bf_data <- clean_data |>
  group_by(sector) |>
  mutate(abs_dev = abs(esg_total - median(esg_total))) |>
  ungroup()
bf_test <- tidy(aov(abs_dev ~ sector, data = bf_data))
cat("Brown-Forsythe: W =", round(bf_test$statistic[1], 3),
    ", p =", formatC(bf_test$p.value[1], format = "e", digits = 2), "\n")

sd_range <- range(sector_summary$sd_esg)
cat("Sector SDs range from", sd_range[1], "to", sd_range[2],
    "(ratio", round(sd_range[2] / sd_range[1], 1), "x)\n")
cat("=> Equal-variance assumption is violated; Welch's test is used below.\n")

# ── Analysis 1: sector differences in ESG risk ───────────────
cat("\n--- ANALYSIS 1: ESG differences across sectors ---\n")

welch <- oneway.test(esg_total ~ sector, data = clean_data, var.equal = FALSE)
cat("Welch's ANOVA (primary test):\n")
cat("  F(", round(welch$parameter[1], 0), ",",
    round(welch$parameter[2], 1), ") =", round(welch$statistic, 2),
    ", p =", formatC(welch$p.value, format = "e", digits = 2), "\n")

classic <- tidy(aov(esg_total ~ sector, data = clean_data))
cat("Classical one-way ANOVA (reported for comparison):\n")
cat("  F(", classic$df[1], ",", classic$df[2], ") =",
    round(classic$statistic[1], 2),
    ", p =", formatC(classic$p.value[1], format = "e", digits = 2), "\n")
cat("Both tests agree: ESG risk differs significantly across sectors.\n")

# ── Post-hoc: which sectors differ? ──────────────────────────
cat("\n--- POST-HOC: Tukey HSD (exploratory) ---\n")
tukey <- TukeyHSD(aov(esg_total ~ sector, data = clean_data))
tukey_tbl <- as.data.frame(tukey$sector) |>
  rownames_to_column("comparison") |>
  rename(p_adj = `p adj`) |>
  mutate(across(where(is.numeric), \(x) round(x, 4))) |>
  arrange(p_adj)
cat("Significant pairwise differences:",
    sum(tukey_tbl$p_adj < 0.05), "of", nrow(tukey_tbl), "\n")
print(head(tukey_tbl, 10))
write_csv(tukey_tbl, "results/table4_tukey.csv")
cat("Note: Tukey assumes equal variances, which the Brown-Forsythe test\n")
cat("rejects. These pairwise results are exploratory, not confirmatory.\n")

# ── Analysis 2: does firm size predict ESG risk? ─────────────
cat("\n--- ANALYSIS 2: Does firm size predict ESG risk? ---\n")
cat("A resource-based argument predicts that larger firms, having more\n")
cat("compliance capacity, carry LOWER ESG risk. Tested two-sided.\n\n")

model_data <- clean_data |> filter(!is.na(log_employees))
cat("Regression sample:", nrow(model_data), "firms (",
    nrow(clean_data) - nrow(model_data), "dropped for missing employee counts )\n\n")

m_size   <- lm(esg_total ~ log_employees, data = model_data)
m_sector <- lm(esg_total ~ sector,        data = model_data)
m_full   <- lm(esg_total ~ log_employees + sector, data = model_data)

model_results <- tidy(m_full, conf.int = TRUE) |>
  mutate(across(where(is.numeric), \(x) round(x, 4)))

cat("Size alone:\n")
print(tidy(m_size) |> filter(term == "log_employees") |>
        mutate(across(where(is.numeric), \(x) round(x, 4))))
cat("\nSize controlling for sector:\n")
print(model_results |> filter(term == "log_employees"))

cat("\nModel comparison:\n")
cat("  Size only        R2 =", round(glance(m_size)$r.squared, 4), "\n")
cat("  Sector only      R2 =", round(glance(m_sector)$r.squared, 4), "\n")
cat("  Sector + size    R2 =", round(glance(m_full)$r.squared, 4),
    " (adj R2 =", round(glance(m_full)$adj.r.squared, 4), ")\n")
cat("  Change in R2 from adding size:",
    round(glance(m_full)$r.squared - glance(m_sector)$r.squared, 4), "\n")

cat("\nNested model test (does size add explanatory power?):\n")
print(tidy(anova(m_sector, m_full)) |>
        mutate(across(where(is.numeric), \(x) round(x, 4))))

cat("\nConclusion: firm size does not predict ESG risk, with or without\n")
cat("sector controls. The resource-based expectation is not supported.\n")

write_csv(model_results, "results/table3_regression.csv")

cat("\n================================================================\n")
cat("✓ Analysis complete — tables saved to results/\n")
cat("================================================================\n")
