test\_tq\_Rblpapi\_bds
================
Art Steinmetz

testing Tidyquant Rblpapi integration
=====================================

validate some variations on <code>bdp()</code>

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
library(Rblpapi)
secs<-c("DODFX US Equity",
        "DODGX US Equity",
        "DODIX US Equity",
        "DODWX US Equity",
        "SPX Index",
        "LBUSTRUU Index")
```

show output from Rblpapi::bdp()
===============================

NA output for index tickers is correct.

``` r
blpConnect()
my_fields<- c("FUND_MGR_STATED_FEE",
              "FUND_EXPENSE_RATIO",
              "FUND_TOTAL_ASSETS")

my_bloomberg_data <- secs %>% bdp(
           fields  = my_fields
           )

my_bloomberg_data
```

    ##                 FUND_MGR_STATED_FEE FUND_EXPENSE_RATIO FUND_TOTAL_ASSETS
    ## DODFX US Equity                 0.6               0.64         65455.613
    ## DODGX US Equity                 0.5               0.52         68443.773
    ## DODIX US Equity                 0.4               0.43         52413.539
    ## DODWX US Equity                 0.6               0.63          9255.162
    ## SPX Index                        NA                 NA                NA
    ## LBUSTRUU Index                   NA                 NA                NA

``` r
saveRDS(my_bloomberg_data,file='output_bdp.rds')
```

initial test
============

single security, single data point

``` r
# Get BBG Descriptive Data

my_bloomberg_data <- secs[1] %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           fields      = c("FUND_MGR_STATED_FEE")
           )

my_bloomberg_data
```

    ## # A tibble: 1 x 1
    ##   FUND_MGR_STATED_FEE
    ## *               <dbl>
    ## 1                 0.6

multiple security, single data point
====================================

``` r
my_bloomberg_data <- secs %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           fields      = c("FUND_MGR_STATED_FEE")
           )

my_bloomberg_data
```

    ## # A tibble: 6 x 2
    ##            symbol FUND_MGR_STATED_FEE
    ##             <chr>               <dbl>
    ## 1 DODFX US Equity                 0.6
    ## 2 DODGX US Equity                 0.5
    ## 3 DODIX US Equity                 0.4
    ## 4 DODWX US Equity                 0.6
    ## 5       SPX Index                  NA
    ## 6  LBUSTRUU Index                  NA

multiple security, multiple data point
======================================

``` r
my_fields<- c("FUND_MGR_STATED_FEE",
              "FUND_EXPENSE_RATIO",
              "FUND_TOTAL_ASSETS")

my_bloomberg_data <- secs %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           fields      = my_fields
           )

my_bloomberg_data
```

    ## # A tibble: 6 x 4
    ##            symbol FUND_MGR_STATED_FEE FUND_EXPENSE_RATIO FUND_TOTAL_ASSETS
    ##             <chr>               <dbl>              <dbl>             <dbl>
    ## 1 DODFX US Equity                 0.6               0.64         65455.613
    ## 2 DODGX US Equity                 0.5               0.52         68443.773
    ## 3 DODIX US Equity                 0.4               0.43         52413.539
    ## 4 DODWX US Equity                 0.6               0.63          9255.162
    ## 5       SPX Index                  NA                 NA                NA
    ## 6  LBUSTRUU Index                  NA                 NA                NA

try some overrides
==================

``` r
my_fields=c("CURRENT_TRR_1YR","PEER_RANKING","FUND_BENCHMARK_PRIM")
my_bloomberg_data <- secs %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           #overrides = ovr, #without override default period is 1Y
           fields      = my_fields
           )

my_bloomberg_data
```

    ## # A tibble: 6 x 4
    ##            symbol CURRENT_TRR_1YR PEER_RANKING FUND_BENCHMARK_PRIM
    ##             <chr>           <dbl>        <int>               <chr>
    ## 1 DODFX US Equity       25.455420           65                MXEA
    ## 2 DODGX US Equity       15.665860           52                 SPX
    ## 3 DODIX US Equity        4.606240           77            LBUSTRUU
    ## 4 DODWX US Equity       20.471380           35                M1WO
    ## 5       SPX Index       20.590790           NA                    
    ## 6  LBUSTRUU Index        3.311082           NA

``` r
my_fields=c("CURRENT_ANN_TRR_3YR","PEER_RANKING","FUND_BENCHMARK_PRIM")
ovr<-c("PEER_RANKING_PERIOD"='3Y')
my_bloomberg_data <- secs %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           overrides = ovr,
           fields      = my_fields
           )

