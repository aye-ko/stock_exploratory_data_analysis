# SECTION 1: SETUP, LOADING PACKAGES AND DATA

# Install Packages
if(!require("tidyverse"))install.packages("tidyverse", dependencies = TRUE)
if(!require("tidyquant"))install.packages("tidyquant", dependencies = TRUE)
if(!require("e1071"))install.packages("e1071", dependencies = TRUE)
if(!require("corrplot"))install.packages("corrplot", dependencies = TRUE)
if(!require("DT"))install.packages("DT")
# Load Libraries
library(tidyverse)
library(tidyquant)
library(e1071)
library(corrplot)
library(DT)

#Create required Global Variables
tickers <- c("AAPL", "MSFT", "JPM", "V", "JNJ", "PFE", "WMT", "NKE", "XOM", "VZ", "T", "NEE")

# Load data from api using tidyquant
stock_data <- tq_get(
  tickers,
  from = "2024-11-17",
  to = "2025-11-17",
  get = "stock.prices"
)

# get DTB3 data with tryCatch to make sure that if no economic data it wont crash
risk_free_daily <- tryCatch(
  {treasury_bill_rate <- tq_get(
    "DTB3",
    get = "economic.data",
    from = (Sys.Date() - 30) # Get the last 30 days
  )
  risk_free_annual <- tail(treasury_bill_rate, 1)$price
  risk_free_daily <- risk_free_annual/ 249
  
  cat("3 Month U.S Treasury Bill Risk Free Annual: ", risk_free_annual, "\n")
  cat("Risk Free Daily: ", risk_free_daily, "\n")
  
  risk_free_daily
  },
  
  error = function(e) {
    cat("API down. Using fallback 3.9 Risk Free Annual", "\n")
    risk_free_daily = 0.01566
    
  }
  
)

# SECTION 2; CLEANING AND ORGANIZING DATA

# clean stock data and organize what I need symbol, data, adjusted and roll average
data <- stock_data %>%
  select(symbol, date, adjusted) %>%
  group_by(symbol) %>%
  mutate(return = (((adjusted - lag(adjusted))/ lag(adjusted)) * 100),
         roll_avg_20 = rollmean(adjusted, k =20, fill = NA, align = "right")
         )  # Calculate daily percentage return and rolling average
  

#optimize by removing stock data
rm(stock_data)

# SECTION 3: FUNCTIONS 

# Create Necessary Functions

# Function to plot the mean_return
line_plot <- function(ticker){ 
  
  ticker_data <- data %>% filter(symbol == ticker)
  ticker_summary <- summary_stats %>% filter(symbol == ticker)
  ticker_mean <- ticker_summary$mean_return
  ticker_median <- ticker_summary$median_return
  ticker_max <- ticker_data %>% filter(return == max(return, na.rm = TRUE))
  ticker_min <- ticker_data %>% filter(return == min(return, na.rm = TRUE))
    ggplot(ticker_data, aes(x = date, y = return)) +
    geom_line() +
    geom_point(data = ticker_max, aes(x = date, y = return), color = "purple", size = 3) +
    geom_point(data = ticker_min, aes(x = date, y = return), color = "blue", size = 3) +
    geom_hline(yintercept = ticker_mean, color = "red", linetype = "dashed", linewidth = 1) +
    geom_hline(yintercept = ticker_median, color = "green", linetype = "dashed", linewidth = 1) +
    labs(title = paste(ticker, "Return"),
         subtitle = "Red = Mean, Green = Median") +
    theme_minimal()
}

# Function to Plot Rolling average against adjusted values
rolling_average_plot <- function(ticker) {
  ticker_data <- data %>% filter(symbol == ticker) 
  ggplot(ticker_data, aes(x=date)) +
    geom_line(aes(y = adjusted), color = "black") +
    geom_line(aes(y = roll_avg_20), color = "red", linetype = "dashed") +
    labs(
      title = paste(ticker, "Price with 20-Day Moving Average"),
                    subtitle = "Black = Actual Adjusted Price, Red = 20-Day Average",
                    x = "Date",
                    y = "Price ($)") +
        theme_minimal()
}

# Validate Data
 # head(data)
 # str(data)
 # summary(data)
 # data %>% 
 #   filter(is.na(return)) %>%
 #   count(symbol)  # verify only the first day of each stock has no returns

