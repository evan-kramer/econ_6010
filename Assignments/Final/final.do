clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Final
Evan Kramer
12/6/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
insheet using "Data/web.csv", clear

* Create time and percent change variables
gen t = _n
gen t2 = t^2
tsset t
gen pct_change_hits = 100 * (hits - hits[_n-1]) / hits[_n-1]

* Plot results and drop outliers
//twoway scatter hits t, title("Website Hits over Time") ytitle("Hits") xtitle("Time")
drop if hits >= 35000 // drop what appear to be outliers
//twoway scatter pct_change_hits t, title("Percent Change in Website Hits over Time") ytitle("Hits (% Change)") xtitle("Time")

* Test data to see if unit root is present (p > 0.05)
dfuller hits
pperron hits
//dfuller pct_change_hits
//pperron pct_change_hits

* ARIMA model
//arima hits, arima(1, 0, 0) // autocorrelation in the lags
//arima hits, arima(2, 0, 0) // still autocorrelation in the lags
//arima hits, arima(3, 0, 0) // still autocorrelation in the lags
//arima hits, arima(1, 1, 0) // still autocorrelation in the lags
// arima hits, arima(1, 2, 0) // still autocorrelation in the lags
arima hits, arima(1, 0, 1) // no autocorrelation in the lags, but coefficient is close to 1
//arima hits, arima(1, 0, 2) // moving average(2) coefficient not significant
//arima hits, arima(1, 0, 3) // same as above
//arima hits, arima(1, 1, 1) // neither AR nor MA coefficient significant

* Model specification tests
predict r, resid
predict yhat
estat ic
corrgram r
ac r
pac r
//twoway scatter r t, sort yline(0)
//twoway scatter hits yhat t
dwstat
swilk r
sktest r
kdensity r, normal

* Prediction accuracy
egen mfe = total(r - yhat) // n
egen mad = total(abs(r - yhat)) // n
egen rsfe = total(r - yhat)
