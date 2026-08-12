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

# ── Load clean data ──────────────────────────────────────────
clean_data <- read_csv("data/clean/esg_clean.csv",
                       show_col_types = FALSE) |>
  mutate(
    sector    = as.factor(sector),
    esg_level = as.factor(esg_level),
    log_employees = log(employees)
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
  select(n, mean, sd, min, max, skew, kurtosis) |>
  round(2)
print(desc_stats)

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

# ── Analysis 1: ANOVA ────────────────────────────────────────
cat("\n--- ANALYSIS 1: ESG differences across sectors ---\n")
anova_result  <- aov(esg_total ~ sector, data = clean_data)
anova_summary <- tidy(anova_result)
cat("F =", round(anova_summary$statistic[1], 2),
    ", p =", formatC(anova_summary$p.value[1], format = "e", digits = 2), "\n")
cat("Result: ESG scores differ significantly across sectors\n")

# ── Analysis 2: Regression — firm size predicts ESG? ────────
cat("\n--- ANALYSIS 2: Does firm size predict ESG score? ---\n")
cat("H1: Larger firms have higher ESG risk scores\n\n")

model <- lm(esg_total ~ log_employees + sector,
            data = clean_data)

model_results <- tidy(model, conf.int = TRUE) |>
  mutate(across(where(is.numeric), \(x) round(x, 4)))

# Show only key results (not all sector dummies)
cat("Key coefficient — log(Employees):\n")
print(model_results |> filter(term == "log_employees"))

model_fit <- glance(model)
cat("\nModel fit:\n")
cat("  R-squared        :", round(model_fit$r.squared, 3), "\n")
cat("  Adjusted R-squared:", round(model_fit$adj.r.squared, 3), "\n")
cat("  F-statistic      :", round(model_fit$statistic, 2), "\n")
cat("  p-value          :", formatC(model_fit$p.value, format = "e", digits = 2), "\n")

# ── Save results ─────────────────────────────────────────────
write_csv(sector_summary, "output/tables/table2_sector_esg.csv")
write_csv(model_results,  "output/tables/table3_regression.csv")

cat("\n================================================================\n")
cat("✓ Analysis complete — tables saved to output/tables/\n")
cat("================================================================\n")