# Mean, Median and SD (Return)

# SECTION 4: ANALYSIS

# Analyzing mean returns, volatility, skewness, kurtosis, and Sharpe Ratio
summary_stats <- data %>%
  group_by(symbol) %>%
  summarize(
    mean_return = mean(return, na.rm = TRUE),
    median_return = median(return, na.rm = TRUE), #average returns
    max_return = max(return, na.rm = TRUE),
    min_return = min(return, na.rm = TRUE),
    sd_return = sd(return, na.rm = TRUE), # Volatility higher the more volatile
    skewness = skewness(return, na.rm = TRUE), # Skewness Calculation: Performs better or worse than the mean average on a daily
    kurtosis = kurtosis(return, na.rm = TRUE),  # Kurtosis Calculation: Low kurtosis, moves predictatbly, High Kurtosis sudden drastic change
    sharpe_ratio_daily = ((mean_return - risk_free_daily)/sd_return), #calculate risk v. reward
    sharpe_ratio_annual = sharpe_ratio_daily * sqrt(249)  
  ) %>%
  arrange(desc(sharpe_ratio_annual),
          desc(mean_return),
          sd_return,
          desc(kurtosis),
          desc(skewness)
          
  )

# Analzying Correlation
corr_data <- summary_stats %>%
  select(where(is.numeric)) %>%
  cor()

# Cluster stocks for more in-depth analysis
cluster_data <- summary_stats %>%
  column_to_rownames("symbol") %>%
  select(mean_return, sd_return, skewness, kurtosis,sharpe_ratio_annual) %>%
  scale()  # get the z score for these columns

# Elbow method to determine center size
wss <- sapply(1:10, function(k) {
  set.seed(123)
  kmeans(cluster_data, centers = k)$tot.withinss
})

# Plot the elbow
plot(1:10, wss, type = "b", 
     xlab = "Number of Clusters (k)", 
     ylab = "Within-Cluster Sum of Squares",
     main = "Elbow Method for Optimal k")

set.seed(123) # makes results reproducible 

# From Elbow Method set center to 6
kmeans_result <- kmeans(cluster_data, centers =6)


# Add cluster assignment to summary_stats
summary_stats$cluster <- kmeans_result$cluster
summary_stats <- summary_stats %>%
  mutate(investor_type = case_when(
    cluster == 4 ~ "Best Bangs per Buck",
    cluster == 3 ~ "Below Average Performers",
    cluster == 2 ~ "Disaster - Avoid",
    cluster == 1 ~ "High Performers",
    cluster == 5 ~ "High Risk, Decent Return",
    cluster == 6 ~ "Average-Performers"
  ))

# Create table to analyze
cluster_summary_stats <- summary_stats %>%
  group_by(investor_type) %>%
  summarize(
    avg_mean_return = mean(mean_return),
    avg_sd_return = mean(sd_return),
    avg_skewness = mean(skewness),
    avg_kurtosis = mean(kurtosis),
    avg_sharpe = mean(sharpe_ratio_annual),
    stocks = paste(symbol, collapse = ", "),
    count = n()
  ) %>%
  arrange(desc(avg_sharpe))




# SECTION 5: DATA VISUALIZATION

# Plot returns, and Rolling average for each stock
for(ticker in unique(data$symbol)) {
  print(line_plot(ticker))
  print(rolling_average_plot(ticker))
} # use unique to keep it from duplicating multiple of same stock

# Risk Return Scatter Plot
risk_return_scatter_plot <- ggplot(summary_stats, aes(x = sd_return, y = mean_return, color = investor_type)) +
  geom_point(size = 3) +
  geom_text(aes(label = symbol), vjust = -1, hjust = -2, size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Risk-Return Scatter Plot",
       x = "Volatility (Standard Deviation %)",
       y = "Mean Daily Return %",
       color = "Investor Type") +
  theme_minimal()

# Correlation Heat Map
corrplot(corr_data, 
         method = "color",
         type = "upper",              # Show only upper triangle (less redundant)
         addCoef.col = "black",       # Add correlation numbers
         tl.col = "black",            # Text label color
         tl.cex = 0.8,                # Text label size
         number.cex = 0.5,            # Number size
         title = "Stock Metrics Correlation Matrix",
         mar = c(1, 1, 2, 1))         # Margins for title
