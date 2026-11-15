# Econometrics I Project: Exchange Rate Pass-Through Analysis (Sector 09)

This project contains the computational solution for the Econometrics I course assignment from the Institute of Economics at UFRJ. The main objective of this empirical analysis is to calculate the exchange rate pass-through to inflation in a specific sector of the economy (Sector 09), using time series econometric models.

## Project Files

*   **`Trabalho_Susan.R`**: The main R script containing the routine for data reading, model estimation, diagnostic tests, and data visualization.
*   **`Trab_setores_dados.xls`**: Excel file containing the macroeconomic and sectoral dataset used for estimations.

## Variables Used

The dataset is restricted to the first 200 observations and focuses on the following main variables:
*   **`setor09`**: Monthly percentage change in Sector 09 prices.
*   **`cambio`**: Monthly percentage change in the exchange rate (Reais per US Dollar, monthly average buy rate).
*   **`ibcbr`**: Monthly percentage change in the Central Bank of Brazil's Economic Activity Index (IBC-Br).
*   **`fev` to `dez`**: Indicator variables (dummies) used to isolate monthly seasonality.

## Dependencies and Prerequisites

To run the `Trabalho_Susan.R` script, you need to have the R environment installed, along with the following packages:
*   `readxl`: For importing data from the Excel spreadsheet.
*   `lmtest`: For running diagnostic tests, such as the Breusch-Pagan test and coeftest.
*   `sandwich`: For calculating the robust covariance matrix (HAC / Newey-West).
*   `car`: For performing linear hypothesis tests and model comparisons.
*   `ggplot2`: For advanced data visualization support (although the script extensively uses base R plots).

You can install the packages by uncommenting the line `install.packages(c("readxl", "lmtest", "sandwich", "car", "tseries", "ggplot2"))` at the beginning of the code.

## Analysis Structure and Methodology

The R script is methodologically organized around 8 fundamental steps required by the assignment guidelines:

1.  **Simple Regression and Visualization (Question 1)**: Estimation of an initial OLS model relating sector prices to the exchange rate and IBC-Br. Includes line charts to assess structural breaks and the temporal behavior of the variables.
2.  **Initial Diagnostic Tests (Question 2)**: Application of the Ljung-Box test (residual autocorrelation) and the Breusch-Pagan test (heteroskedasticity) to the first model.
3.  **Seasonality Modeling (Question 3)**: Re-estimation of the initial model incorporating 11 seasonal dummies (February to December) to mitigate recurring monthly effects.
4.  **Seasonal Model Diagnostics (Question 4)**: Repetition of the Ljung-Box and Breusch-Pagan tests on the updated model with seasonal effects.
5.  **Temporal Dynamics and Lags (Question 5)**: Expansion of the equation to include the lagged dependent variable (`setor09_l1`) and the lagged exchange rate variable (`cambio_l1`) at time t-1. This step explicitly calculates the short-term and long-term exchange rate pass-through.
6.  **Linear Restrictions Test (Question 6)**: Execution of an F-test (analysis of variance) to compare the fit of the restricted model (Question 3) against the unrestricted model (Question 5).
7.  **Unrestricted Model Diagnostics (Question 7)**: Final assessment of autocorrelation and heteroskedasticity in the residuals of the more complex model.
8.  **HAC Robust Errors (Question 8)**: Final estimation using the Newey-West correction (HAC) to ensure valid statistical inference in the presence of potential residual issues. The script features a bar chart comparing OLS versus HAC standard errors and discusses theoretical specification improvements (such as structural break testing and SARIMA).

## How to Run

1.  Ensure that the files `Trabalho_Susan.R` and `Trab_setores_dados.xls` are in the same working directory (folder).
2.  Open the `Trabalho_Susan.R` file in an IDE like RStudio or VS Code.
3.  Set the working directory to the folder where the files are located.
4.  Run the script step-by-step or entirely to generate the descriptive statistics, console statistical tests, and their respective plots.