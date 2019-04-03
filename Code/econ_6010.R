# ECON 6010
# Evan Kramer
# 8/30/2018

options(java.parameters = "-Xmx16G")
library(tidyverse)
library(lubridate)
library(haven)
library(RJDBC)

# Set up
setwd("C:/Users/CA19130/Documents/Projects/ECON 6010")

# Chapter 1

# Chapter 2
# 2.3 
d = read_dta("Data/CEOSAL1.dta")
l = lm(data = d, salary ~ roe)
predict(l, data.frame(roe = 30)) # predict salary from model when roe = 30
predict(l, data.frame(roe = 0))
rm(l, d)

# 2.4
d = read_dta("Data/WAGE1.dta")
l = lm(data = d, wage ~ educ)
predict(l, data.frame(educ = 8)) * 19.06 / 5.9 # how much in 2003 dollars (5.90 = 19.06)
rm(d, l)

# 2.5
d = read_dta("Data/VOTE1.dta")
l = lm(data = d, voteA ~ shareA)
predict(l, data.frame(shareA = 60))
rm(d, l)

# 2.10
d = read_dta("Data/WAGE1.dta")
l = lm(data = d, log(wage) ~ educ)
summary(l) # taking log of dependent variable only gives the percent change in y 
rm(d, l)

# 2.11
d = read_dta("Data/CEOSAL1.dta")
l = lm(data = d, log(salary) ~ log(sales))
summary(l) # interpretation: a 1% increase in sales yields a 0.26% increase in CEO salary
rm(d, l)




d = readxl::read_excel("Data/invest.xls")
ggplot(d, aes(y = `F`, x = I, col = factor(FIRM))) + 
  geom_point()