my_bloomberg_data
```

    ## # A tibble: 6 x 4
    ##            symbol CURRENT_ANN_TRR_3YR PEER_RANKING FUND_BENCHMARK_PRIM
    ##             <chr>               <dbl>        <int>               <chr>
    ## 1 DODFX US Equity            4.137208           24                MXEA
    ## 2 DODGX US Equity            9.401031           86                 SPX
    ## 3 DODIX US Equity            3.055207           81            LBUSTRUU
    ## 4 DODWX US Equity            7.299826           73                M1WO
    ## 5       SPX Index           10.176840           NA                    
    ## 6  LBUSTRUU Index            2.393554           NA

``` r
my_fields=c("CURRENT_ANN_TRR_5YR","PEER_RANKING","FUND_BENCHMARK_PRIM")
ovr<-c("PEER_RANKING_PERIOD"='5Y')
my_bloomberg_data <- secs %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           overrides = ovr,
           fields      = my_fields
           )

my_bloomberg_data
```

    ## # A tibble: 6 x 4
    ##            symbol CURRENT_ANN_TRR_5YR PEER_RANKING FUND_BENCHMARK_PRIM
    ##             <chr>               <dbl>        <int>               <chr>
    ## 1 DODFX US Equity            9.777702           66                MXEA
    ## 2 DODGX US Equity           16.324170           98                 SPX
    ## 3 DODIX US Equity            3.063700           86            LBUSTRUU
    ## 4 DODWX US Equity           13.774270           95                M1WO
    ## 5       SPX Index           15.584350           NA                    
    ## 6  LBUSTRUU Index            2.040308           NA

deliberate errors
=================

Bad security ticker

``` r
bad_sec = "some nonsense"
my_fields=c("CURRENT_ANN_TRR_5YR","PEER_RANKING","FUND_BENCHMARK_PRIM")
ovr<-c("PEER_RANKING_PERIOD"='5Y')
my_bloomberg_data <- bad_sec %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           overrides = ovr,
           fields      = my_fields
           )

my_bloomberg_data
```

    ## # A tibble: 1 x 3
    ##   CURRENT_ANN_TRR_5YR PEER_RANKING FUND_BENCHMARK_PRIM
    ## *               <dbl>        <int>               <chr>
    ## 1                  NA           NA

empty table. No error message. Suggests verbose=TRUE.

now try a bad field.

``` r
my_fields=c("blah blah")
ovr<-c("PEER_RANKING_PERIOD"='5Y')
my_bloomberg_data <- secs %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           overrides = ovr,
           fields      = my_fields
           )
```

    ## Warning: x = 'DODFX US Equity', get = 'Rblpapi': Error in bdp_Impl(con, securities, fields, options, overrides, verbose, : Bad field: BLAH BLAH
    ## 
    ##  Removing DODFX US Equity.

    ## Warning: x = 'DODGX US Equity', get = 'Rblpapi': Error in bdp_Impl(con, securities, fields, options, overrides, verbose, : Bad field: BLAH BLAH
    ## 
    ##  Removing DODGX US Equity.

    ## Warning: x = 'DODIX US Equity', get = 'Rblpapi': Error in bdp_Impl(con, securities, fields, options, overrides, verbose, : Bad field: BLAH BLAH
    ## 
    ##  Removing DODIX US Equity.

    ## Warning: x = 'DODWX US Equity', get = 'Rblpapi': Error in bdp_Impl(con, securities, fields, options, overrides, verbose, : Bad field: BLAH BLAH
    ## 
    ##  Removing DODWX US Equity.

    ## Warning: x = 'SPX Index', get = 'Rblpapi': Error in bdp_Impl(con, securities, fields, options, overrides, verbose, : Bad field: BLAH BLAH
    ## 
    ##  Removing SPX Index.

    ## Warning: x = 'LBUSTRUU Index', get = 'Rblpapi': Error in bdp_Impl(con, securities, fields, options, overrides, verbose, : Bad field: BLAH BLAH
    ## 
    ##  Removing LBUSTRUU Index.

    ## Warning in value[[3L]](cond): Returning as nested data frame.

``` r
my_bloomberg_data
```

    ## # A tibble: 0 x 2
    ## # ... with 2 variables: symbol <chr>, Rblpapi <list>

useful error message.

try verbose=TRUE flag
=====================

``` r
bad_sec = "some nonsense"
my_fields=c("CURRENT_ANN_TRR_5YR","PEER_RANKING","FUND_BENCHMARK_PRIM")
ovr<-c("PEER_RANKING_PERIOD"='5Y')
my_bloomberg_data <- bad_sec %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           overrides = ovr,
           fields      = my_fields,
           verbose = TRUE
           )
