# ESG Risk Analysis of S&P 500 Companies

**Author:** Sam Barati Dastjerdi  
**Institution:** University of Hertfordshire  
**Date:** May 2025  

---

## Overview

This project analyses ESG (Environmental, Social, and Governance) risk scores 
across S&P 500 companies using R. The analysis examines sector-level differences 
in ESG risk and investigates whether firm size predicts ESG performance.

**Data Source:** Sustainalytics ESG Risk Ratings (via Kaggle)  
**Sample:** 430 S&P 500 companies (after data cleaning)  
**Tools:** R 4.6, tidyverse, psych, broom, ggplot2

---

## Research Questions

1. Do ESG risk scores differ significantly across industry sectors?
2. Does firm size predict ESG risk score after controlling for sector?

---

## Key Findings

- ESG scores differ significantly across sectors (F = 27.98, p < .001)
- Energy sector has the highest mean ESG risk (32.3)
- Real Estate has the lowest mean ESG risk (13.1)
- Firm size does not significantly predict ESG score after sector controls (β = 0.13, p = .566)
- Sector explains 40% of variance in ESG scores (R² = .40)

---

## Project Structure
