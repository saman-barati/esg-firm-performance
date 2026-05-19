# ═══════════════════════════════════════════════════════════
# Script 04 — Figures
# Project: ESG Performance & Firm Financial Outcomes
# Author: Sam Barati Dastjerdi
# Institution: University of Hertfordshire
# Date: May 2025
# ═══════════════════════════════════════════════════════════

library(tidyverse)

# ── Load clean data ──────────────────────────────────────────
clean_data <- read_csv("data/clean/esg_clean.csv",
                       show_col_types = FALSE) |>
  mutate(sector = as.factor(sector),
         esg_level = as.factor(esg_level))

cat("Creating figures...\n")

# ── Figure 1: ESG Score by Sector ───────────────────────────
fig1 <- clean_data |>
  group_by(sector) |>
  summarise(mean_esg = mean(esg_total),
            se = sd(esg_total) / sqrt(n())) |>
  ggplot(aes(x = reorder(sector, mean_esg),
             y = mean_esg, fill = sector)) +
  geom_col(width = 0.7, show.legend = FALSE) +
  geom_errorbar(aes(ymin = mean_esg - se,
                    ymax = mean_esg + se),
                width = 0.25) +
  coord_flip() +
  labs(
    title    = "Figure 1: Mean ESG Risk Score by Sector",
    subtitle = "S&P 500 Companies (n = 430) | Source: Sustainalytics",
    x        = NULL,
    y        = "Mean ESG Risk Score",
    caption  = "Higher score = Higher ESG risk"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title    = element_text(face = "bold"),
        plot.subtitle = element_text(color = "gray50"))

ggsave("output/figures/fig1_esg_by_sector.png",
       fig1, width = 8, height = 5, dpi = 300)
cat("✓ Figure 1 saved\n")

# ── Figure 2: ESG Risk Level Distribution ───────────────────
fig2 <- clean_data |>
  count(esg_level) |>
  mutate(esg_level = fct_reorder(esg_level, n)) |>
  ggplot(aes(x = esg_level, y = n, fill = esg_level)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = n), vjust = -0.5, size = 3.5) +
  labs(
    title    = "Figure 2: Distribution of ESG Risk Levels",
    subtitle = "S&P 500 Companies (n = 430)",
    x        = "ESG Risk Level",
    y        = "Number of Companies"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"))

ggsave("output/figures/fig2_esg_distribution.png",
       fig2, width = 7, height = 5, dpi = 300)
cat("✓ Figure 2 saved\n")

# ── Figure 3: E vs S vs G by Sector ─────────────────────────
fig3 <- clean_data |>
  group_by(sector) |>
  summarise(Environmental = mean(esg_env, na.rm = TRUE),
            Social        = mean(esg_soc, na.rm = TRUE),
            Governance    = mean(esg_gov, na.rm = TRUE)) |>
  pivot_longer(-sector,
               names_to  = "pillar",
               values_to = "score") |>
  ggplot(aes(x = reorder(sector, score),
             y = score, fill = pillar)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title    = "Figure 3: ESG Pillars by Sector",
    subtitle = "Environmental, Social, and Governance scores",
    x        = NULL,
    y        = "Mean Score",
    fill     = "ESG Pillar"
  ) +
  theme_minimal(base_size = 10) +
  theme(plot.title  = element_text(face = "bold"),
        legend.position = "bottom")

ggsave("output/figures/fig3_pillars_by_sector.png",
       fig3, width = 9, height = 6, dpi = 300)
cat("✓ Figure 3 saved\n")

cat("\n================================================================\n")
cat("✓ All figures saved to output/figures/\n")
cat("================================================================\n")