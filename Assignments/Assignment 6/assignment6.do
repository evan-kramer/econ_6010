clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Assignment 6
Evan Kramer
11/29/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
insheet using "Data/caemp.csv", clear

* Natural log
gen ln_caemp = ln(caemp)

* Create time variable
gen t = _n
gen t2 = t^2

* Plot results
//twoway connect ln_caemp t // appears seasonal (~10-15 periods)

* ARIMA model
tsset t
arima ln_caemp, arima(1, 0, 0) // 1 indicates the first lag is significant
arima ln_caemp, arima(2, 0, 0) 
arima ln_caemp, arima(2, 0, 1)
arima ln_caemp, arima(1, 0, 1)
//arima ln_caemp, arima(5, 0, 1)

* Test model
predict r, resid
predict yhat
twoway connect ln_caemp yhat t
corrgram r
ac r
pac r

* Test model
egen mfe = total(r - yhat) // n
egen mad = total(abs(r - yhat)) // n
egen rsfe = total(r - yhat)
dfuller ln_caemp, lags(2) trend
pperron ln_caemp
estat ic
wntestq r, lags(2)

