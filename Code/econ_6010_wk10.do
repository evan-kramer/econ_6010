clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Week 10
Evan Kramer
11/8/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"

* Read in data
insheet using "Data/wdi.csv", clear

* Clean data
replace value = "" if value == ".."
destring value, replace
replace seriesname = "annual_gdp_growth" if seriesname == "GDP per capita growth (annual %)"
replace seriesname = "gross_fixed_capital" if seriesname == "Gross fixed capital formation (% of GDP)"
replace seriesname = "pop_growth_annual" if seriesname == "Population growth (annual %)"
replace seriesname = "trade_pct_gdp" if seriesname == "Trade (% of GDP)"
replace seriesname = "gov_exp_edu" if regexm(seriesname, "Government expenditure")

* Reshape wide
drop if seriesname == ""
reshape wide value, i(countryname time) j(seriesname) string

* Label and rename variables
rename countryname country
encode country, gen(c)

* Natural logs and lags
foreach v in annual_gdp_growth gross_fixed_capital pop_growth_annual trade_pct_gdp gov_exp_edu {
	rename value`v' `v' 
	gen ln_`v' = ln(`v')
}

* Switch for Europe, Latin America
gen dum_la = inlist(country, "Argentina", "Brazil", "Chile", "Colombia", "Ecuador", "El Salvador", "Nicaragua", "Panama", "Uruguay")
replace dum_la = 1 if country == "Venezuela, RB"
gen dum_eur = inlist(country, "Austria", "Belgium", "France", "Germany", "Italy", "Netherlands", "Norway", "Portugal", "Spain") 
replace dum_eur = 1 if country == "United Kingdom"

keep if dum_la == 1 

* Create groups for fixed effects
xtset c time
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual ln_trade_pct_gdp ln_gov_exp_edu, fe
xtreg ln_annual_gdp_growth ln_gross_fixed_capital ln_pop_growth_annual, fe

exit

* Does the same thing as xtset
egen country_group = group(country)
bysort country_group: gen trend = mod(_n, _N + 1)
tsset country_group time



/*
egen var_groups = group(var)
bysort var_groups: gen trend = mod(_n, _N + 1)
tsset var_groups t
keep if region == 1
*/
