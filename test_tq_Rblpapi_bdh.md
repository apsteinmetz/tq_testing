test\_tq\_Rblpapi
================
Art Steinmetz

testing Tidyquant Rblpapi integration
=====================================

validate some variations on <code>bdh()</code>

``` r
devtools::install_github("business-science/tidyquant")
```

    ## Skipping install of 'tidyquant' from a github remote, the SHA1 (81b67678) has not changed since last install.
    ##   Use `force = TRUE` to force installation

``` r
library(tidyverse)
```

    ## Warning: package 'tidyverse' was built under R version 3.4.2

    ## -- Attaching packages ---------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 2.2.1     v purrr   0.2.4
    ## v tibble  1.3.4     v dplyr   0.7.4
    ## v tidyr   0.7.2     v stringr 1.2.0
    ## v readr   1.1.1     v forcats 0.2.0

    ## Warning: package 'tibble' was built under R version 3.4.2

    ## Warning: package 'tidyr' was built under R version 3.4.2

    ## Warning: package 'purrr' was built under R version 3.4.2

    ## Warning: package 'dplyr' was built under R version 3.4.2

    ## -- Conflicts ------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(stringr)
library(dplyr)
library(lubridate)
```

    ## Warning: package 'lubridate' was built under R version 3.4.2

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:base':
    ## 
    ##     date

``` r
library(Rblpapi)
```

    ## Rblpapi version 0.3.6 using Blpapi headers 3.8.18.1 and run-time 3.8.18.1.

    ## Please respect the Bloomberg licensing agreement and terms of service.

``` r
library(tidyquant)
```

    ## Loading required package: PerformanceAnalytics

    ## Loading required package: xts

    ## Loading required package: zoo

    ## 
    ## Attaching package: 'zoo'

    ## The following objects are masked from 'package:base':
    ## 
    ##     as.Date, as.Date.numeric

    ## 
    ## Attaching package: 'xts'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     first, last

    ## 
    ## Attaching package: 'PerformanceAnalytics'

    ## The following object is masked from 'package:graphics':
    ## 
    ##     legend

    ## Loading required package: quantmod

    ## Warning: package 'quantmod' was built under R version 3.4.2

    ## Loading required package: TTR

    ## Warning: package 'TTR' was built under R version 3.4.2

    ## Version 0.4-0 included new data defaults. See ?getSymbols.

    ## 
    ## Attaching package: 'tidyquant'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     as_tibble

    ## The following object is masked from 'package:tibble':
    ## 
    ##     as_tibble

``` r
library(reprex)
```

    ## Warning: package 'reprex' was built under R version 3.4.2

``` r
library(Rblpapi)

# my tidy bdh wrapper as a control
art_tidy_bdh<-function(secs,...){
  blpConnect() #must have a valid blp session running
  blp_bdh  <-bdh(secs,...=...)
  blp_bdh_tq<-bind_rows(blp_bdh,.id='ticker') %>%
    mutate(sector=word(ticker,-1)) %>% 
    mutate(ticker=word(ticker,1)) %>% 
    select(date,ticker,everything())%>%
    group_by(sector,ticker)
  #special case of one ticker
  if (length(secs)==1){
    blp_bdh_tq$ticker=word(secs,1)
    blp_bdh_tq$sector=word(secs,-1)
  }
  
  return(blp_bdh_tq)
}
```

Use Rblpapi::bdh() directly

``` r
blpConnect()
my_bloomberg_data <- c('SPX Index','AGTHX Equity') %>%
  bdh(
    fields      = c("PX_LAST","TOT_RETURN_INDEX_GROSS_DVDS"),
    options     = c("periodicitySelection" = "MONTHLY"),
    start.date        = as.Date("2016-01-01"),
    end.date          = as.Date("2016-12-31")
  )

