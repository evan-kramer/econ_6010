clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Week 11
Evan Kramer
11/15/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
insheet using "Data/EUROstar04.csv", clear

* Create time variable
gen t = _n
gen t2 = t^2

* Plot results
//twoway connect eurostar t // appears seasonal (~10-15 periods)

* Initial regression
regress eurostar t
regress eurostar t2
regress eurostar t t2

* Dummies for seasonality
gen d1 = inlist(t, 4, 5, 6)
gen d2 = inlist(t, 12, 13, 14, 24)

* Second regression
regress eurostar t d2

* Third regression
regress eurostar t2 d2

* Fourth regression
regress eurostar t d1 d2

* Fifth regression
regress eurostar t t2 d1 d2 // t not significant

* Sixth regression
regress eurostar d*

* Plot fitted values
predict r, resid
predict yhat
//twoway connect eurostar yhat t

* Second dataset
insheet using "Data/RSALES.csv", clear

* Generate time variable
gen t = _n
gen t2 = t^2
gen t3 = t^3
tsset t

* Generate IVs and lags
gen ln_rsales = ln(rsales)

* Dummies
gen d1 = inlist(t, 396, 397, 157)

* Plot data
//twoway scatter rsales t

* First models
regress rsales t
regress rsales t t2
regress rsales t*
regress rsales t*

* Plot fitted values
//predict r, resid
//predict yhat
//twoway connect rsales yhat t

* Model specification tests
ovtest
hettest
sktest r
swilk r
tsset t //t2
dwstat

* ARIMA model
arima ln_rsales, arima(1, 0, 0) // 1 indicates the first lag is significant

* Test model
predict r, resid
predict yhat
corrgram r
ac r
pac r
