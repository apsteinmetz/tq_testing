test\_tq\_Rblpapi\_bds
================
Art Steinmetz

testing Tidyquant Rblpapi integration
=====================================

validate some variations on <code>bds()</code>

``` r
devtools::install_github("business-science/tidyquant")
```

    ## Skipping install of 'tidyquant' from a github remote, the SHA1 (f367de1f) has not changed since last install.
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

paste("Using tidyquant version",packageVersion('tidyquant'))
```

    ## [1] "Using tidyquant version 0.5.3.9000"

initial test
============

from Rblpapi docs using Rblpapi::bdp(), not tq\_get()
=====================================================

``` r
# Get BBG Descriptive Data
## Not run:
## simple query
blpConnect()
output_bds<-bds("GOOG US Equity", "TOP_20_HOLDERS_PUBLIC_FILINGS")
output_bds
```

    ##    Amount Held        Country Filing Date          Holder Name
    ## 1     20995893  United States  2017-09-30       VANGUARD GROUP
    ## 2     20038614            n/a  2017-02-22      PAGE LAWRENCE E
    ## 3     19381435            n/a  2017-08-10          BRIN SERGEY
    ## 4     18648659  United States  2017-11-17            BLACKROCK
    ## 5     13389160  United States  2017-09-30              FMR LLC
    ## 6     12314039  United States  2017-09-30 CAPITAL GROUP COMPAN
    ## 7     11739152  United States  2017-09-30    STATE STREET CORP
    ## 8      9508968  United States  2017-09-30 T ROWE PRICE GROUP I
    ## 9      4598070  United States  2017-09-30  JPMORGAN CHASE & CO
    ## 10     4323614            n/a  2017-08-25 SCHMIDT ERIC EMERSON
    ## 11     4163578  United States  2017-09-30 NORTHERN TRUST CORPO
    ## 12     3843461  United States  2017-09-30           BNY MELLON
    ## 13     3439401  United States  2017-09-30          INVESCO LTD
    ## 14     3401789  United States  2017-09-30            TIAA-CREF
    ## 15     3251657  United States  2017-09-30 GEODE CAPITAL MANAGE
    ## 16     3239665  United States  2017-09-30          DODGE & COX
    ## 17     3213342 United Kingdom  2017-09-30 JANUS HENDERSON GROU
    ## 18     3205983  United States  2017-09-30   ALLIANCE BERNSTEIN
    ## 19     2836902 United Kingdom  2017-09-30  BAILLIE GIFFORD AND
    ## 20     2761215          Japan  2017-03-31  GOVMT PENSION INVST
    ##      Institution Type Latest Change                            Metro Area
    ## 1  Investment Advisor        555855                          Philadelphia
    ## 2        Unclassified             0                          Unclassified
    ## 3        Unclassified             0                          Unclassified
    ## 4  Investment Advisor        588587 New York City/Southern CT/Northern NJ
    ## 5  Investment Advisor       -582519                                Boston
    ## 6  Investment Advisor        328534                  Los Angeles/Pasadena
    ## 7  Investment Advisor       -184515                                Boston
    ## 8  Investment Advisor       -560124                             Baltimore
    ## 9  Investment Advisor        -58824 New York City/Southern CT/Northern NJ
    ## 10       Unclassified          2625                          Unclassified
    ## 11 Investment Advisor        147586                               Chicago
    ## 12 Investment Advisor        -49491                            Pittsburgh
    ## 13 Investment Advisor         13183                               Atlanta
    ## 14 Investment Advisor        -38505 New York City/Southern CT/Northern NJ
    ## 15 Investment Advisor         94475                                Boston
    ## 16 Investment Advisor        -19823                San Francisco/San Jose
    ## 17 Investment Advisor          9255                                London
    ## 18 Investment Advisor        176180 New York City/Southern CT/Northern NJ
    ## 19 Investment Advisor        -82370                             Edinburgh
    ## 20         Government             0                                 Tokyo
    ##    Percent Outstanding       Portfolio Name  Source
    ## 1                 6.01                  n/a ULT-AGG
    ## 2                 5.73                  n/a  Form 4
    ## 3                 5.55                  n/a  Form 4
    ## 4                 5.34                  n/a ULT-AGG
    ## 5                 3.83                  n/a ULT-AGG
    ## 6                 3.52  Multiple Portfolios     13F
    ## 7                 3.36                  n/a ULT-AGG
    ## 8                 2.72                  n/a ULT-AGG
    ## 9                 1.32                  n/a ULT-AGG
    ## 10                1.24                  n/a  Form 4
    ## 11                1.19 NORTHERN TRUST CORPO     13F
    ## 12                1.10                  n/a ULT-AGG
    ## 13                0.98                  n/a ULT-AGG
    ## 14                0.97                  n/a ULT-AGG
    ## 15                0.93 GEODE CAPITAL MANAGE     13F
    ## 16                0.93          DODGE & COX     13F
    ## 17                0.92 JANUS HENDERSON GROU     13F
    ## 18                0.92                  n/a ULT-AGG
    ## 19                0.81 BAILLIE GIFFORD & CO     13F
    ## 20                0.79  Multiple Portfolios  MF-AGG

using tq\_get
=============

The parameter names for bds() differ slightly from bdp() and bdh(). <code>securities</code> becomes <code>security</code> and that blows up piping in the ticker symbols. <code>fields</code> becomes <code>field</code>

Pipe in first parameter with the ticker
=======================================

``` r
my_bloomberg_data <- c('GOOG US Equity') %>%
    tq_get(get         = "rblpapi",
           rblpapi_fun = "bds",
           field     = c("TOP_20_HOLDERS_PUBLIC_FILINGS")
           )
