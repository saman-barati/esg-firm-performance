# ═══════════════════════════════════════════════════════════
# Script 01 — Data Import
# Project: ESG Performance & Firm Financial Outcomes
# Author: Saman Barati Dastjerdi
# Institution: University of Hertfordshire
# Date: May 2025
# Source: S&P 500 ESG Risk Ratings (Kaggle / Sustainalytics)
# ═══════════════════════════════════════════════════════════

library(tidyverse)

# ── Load raw data ────────────────────────────────────────────
raw_data <- read_csv("data/raw/SP 500 ESG Risk Ratings.csv")

# ── First look ───────────────────────────────────────────────
cat("================================================================\n")
cat("Dataset : S&P 500 ESG Risk Ratings\n")
cat("Rows    :", nrow(raw_data), "\n")
cat("Columns :", ncol(raw_data), "\n")
cat("================================================================\n")

# ── Column names ─────────────────────────────────────────────
cat("\nColumn names:\n")
print(names(raw_data))

# ── First 6 rows ─────────────────────────────────────────────
cat("\nFirst 6 companies:\n")
print(head(raw_data, 6))
