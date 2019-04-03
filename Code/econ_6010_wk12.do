clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Week 12
Evan Kramer
11/29/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
insheet using "Data/caemp.csv", clear

* Create time variable
gen t = _n
gen t2 = t^2
tsset t

* Test data to see if unit root is present (p > 0.05)
dfuller caemp
pperron caemp

* Create percent change to attempt to address unit root problem
gen pct_change_caemp = 100 * (caemp - caemp[_n-1]) / caemp[_n-1]

* Plot results
//twoway scatter pct_change_caemp t

* Drop outliers
drop if inlist(t, 105, 125)

* Re-test data -- unit root is gone
dfuller pct_change_caemp
pperron pct_change_caemp

* ARIMA model
arima pct_change_caemp, arima(1, 0, 0) // 1 indicates the first lag is significant, moving average is zero because we already calculated the percent change
arima pct_change, ar(1) // same result with different syntax because there is no integrative behavior and no moving average

* Test model
predict r, resid
predict yhat
corrgram r
ac r
pac r
dwstat
swilk r
sktest r
kdensity r, normal
twoway connect r pct_change_caemp t, sort yline(0)