```

'x = 'GOOG US Equity', get = 'Rblpapi': Error in bds(securities = "GOOG US Equity", field = "TOP\_20\_HOLDERS\_PUBLIC\_FILINGS"): unused argument (securities = "GOOG US Equity")'

When the parameter is piped in tq\_get tries to assign it to `securities` even if the function is `bds', which throws an`unused argument\` error.

bds() with proper parameter names.
==================================

Commented out because otherwise execution halts. Error message shown below.

``` r
# my_bloomberg_data <-  tq_get(security = 'GOOG US Equity',
#                             get = "rblpapi",
#                             rblpapi_fun = "bds",
#                             field = c("TOP_20_HOLDERS_PUBLIC_FILINGS")
#           )
```

`Error in tq_get(security = "GOOG US Equity", get = "rblpapi", rblpapi_fun = "bds",  :    argument "x" is missing, with no default`

try assigning x.
================

``` r
my_bloomberg_data <-  tq_get(x = 'GOOG US Equity',
                             get = "rblpapi",
                             rblpapi_fun = "bds",
                             field = c("TOP_20_HOLDERS_PUBLIC_FILINGS")
           )
```

`x = 'GOOG US Equity', get = 'Rblpapi': Error in bds(securities = "GOOG US Equity", field = "TOP_20_HOLDERS_PUBLIC_FILINGS"): unused argument (securities = "GOOG US Equity")`

also doesn't work.

supply parameters sought, though not needed
===========================================

``` r
my_bloomberg_data <-  tq_get(x= 'GOOG US Equity',
                             securities='not needed',
                             fields = 'not needed',
                             get = "rblpapi",
                             rblpapi_fun = "bds",
                             security='GOOG US Equity',
                             field = c("TOP_20_HOLDERS_PUBLIC_FILINGS")
           )
```

    ## Warning: x = 'GOOG US Equity', get = 'Rblpapi': Error in bds(security = "GOOG US Equity", securities = "not needed", fields = "not needed", : formal argument "security" matched by multiple actual arguments

'x = 'GOOG US Equity', get = 'Rblpapi': Error in bds(securities = "GOOG US Equity", securities = "not needed", : unused arguments (securities = "GOOG US Equity", securities = "not needed", fields = "not needed")'

``` r
my_bloomberg_data <-  tq_get(x='not needed',
                             fields = 'not needed',
                             get = "rblpapi",
                             rblpapi_fun = "bds",
                             security='GOOG US Equity',
                             field = c("TOP_20_HOLDERS_PUBLIC_FILINGS")
           )
```

    ## Warning: x = 'not needed', get = 'Rblpapi': Error in bds(security = "not needed", fields = "not needed", security = "GOOG US Equity", : formal argument "security" matched by multiple actual arguments

This is the error that I get when I run the chunk above interactively. It is different from the error I get when I knit the notebook!

`x = 'not needed', get = 'Rblpapi': Error in bds(securities = "not needed", fields = "not needed", security = "GOOG US Equity", : unused arguments (securities = "not needed", fields = "not needed")`

Interesting. Note that `securities` is shown as an unused argument though it does not appear in the parameter list. It is a holdover from the last call, somehow.
