test\_tq\_Rblpapi
================
Art Steinmetz

testing Tidyquant Rblpapi integration
=====================================

Just a start. More validation to do.

``` r
devtools::install_github("business-science/tidyquant")
```

    ## Skipping install of 'tidyquant' from a github remote, the SHA1 (fc654641) has not changed since last install.
    ##   Use `force = TRUE` to force installation

``` r
library(tidyverse)
```

    ## -- Attaching packages ---------------------------------- tidyverse 1.2.1 --

    ## v tibble  1.3.4     v purrr   0.2.4
    ## v tidyr   0.7.2     v stringr 1.2.0
    ## v readr   1.1.1     v forcats 0.2.0

    ## Warning: package 'tibble' was built under R version 3.4.1

    ## Warning: package 'tidyr' was built under R version 3.4.2

    ## Warning: package 'purrr' was built under R version 3.4.2

    ## -- Conflicts ------------------------------------- tidyverse_conflicts() --
    ## x dplyr::arrange()   masks plyr::arrange()
    ## x purrr::compact()   masks plyr::compact()
    ## x dplyr::count()     masks plyr::count()
    ## x dplyr::failwith()  masks plyr::failwith()
    ## x dplyr::filter()    masks stats::filter()
    ## x dplyr::first()     masks xts::first()
    ## x dplyr::id()        masks plyr::id()
    ## x dplyr::lag()       masks stats::lag()
    ## x dplyr::last()      masks xts::last()
    ## x dplyr::mutate()    masks plyr::mutate()
    ## x dplyr::rename()    masks plyr::rename()
    ## x dplyr::summarise() masks plyr::summarise()
    ## x dplyr::summarize() masks plyr::summarize()

``` r
library(stringr)
library(dplyr)
library(lubridate)
```

    ## Warning: package 'lubridate' was built under R version 3.4.2

    ## 
    ## Attaching package: 'lubridate'

    ## The following object is masked from 'package:plyr':
    ## 
    ##     here

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

    ## Loading required package: quantmod

    ## Warning: package 'quantmod' was built under R version 3.4.2

    ## Loading required package: TTR

    ## Warning: package 'TTR' was built under R version 3.4.1

    ## Version 0.4-0 included new data defaults. See ?getSymbols.

    ## 
    ## Attaching package: 'tidyquant'

    ## The following object is masked from 'package:tibble':
    ## 
    ##     as_tibble

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     as_tibble

``` r
library(reprex)
```

    ## Warning: package 'reprex' was built under R version 3.4.2

``` r
#don't forget to connect!
# I build it into my version of bdh
Rblpapi::blpConnect()

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

Here is the sample from your github issue comment

``` r
my_bloomberg_data <- c('SPX Index','AGTHX Equity') %>%
    tq_get(get         = "rblpapi",
           rblpapi_fun = "bdh",
           fields      = c('RETURN','PRICE'),
           options     = c("periodicitySelection" = "MONTHLY"),
           from        = "2016-01-01",
           to          = "2016-12-31")
```

    ## Warning: package 'bindrcpp' was built under R version 3.4.1

    ## Warning: x = 'SPX Index', get = 'Rblpapi': Error in bdh_Impl(con, securities, fields, start.date, end.date, options, : Bad field: RETURN
    ## 
    ##  Removing SPX Index.

    ## Warning: x = 'AGTHX Equity', get = 'Rblpapi': Error in bdh_Impl(con, securities, fields, start.date, end.date, options, : Bad field: RETURN
    ## 
    ##  Removing AGTHX Equity.

    ## Warning in value[[3L]](cond): Returning as nested data frame.

Obvious issues.

Invalid fields. Valid would be <code>LAST\_PRICE</code> and <code>TOT\_RETURN\_INDEX\_GROSS\_DVDS</code>. That is not the responsibility of tq\_get.

<code>from</code> and <code>to</code> need to be <code>start.date</code> and <code>end.date</code> to be passed to bdh and need to be valid dates, not character strings.

Let's try to fix.

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
    ##  2 SPX Index 2016-02-29 1932.23                    1937.626
    ##  3 SPX Index 2016-03-31 2059.74                    2069.066
    ##  4 SPX Index 2016-04-29 2065.30                    2077.092
    ##  5 SPX Index 2016-05-31 2096.96                    2114.384
    ##  6 SPX Index 2016-06-30 2098.86                    2119.872
    ##  7 SPX Index 2016-07-29 2173.60                    2198.020
    ##  8 SPX Index 2016-08-31 2170.95                    2201.113
    ##  9 SPX Index 2016-09-30 2168.27                    2201.524
    ## 10 SPX Index 2016-10-31 2126.15                    2161.364
    ## # ... with 14 more rows

Eureka! So it works. Do you want to be consistent with other get sources in nomenclature or be true to each separate api?

``` r
my_bloomberg_data <- c('SPX Index','AGTHX Equity') %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdh",
           fields      = c("PX_LAST","TOT_RETURN_INDEX_GROSS_DVDS"),
           options     = c("periodicitySelection" = "MONTHLY"),
           from        = "2016-01-01",
           to          = "2016-12-31"
           )
           

my_bloomberg_data
```

    ## # A tibble: 24 x 4
    ##       symbol       date PX_LAST TOT_RETURN_INDEX_GROSS_DVDS
    ##        <chr>     <date>   <dbl>                       <dbl>
    ##  1 SPX Index 2016-01-29 1940.24                    1940.240
    ##  2 SPX Index 2016-02-29 1932.23                    1937.626
    ##  3 SPX Index 2016-03-31 2059.74                    2069.066
    ##  4 SPX Index 2016-04-29 2065.30                    2077.092
    ##  5 SPX Index 2016-05-31 2096.96                    2114.384
    ##  6 SPX Index 2016-06-30 2098.86                    2119.872
    ##  7 SPX Index 2016-07-29 2173.60                    2198.020
    ##  8 SPX Index 2016-08-31 2170.95                    2201.113
    ##  9 SPX Index 2016-09-30 2168.27                    2201.524
    ## 10 SPX Index 2016-10-31 2126.15                    2161.364
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