my_bloomberg_data
```

    ## $`SPX Index`
    ##          date PX_LAST TOT_RETURN_INDEX_GROSS_DVDS
    ## 1  2016-01-29 1940.24                    1940.240
    ## 2  2016-02-29 1932.23                    1937.517
    ## 3  2016-03-31 2059.74                    2068.869
    ## 4  2016-04-29 2065.30                    2076.904
    ## 5  2016-05-31 2096.96                    2114.097
    ## 6  2016-06-30 2098.86                    2119.557
    ## 7  2016-07-29 2173.60                    2197.635
    ## 8  2016-08-31 2170.95                    2200.734
    ## 9  2016-09-30 2168.27                    2201.125
    ## 10 2016-10-31 2126.15                    2161.000
    ## 11 2016-11-30 2198.81                    2240.918
    ## 12 2016-12-30 2238.83                    2285.077
    ## 
    ## $`AGTHX Equity`
    ##          date PX_LAST TOT_RETURN_INDEX_GROSS_DVDS
    ## 1  2016-01-29   38.19                     38.1900
    ## 2  2016-02-29   37.79                     37.7900
    ## 3  2016-03-31   40.24                     40.2400
    ## 4  2016-04-29   40.91                     40.9100
    ## 5  2016-05-31   41.77                     41.7700
    ## 6  2016-06-30   41.40                     41.4000
    ## 7  2016-07-29   43.21                     43.2100
    ## 8  2016-08-31   43.47                     43.4700
    ## 9  2016-09-30   44.08                     44.0800
    ## 10 2016-10-31   43.27                     43.2700
    ## 11 2016-11-30   44.53                     44.5300
    ## 12 2016-12-30   42.04                     44.8196

``` r
saveRDS(my_bloomberg_data,file="output_bdh.rds")
```

initial test

``` r
my_bloomberg_data <- c('SPX Index','AGTHX Equity') %>%
    tq_get(get         = "rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST","TOT_RETURN_INDEX_GROSS_DVDS"),
           options     = c("periodicitySelection" = "MONTHLY"),
           from        = "2016-01-01",
           to          = "2016-12-31")
my_bloomberg_data
```

    ## # A tibble: 24 x 4
    ##       symbol       date PX_LAST TOT_RETURN_INDEX_GROSS_DVDS
    ##        <chr>     <date>   <dbl>                       <dbl>
    ##  1 SPX Index 2016-01-29 1940.24                    1940.240
    ##  2 SPX Index 2016-02-29 1932.23                    1937.517
    ##  3 SPX Index 2016-03-31 2059.74                    2068.869
    ##  4 SPX Index 2016-04-29 2065.30                    2076.904
    ##  5 SPX Index 2016-05-31 2096.96                    2114.097
    ##  6 SPX Index 2016-06-30 2098.86                    2119.557
    ##  7 SPX Index 2016-07-29 2173.60                    2197.635
    ##  8 SPX Index 2016-08-31 2170.95                    2200.734
    ##  9 SPX Index 2016-09-30 2168.27                    2201.125
    ## 10 SPX Index 2016-10-31 2126.15                    2161.000
    ## # ... with 14 more rows

Use `start.date` and 'end.date' instead of `from/to`

``` r
my_bloomberg_data <- c('SPX Index','AGTHX Equity') %>%
    tq_get(get         = "rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST","TOT_RETURN_INDEX_GROSS_DVDS"),
           options     = c("periodicitySelection" = "MONTHLY"),
           start.date        = as.Date("2016-01-01"),
           end.date          = as.Date("2016-12-31")
           )
           

my_bloomberg_data
```

    ## # A tibble: 24 x 4
    ##       symbol       date PX_LAST TOT_RETURN_INDEX_GROSS_DVDS
    ##        <chr>     <date>   <dbl>                       <dbl>
    ##  1 SPX Index 2016-01-29 1940.24                    1940.240
    ##  2 SPX Index 2016-02-29 1932.23                    1937.517
    ##  3 SPX Index 2016-03-31 2059.74                    2068.869
    ##  4 SPX Index 2016-04-29 2065.30                    2076.904
    ##  5 SPX Index 2016-05-31 2096.96                    2114.097
    ##  6 SPX Index 2016-06-30 2098.86                    2119.557
    ##  7 SPX Index 2016-07-29 2173.60                    2197.635
    ##  8 SPX Index 2016-08-31 2170.95                    2200.734
    ##  9 SPX Index 2016-09-30 2168.27                    2201.125
    ## 10 SPX Index 2016-10-31 2126.15                    2161.000
    ## # ... with 14 more rows

``` r
#single security, single field bdh
my_bloomberg_data <- c('SPX Index') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "MONTHLY"),
           from        = "2016-01-01",
           to          = "2016-12-31"
           )
           

