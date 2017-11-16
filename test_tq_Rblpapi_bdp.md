test\_tq\_Rblpapi
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
library(Rblpapi)
secs<-c("DODFX US Equity",
        "DODGX US Equity",
        "DODIX US Equity",
        "DODWX US Equity",
        "SPX Index",
        "LBUSTRUU Index")
```

initial test
============

single security, single data point
==================================

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
```

    ## Warning: package 'bindrcpp' was built under R version 3.4.1

``` r
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
    ## 1 DODFX US Equity       22.889710           63                MXEA
    ## 2 DODGX US Equity       14.656710           48                 SPX
    ## 3 DODIX US Equity        4.146775           75            LBUSTRUU
    ## 4 DODWX US Equity       18.534010           33                M1WO
    ## 5       SPX Index       21.201810           NA                    
    ## 6  LBUSTRUU Index        2.774545           NA

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
    ## 1 DODFX US Equity            3.649590           22                MXEA
    ## 2 DODGX US Equity            9.140778           85                 SPX
    ## 3 DODIX US Equity            3.024889           81            LBUSTRUU
    ## 4 DODWX US Equity            6.940759           74                M1WO
    ## 5       SPX Index           10.495980           NA                    
    ## 6  LBUSTRUU Index            2.390614           NA

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
    ## 1 DODFX US Equity            9.805865           66                MXEA
    ## 2 DODGX US Equity           16.489940           97                 SPX
    ## 3 DODIX US Equity            3.034104           86            LBUSTRUU
    ## 4 DODWX US Equity           13.812470           95                M1WO
    ## 5       SPX Index           16.117900           NA                    
    ## 6  LBUSTRUU Index            2.008912           NA

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
    ##                 source = "118::bbdbd9"
    ##                 code = 3
    ##                 category = "BAD_SEC"
    ##                 message = "Unknown/Invalid Security  [nid:118] "
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
    ##                 CURRENT_ANN_TRR_5YR = 9.805865
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
    ##                 CURRENT_ANN_TRR_5YR = 16.489930
    ##                 PEER_RANKING = 97
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
    ##                 CURRENT_ANN_TRR_5YR = 3.034104
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
    ##                 CURRENT_ANN_TRR_5YR = 13.812470
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
    ## 1 DODFX US Equity            9.805865           66                MXEA
    ## 2 DODGX US Equity           16.489930           97                 SPX
    ## 3 DODIX US Equity            3.034104           86            LBUSTRUU
    ## 4 DODWX US Equity           13.812470           95                M1WO

Good.
