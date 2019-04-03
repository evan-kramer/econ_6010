clear

insheet using E:\6010\data\bp.csv

egen t=fill(1 2)


*graph twoway connect bloodpressure t


*************regress using linear trend***************

reg bloodpressure age

predict r,resid
*twoway connect r t, sort yline(0)


ovtest
hettest
sktest r
tsset t
dwstat

*kdensity r,normal 
