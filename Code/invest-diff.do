clear

insheet using E:\invest.csv

egen t=fill (1 2)
gen tsq=t^2

tsset t

* twoway connect f t

***gen new capital stock value


*** gen nnatural logs

gen lnf=ln(f)
gen lni=ln(i)
gen lnc=ln(c)

*** try 1
/*
reg lni lnf lncn

predict r, resid

ovtest
hettest
sktest r
kdensity r, normal
durbina
*/


** gen lags

gen llni=L.lni
gen l2lni=L.llni
gen l3lni=L.l2lni

gen llnc=L.lnc
gen l2lnc=L.llnc
gen l3lnc=l2lnc

gen llnf=L.lnf
gen l2lnf=L.llnf
gen l3lnf=L.l2lnf


*** gen IV

gen dlnf=lnf-llnf
gen dlni=lni-llni
gen dlnc=lnc-llnc

gen d2lnf=llnf-l2lnf
gen d2lni=llni-l2lni
gen d2lnc=llnc-l2lnc

gen d3lnf=l2lnf-l3lnf
gen d3lni=l2lni-l3lni
gen d3lnc=l2lnc-l3lnc

gen dtf=dlnf*t
gen dt2f=d2lnf*t
gen dt3f=d3lnf*t

gen dti=dlni*t
gen dt2i=d2lni*t
gen dt3i=d3lni*t

gen dtc=dlnc*t
gen dt2c=d2lnc*t
gen dt3c=d3lnc*t

gen llnisq=lni^2
gen l2lnisq=l2lni^2
gen l3lnisq=l3lni^2


gen lncsq=lnc^2
gen llncsq=llnc^2
gen l2lncsq=l2lnc^2
gen l3lncsq=l3lnc^2


gen tlnf=lnf*t
gen t1lnf=llnf*t
gen t2lnf=l2lnf*t
gen tlnisq=lni*t
gen t1lnisq=llni*t
gen t2lnisq=l2lni*t

gen tlncsq=lnc*t
gen t1lncsq=llnc*t
gen t2lncsq=l2lnc*t


gen dumout=0

replace dumout=1 if t==21
replace dumout=1 if t==61
replace dumout=1 if t==81
replace dumout=1 if t==99
replace dumout=1 if t==121
replace dumout=1 if t==161
replace dumout=1 if t==142
replace dumout=1 if t==181

*** gen dummies

gen WWII=0
replace WWII=1 if year>=1939 & year<1946 

gen KW=0
replace KW=1 if year>=1950 & year<=1953

gen dep=0
replace dep=1 if year>=1935 & year<1940


gen firmvhigh=0
replace firmvhigh=1 if f>4000

/*
gen firmhigh=0
replace firmhigh=1 if f>3000 & f<=5000

gen firmumid=0
replace firmumid=1 if f>1500 & f<=3000

gen firmmid=0
replace firmmid=1 if f>1000 & f<=1500

gen firmlmid=0
replace firmlmid=1 if f>=100 & f<=1000
*/
gen firmlow=0
replace firmlow=1 if f<100


reg dlnf d3lni d2lnc WWII KW firmlow  

predict r, resid
drop if r<-0.5
twoway connect r t, sort yline(0)
ovtest
hettest
sktest  r
swilk r
*qnorm r
*kdensity r, normal
dwstat

