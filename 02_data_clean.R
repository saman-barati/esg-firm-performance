# ═══════════════════════════════════════════════════════════
# Script 02 — Data Cleaning
# Project: ESG Performance & Firm Financial Outcomes
# Author: Sam Barati Dastjerdi
# Institution: University of Hertfordshire
# Date: May 2025
# ═══════════════════════════════════════════════════════════

library(tidyverse)

# ── Load raw data ────────────────────────────────────────────
raw_data <- read_csv("data/raw/SP 500 ESG Risk Ratings.csv",
                     show_col_types = FALSE)

cat("================================================================\n")
cat("Script 02 — Data Cleaning\n")
cat("Raw data: ", nrow(raw_data), "companies\n")
cat("================================================================\n")

# ── Step 1: Rename columns (remove spaces) ───────────────────
clean_data <- raw_data |>
  rename(
    symbol        = Symbol,
    name          = Name,
    sector        = Sector,
    industry      = Industry,
    employees     = `Full Time Employees`,
    esg_total     = `Total ESG Risk score`,
    esg_env       = `Environment Risk Score`,
    esg_gov       = `Governance Risk Score`,
    esg_soc       = `Social Risk Score`,
    controversy   = `Controversy Level`,
    esg_level     = `ESG Risk Level`
  ) |>
  select(symbol, name, sector, industry, employees,
         esg_total, esg_env, esg_gov, esg_soc,
         controversy, esg_level)

# ── Step 2: Remove rows with missing ESG score ───────────────
cat("\nMissing ESG scores before cleaning:", 
    sum(is.na(clean_data$esg_total)), "\n")

clean_data <- clean_data |>
  filter(!is.na(esg_total))

cat("Companies after removing missing:", nrow(clean_data), "\n")

# ── Step 3: Fix sector as factor ─────────────────────────────
clean_data <- clean_data |>
  mutate(
    sector      = as.factor(sector),
    esg_level   = as.factor(esg_level),
    controversy = as.factor(controversy)
  )

# ── Step 4: Summary check ────────────────────────────────────
cat("\nSectors in dataset:\n")
print(table(clean_data$sector))

cat("\nESG Risk Levels:\n")
print(table(clean_data$esg_level))

cat("\nESG Score Summary:\n")
print(summary(clean_data$esg_total))

# ── Step 5: Save clean data ──────────────────────────────────
write_csv(clean_data, "data/clean/esg_clean.csv")

cat("\n================================================================\n")
cat("✓ Clean data saved: data/clean/esg_clean.csv\n")
cat("  Companies:", nrow(clean_data), "\n")
cat("  Columns  :", ncol(clean_data), "\n")
cat("================================================================\n")