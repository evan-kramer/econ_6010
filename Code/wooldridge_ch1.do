clear all
set more off, perm
set type double, perm
capture log close
macro drop _all
program drop _all
estimates drop _all

/*
ECON 6010 - Wooldridge Chapter 1 Questions
Evan Kramer
9/13/2018
*/

* Macros and set up
cd "C:/Users/CA19130/Documents/Projects/ECON 6010"
use "Data/WAGE1", clear

* Average education 
summarize educ /* 12.56 years, min = 0, max = 18 */

* Average hourly wage
summarize wage /* $5.89; seems super low */


