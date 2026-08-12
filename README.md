# ESG Risk Analysis of S&P 500 Companies

**Saman Barati Dastjerdi** · University of Hertfordshire · May 2025

A self-directed empirical project in R examining whether ESG risk is a sector-level phenomenon or a firm-level one.

---

## Overview

This project analyses Sustainalytics ESG risk scores across S&P 500 companies in R. It tests two claims: that ESG risk differs systematically across industry sectors, and that larger firms — having more compliance capacity — carry lower ESG risk. The first holds strongly. The second does not hold at all.

| | |
|---|---|
| **Data source** | Sustainalytics ESG Risk Ratings (via Kaggle) |
| **Sample** | 430 firms with a valid ESG score; 426 in the regression |
| **Tools** | R 4.6 · tidyverse · psych · broom · ggplot2 |
| **Methods** | Brown-Forsythe · Welch's ANOVA · Tukey HSD · OLS with nested model comparison |

---

## Research questions

1. Do ESG risk scores differ significantly across industry sectors?
2. Does firm size predict ESG risk score, before or after controlling for sector?

---

## Key findings

**Sector matters, and it matters a great deal.**

Sector standard deviations range from 2.62 (Real Estate) to 7.12 (Industrials), a 2.7-fold spread, so the equal-variance assumption behind the classical one-way ANOVA fails: Brown-Forsythe **W = 4.16, p < .001**. Welch's ANOVA, which does not assume equal variances, is therefore the primary test:

- **Welch's ANOVA: F(10, 122.1) = 44.19, p < .001**
- Classical one-way ANOVA, reported for comparison: F(10, 419) = 27.98, p < .001
- Energy carries the highest mean ESG risk (**32.3**); Real Estate the lowest (**13.1**)
- Tukey HSD finds 38 of 55 pairwise sector comparisons significant at α = .05, though these are exploratory given the variance violation

**Firm size does not matter.**

- Size alone: **β = 0.25, p = .291**, R² = .003
- Size controlling for sector: **β = 0.13, p = .566**, 95% CI [−0.32, 0.58]
- Sector alone explains **R² = .400** of the variance; adding size raises this to .4005, a change of **ΔR² = .0005**
- Nested model test: **F(1, 414) = 0.33, p = .566**

The null result is reported as found. A common assumption in ESG commentary is that larger firms, having more compliance resources, carry lower ESG risk. In this sample the coefficient is not merely insignificant but slightly *positive*, and the confidence interval spans zero comfortably. Once sector is known, firm size adds essentially nothing. This points to ESG risk in these ratings being substantially structural — a property of what an industry does — rather than managerial.

---

## Figures

### Mean ESG risk score by sector

![Mean ESG risk by sector](figures/fig1_esg_by_sector.png)

Bars show sector means with standard error. Higher score = higher ESG risk.

### Distribution of ESG risk levels

![Distribution of ESG risk levels](figures/fig2_esg_distribution.png)

### Environmental, Social and Governance pillars by sector

![ESG pillars by sector](figures/fig3_pillars_by_sector.png)

Decomposing the total score shows that the sector ranking is driven largely by the Environmental pillar, while Governance varies far less across sectors.

---

## Project structure

```
esg-firm-performance/
│
├── 01_data_download.R      Load raw ratings and inspect structure
├── 02_data_clean.R         Rename, filter missing scores, derive esg_clean.csv
├── 03_analysis.R           Descriptives, assumption checks, ANOVA, OLS
├── 04_figures.R            Generate the three figures above
│
├── data/                   Source data (not tracked — see below)
│
├── figures/                Exported PNG figures
│   ├── fig1_esg_by_sector.png
│   ├── fig2_esg_distribution.png
│   └── fig3_pillars_by_sector.png
│
├── results/                Derived result tables
│   ├── table1_descriptives.csv
│   ├── table2_sector_esg.csv
│   ├── table3_regression.csv
│   └── table4_tukey.csv
│
├── .gitignore
├── LICENSE
└── README.md
```

Scripts are numbered and run in order. Each writes its output to disk and creates the directories it needs, so any stage can be re-run independently.

The tables in `results/` are the derived output of the analysis, so every number quoted above can be checked without re-running anything.

**A note on the data.** The source ratings are Sustainalytics data obtained via Kaggle and are not redistributed here, since the licence governing them is not mine to extend. `data/` is git-ignored for that reason. The reproduction steps below explain how to obtain the file.

---

## How to reproduce

1. Clone the repository.
2. Obtain the Sustainalytics ESG Risk Ratings dataset from Kaggle and place `SP 500 ESG Risk Ratings.csv` in `data/raw/`.
3. Run the scripts in order:

   ```r
   source("01_data_download.R")
   source("02_data_clean.R")
   source("03_analysis.R")
   source("04_figures.R")
   ```

Requires R 4.6 or later and the packages listed above.

---

## Notes and limitations

- **Single-provider construct.** ESG ratings are known to correlate imperfectly across providers, so the sector effect reported here should be read as a finding about the Sustainalytics methodology rather than about ESG risk in the abstract.
- **Cross-sectional.** The data are a single snapshot. They cannot distinguish a persistent sector effect from one rating cycle, and no causal claim is made.
- **Size proxy.** Firm size is measured by log full-time employees, the only size variable in the dataset. Headcount is a poor proxy for asset base or market capitalisation, so the null result on size is a null for *this* proxy and not a general one.
- **Missing data.** Four firms lack an employee count and are dropped from the regression, leaving 426. The sector analyses use all 430.
- **Unequal variances.** Welch's ANOVA handles this for the omnibus test, but Tukey HSD does not, so the pairwise comparisons are reported as exploratory.

---

## Licence

MIT — see `LICENSE`.
