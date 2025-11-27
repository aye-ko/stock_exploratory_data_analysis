# Stock Segmentation Analysis

## Project Overview

**Objective:** Conduct exploratory data analysis on 12 random stocks, to see if correlation is the same in sectors, and what is a good indication of mean returns, and make recommendations for different investor types. 

**Key Results:**
- Identified six distinct investor types using k-means clustering
- Discovered a stock that is a candidate for an options short in NKE

**Skills Demonstrated:** R Programming | Statistical Analysis | K-Means Clustering | API Integration | Rolling Averages | Error Handling | Data Visualization | Investment Strategy

---

## Business Problem

**Goal:** Conduct exploratory data analysis and translate findings into actionable business insights.

**Audience:**
- Analytics team (me)
- Investors

**Ask:**
- What stocks perform the best?
- Do sectors move together?
- What strategies can increase returns?
- What stocks are low performers?

**Business Task:** Identify high-value stocks for long-term investment, short-term day trading, and those for options shorting.

---

## Key Findings

The analysis revealed six distinct stock segments:

**Best Bang per Buck:**
- These are low-risk, high-reward, stable stocks with high returns, and are predictable for long-term investment.

**High Performers:** 
- Perform very well, ideal also for long-term investments.

**High Risk-Reward:** 
- Prone to drastic rises and falls, might be suitable for day traders and short-term options trading.

**Average Performers:**
- Not much to write home about, decent for portfolio diversity.

**Below Average Performers:** 
- Perform below the 30-day U.S Treasury Bond, not worth the risk, buy bonds instead.

**Disaster-Avoid:**
- Steady losses on average.
  
## Business Recommendations

- Based on findings, I recommend investing in the Best Bang per Buck for long-term investment growth, as well as High Performers.
- High Risk-Reward stocks have massive highs and lows, but are otherwise calm. This means you can be both bearish and bullish, if timed right, for high profit margins.
- Average Performers are predictable in their ups and downs, and are a candidate for day traders. 
- Below average performers, I have no recommendation on, but if they offer dividends, it might be worth the investment. Further research is needed.
- Disaster stocks are suitable for options shorts. They are on the decline and have been for the past year. 
---

## Technical Approach

**Tools Used:**
- R Studio for data cleaning, analysis, and visualization
- R Markdown for reproducible reporting

**Analysis Steps:**

**1. Descriptive Statistics**
- Calculated mean, median, and standard deviation for all numeric variables
- Analyzed distribution shapes using skewness and kurtosis

**2. Relationship Analysis**
- Correlation analysis between metrics of each stock.
- Sharpe Ratio has the most significant positive correlation with the mean returns. 

**3. Stock Segmentation**
- Standardized all numeric features using z-scores
- Applied k-means clustering (k=6) to identify stock groups


---

## Data Source

**Source:** Yahoo Finance via tidyquant library

**Data Quality Assessment (ROCCC):**
- **Reliable:** Direct from trusted Yahoo Finance via API request
- **Original:** Reports by the New York Stock Exchange
- **Comprehensive:** Contains all necessary variables for segmentation analysis
- **Current:** Static dataset (not real-time)
- **Cited:** Well-documented source

**Limitations:**
- The dataset contains 12 stocks
- Data is not dynamic/real-time
- Limited to a point-in-time snapshot

---

## Project Files

- **Live Report:** [View Analysis]()
- **R Markdown:** [index.Rmd]()
- **R Script:** [stock_analysis.R]()

---

## How to Run This Analysis

**Prerequisites:**
```r
# Install required packages
if(!require("tidyverse"))install.packages("tidyverse", dependencies = TRUE)
if(!require("tidyquant"))install.packages("tidyquant", dependencies = TRUE)
if(!require("e1071"))install.packages("e1071", dependencies = TRUE)
if(!require("corrplot"))install.packages("corrplot", dependencies = TRUE)
if(!require("DT"))install.packages("DT")
```

**Run the analysis:**
```r
# Load libraries
library(tidyverse)
library(tidyquant)
library(e1071)
library(corrplot)
library(DT)
# Render the report
rmarkdown::render("index.Rmd")
```

The analysis will generate an HTML report with all visualizations and findings.

---

## Data Cleaning Process

**Steps taken to ensure data integrity:**
1. Created a backup of the original raw data
2. Validated data types for all columns



**Documentation:** All cleaning steps are documented in the R Markdown file with inline comments.

---

## Author

**Onyedikachukwu Okonkwo**  
Data Analyst 

---

## Acknowledgments

This project was completed as part of building a professional data analytics portfolio. It was done to learn new skills and grow as an analyst. Special thanks to those on stackoverflow and discord who helped me debug. 