my_bloomberg_data
```

    ## # A tibble: 12 x 2
    ##          date PX_LAST
    ##  *     <date>   <dbl>
    ##  1 2016-01-29 1940.24
    ##  2 2016-02-29 1932.23
    ##  3 2016-03-31 2059.74
    ##  4 2016-04-29 2065.30
    ##  5 2016-05-31 2096.96
    ##  6 2016-06-30 2098.86
    ##  7 2016-07-29 2173.60
    ##  8 2016-08-31 2170.95
    ##  9 2016-09-30 2168.27
    ## 10 2016-10-31 2126.15
    ## 11 2016-11-30 2198.81
    ## 12 2016-12-30 2238.83

does omission of 'to' field default to sys.date?
================================================

``` r
# does omission of 'to' field default to sys.date?
my_bloomberg_data <- c('SPX Index') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "MONTHLY"),
           from        = "2017-01-01"
           )
           

my_bloomberg_data
```

    ## # A tibble: 10 x 2
    ##          date PX_LAST
    ##  *     <date>   <dbl>
    ##  1 2017-01-31 2278.87
    ##  2 2017-02-28 2363.64
    ##  3 2017-03-31 2362.72
    ##  4 2017-04-28 2384.20
    ##  5 2017-05-31 2411.80
    ##  6 2017-06-30 2423.41
    ##  7 2017-07-31 2470.30
    ##  8 2017-08-31 2471.65
    ##  9 2017-09-29 2519.36
    ## 10 2017-10-31 2575.26

Yes, it does!

Vary periodicity
================

``` r
#vary periodicity
my_bloomberg_data <- c('SPX Index','ODMAX Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "WEEKLY"),
           from        = "2016-01-01",
           to          = "2016-12-31"
           )
           

my_bloomberg_data
```

    ## # A tibble: 106 x 3
    ##       symbol       date PX_LAST
    ##        <chr>     <date>   <dbl>
    ##  1 SPX Index 2016-01-01 2043.94
    ##  2 SPX Index 2016-01-08 1922.03
    ##  3 SPX Index 2016-01-15 1880.33
    ##  4 SPX Index 2016-01-22 1906.90
    ##  5 SPX Index 2016-01-29 1940.24
    ##  6 SPX Index 2016-02-05 1880.05
    ##  7 SPX Index 2016-02-12 1864.78
    ##  8 SPX Index 2016-02-19 1917.78
    ##  9 SPX Index 2016-02-26 1948.05
    ## 10 SPX Index 2016-03-04 1999.99
    ## # ... with 96 more rows

``` r
#vary periodicity
my_bloomberg_data <- c('SPX Index','ODMAX Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "DAILY"),
           from        = "2016-01-01",
           to          = "2016-12-31"
           )
           

my_bloomberg_data
```

    ## # A tibble: 504 x 3
    ##       symbol       date PX_LAST
    ##        <chr>     <date>   <dbl>
    ##  1 SPX Index 2016-01-04 2012.66
    ##  2 SPX Index 2016-01-05 2016.71
    ##  3 SPX Index 2016-01-06 1990.26
    ##  4 SPX Index 2016-01-07 1943.09
    ##  5 SPX Index 2016-01-08 1922.03
    ##  6 SPX Index 2016-01-11 1923.67
    ##  7 SPX Index 2016-01-12 1938.68
    ##  8 SPX Index 2016-01-13 1890.28
    ##  9 SPX Index 2016-01-14 1921.84
    ## 10 SPX Index 2016-01-15 1880.33
    ## # ... with 494 more rows

mix sec types
=============

``` r
#mix sec types
my_bloomberg_data <- c('GT10 Govt','ODMAX Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "DAILY"),
           from        = "2016-01-01",
           to          = "2016-3-30"
           )
           

my_bloomberg_data
```

    ## # A tibble: 124 x 3
    ##       symbol       date PX_LAST
    ##        <chr>     <date>   <dbl>
    ##  1 GT10 Govt 2016-01-01   2.270
    ##  2 GT10 Govt 2016-01-04   2.244
    ##  3 GT10 Govt 2016-01-05   2.237
    ##  4 GT10 Govt 2016-01-06   2.171
    ##  5 GT10 Govt 2016-01-07   2.146
    ##  6 GT10 Govt 2016-01-08   2.116
    ##  7 GT10 Govt 2016-01-11   2.176
    ##  8 GT10 Govt 2016-01-12   2.104
    ##  9 GT10 Govt 2016-01-13   2.094
    ## 10 GT10 Govt 2016-01-14   2.088
    ## # ... with 114 more rows

show that sectype dates don't align due to varying holidays
===========================================================

not in scope of tidyquant
=========================

``` r
#show that sectype dates don't align due to varying holidays
# not in scope of tidyquant
my_bloomberg_data %>% 
  spread(symbol,PX_LAST) %>% 
  filter(is.na(`ODMAX Equity`))