```

    ## ReferenceDataResponse = {
    ##     securityData[] = {
    ##         securityData = {
    ##             security = "some nonsense"
    ##             eidData[] = {
    ##             }
    ##             securityError = {
    ##                 source = "809::sbbdbd8"
    ##                 code = 3
    ##                 category = "BAD_SEC"
    ##                 message = "Unknown/Invalid Security  [nid:809] "
    ##                 subcategory = "INVALID_SECURITY"
    ##             }
    ##             fieldExceptions[] = {
    ##             }
    ##             sequenceNumber = 0
    ##             fieldData = {
    ##             }
    ##         }
    ##     }
    ## }

``` r
my_bloomberg_data
```

    ## # A tibble: 1 x 3
    ##   CURRENT_ANN_TRR_5YR PEER_RANKING FUND_BENCHMARK_PRIM
    ## *               <dbl>        <int>               <chr>
    ## 1                  NA           NA

Good.

verbose = TRUE when no error is thrown
======================================

``` r
my_fields=c("CURRENT_ANN_TRR_5YR","PEER_RANKING","FUND_BENCHMARK_PRIM")
ovr<-c("PEER_RANKING_PERIOD"='5Y')
my_bloomberg_data <- secs[1:4] %>%
    tq_get(get         = "Rblpapi",
           rblpapi_fun = "bdp",
           overrides = ovr,
           fields      = my_fields,
           verbose = TRUE
           )
```

    ## ReferenceDataResponse = {
    ##     securityData[] = {
    ##         securityData = {
    ##             security = "DODFX US Equity"
    ##             eidData[] = {
    ##             }
    ##             fieldExceptions[] = {
    ##             }
    ##             sequenceNumber = 0
    ##             fieldData = {
    ##                 CURRENT_ANN_TRR_5YR = 9.777702
    ##                 PEER_RANKING = 66
    ##                 FUND_BENCHMARK_PRIM = "MXEA"
    ##             }
    ##         }
    ##     }
    ## }
    ## ReferenceDataResponse = {
    ##     securityData[] = {
    ##         securityData = {
    ##             security = "DODGX US Equity"
    ##             eidData[] = {
    ##             }
    ##             fieldExceptions[] = {
    ##             }
    ##             sequenceNumber = 0
    ##             fieldData = {
    ##                 CURRENT_ANN_TRR_5YR = 16.324170
    ##                 PEER_RANKING = 98
    ##                 FUND_BENCHMARK_PRIM = "SPX"
    ##             }
    ##         }
    ##     }
    ## }
    ## ReferenceDataResponse = {
    ##     securityData[] = {
    ##         securityData = {
    ##             security = "DODIX US Equity"
    ##             eidData[] = {
    ##             }
    ##             fieldExceptions[] = {
    ##             }
    ##             sequenceNumber = 0
    ##             fieldData = {
    ##                 CURRENT_ANN_TRR_5YR = 3.063700
    ##                 PEER_RANKING = 86
    ##                 FUND_BENCHMARK_PRIM = "LBUSTRUU"
    ##             }
    ##         }
    ##     }
    ## }
    ## ReferenceDataResponse = {
    ##     securityData[] = {
    ##         securityData = {
    ##             security = "DODWX US Equity"
    ##             eidData[] = {
    ##             }
    ##             fieldExceptions[] = {
    ##             }
    ##             sequenceNumber = 0
    ##             fieldData = {
    ##                 CURRENT_ANN_TRR_5YR = 13.774270
    ##                 PEER_RANKING = 95
    ##                 FUND_BENCHMARK_PRIM = "M1WO"
    ##             }
    ##         }
    ##     }
    ## }

``` r
my_bloomberg_data
```

    ## # A tibble: 4 x 4
    ##            symbol CURRENT_ANN_TRR_5YR PEER_RANKING FUND_BENCHMARK_PRIM
    ##             <chr>               <dbl>        <int>               <chr>
    ## 1 DODFX US Equity            9.777702           66                MXEA
    ## 2 DODGX US Equity           16.324170           98                 SPX
    ## 3 DODIX US Equity            3.063700           86            LBUSTRUU
    ## 4 DODWX US Equity           13.774270           95                M1WO

Good.