```

    ## # A tibble: 4 x 3
    ##         date `GT10 Govt` `ODMAX Equity`
    ##       <date>       <dbl>          <dbl>
    ## 1 2016-01-01       2.270             NA
    ## 2 2016-01-18       2.036             NA
    ## 3 2016-02-15       1.749             NA
    ## 4 2016-03-25       1.901             NA

try some overrides from Rblpapi documentation
=============================================

``` r
#try some overrides from Rblpapi documentation
## example for an options field: request monthly data; see section A.2.4 of
## http://www.bloomberglabs.com/content/uploads/sites/2/2014/07/blpapi-developers-guide-2.54.pdf
## for more
opt <- c("periodicitySelection"="MONTHLY")
start.date=Sys.Date()-31*6

my_bloomberg_data <- c('SPY US Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST", "VOLUME"),
           options     = opt,
           from        = start.date
           )
           
my_bloomberg_data
```

    ## # A tibble: 6 x 3
    ##         date PX_LAST     VOLUME
    ## *     <date>   <dbl>      <dbl>
    ## 1 2017-05-31  241.44 1494800517
    ## 2 2017-06-30  241.80 1572752876
    ## 3 2017-07-31  246.77 1062993341
    ## 4 2017-08-31  247.49 1557031716
    ## 5 2017-09-29  251.23 1286405280
    ## 6 2017-10-31  257.15 1320624558

demonstrate that override parameter works as intended
-----------------------------------------------------

``` r
## example for options and overrides
opt <- c("periodicitySelection" = "QUARTERLY")
ovrd <- c("BEST_FPERIOD_OVERRIDE"="1GQ")
start.date=Sys.Date()-365.25
         
#no override
my_bloomberg_data <- c('IBM US Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("BEST_SALES"),
           options     = opt,
           #overrides   = ovrd,
           from        = start.date
           ) %>% 
  mutate(Override="No")

#with override
my_bloomberg_data <- c('IBM US Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("BEST_SALES"),
           options     = opt,
           overrides   = ovrd,
           from        = start.date
           ) %>% 
  mutate(Override="Yes") %>% 
  bind_rows(my_bloomberg_data)

#should show the effect of this override
my_bloomberg_data
```

    ## # A tibble: 8 x 3
    ##         date BEST_SALES Override
    ##       <date>      <dbl>    <chr>
    ## 1 2016-12-30   21744.69      Yes
    ## 2 2017-03-31   18381.19      Yes
    ## 3 2017-06-30   19472.61      Yes
    ## 4 2017-09-29   18582.94      Yes
    ## 5 2016-12-30   21689.60       No
    ## 6 2017-03-31   21615.75       No
    ## 7 2017-06-30   21803.47       No
    ## 8 2017-09-29   21835.18       No

test speed
==========

``` r
tq_way<-function(){
  my_bloomberg_data <- c('SPX Index','ODMAX Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "DAILY"),
           from        = "2006-01-01",
           to          = "2016-12-31"
           )
  my_bloomberg_data

}

direct_way<-function(){
  my_bloomberg_data <- c('SPX Index','ODMAX Equity') %>%
    bdh(   fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "DAILY"),
           start.date        = as.Date("2006-01-01"),
           end.date          = as.Date("2016-12-31")
           )
  my_bloomberg_data

}
my_way<-function(){
  my_bloomberg_data <- c('SPX Index','ODMAX Equity') %>%
    art_tidy_bdh(   fields      = c("PX_LAST"),
           options     = c("periodicitySelection" = "DAILY"),
           start.date        = as.Date("2006-01-01"),
           end.date          = as.Date("2016-12-31")
           )
  my_bloomberg_data

}
microbenchmark::microbenchmark(direct_way,tq_way(),my_way(),times=1)
```

    ## Unit: microseconds
    ##        expr        min         lq       mean     median         uq
    ##  direct_way      1.643      1.643      1.643      1.643      1.643
    ##    tq_way() 550661.801 550661.801 550661.801 550661.801 550661.801
    ##    my_way() 641966.434 641966.434 641966.434 641966.434 641966.434
    ##         max neval
    ##       1.643     1
    ##  550661.801     1
    ##  641966.434     1

``` r
system.time(direct_way())
```

    ##    user  system elapsed 
    ##    0.03    0.00    0.31

``` r
system.time(tq_way())
```

    ##    user  system elapsed 
    ##    0.08    0.00    0.59

``` r
system.time(my_way())
```

    ##    user  system elapsed 
    ##    0.29    0.00    0.61
