#utility functions for financial time series
#---------------chart_cum_return-------------------
chart_cum_returns<-function(Ra, 
                            ret_col='return',
                            name_col='name',
                            date_col='date',
                            shape=c('narrow','wide')){
  #returns a ggplot2 line chart object for plotting or further annotation
  #crucially, this function adds a dummy date at the beginning of the series to start
  #the plot at the origin without a gap.
  Ra<-ungroup(Ra)
  Ra<-select(Ra,name = name_col,return=ret_col,date=date_col)
  shape<-match.arg(shape)
  if (shape=='wide'){
    Ra<- Ra %>%
      gather(name,return,-date)
  } else{
    Ra<- Ra %>% select(date,name,return)
  }
  
  #create wealth index. Add a date to start at "1"
  # that is equal to the length between the first and second dates
  new_dates<-(Ra$date[1]-as.numeric(Ra$date[2]-Ra$date[1])) %>% c(Ra$date)
  Ra<- Ra %>% 
    group_by(name)%>% 
    complete(date=new_dates,fill=list(return=0)) %>% 
    mutate(wealth=cumprod(1+return))
  
  gg<-Ra %>% 
    as.tibble() %>% 
    group_by(name) %>% 
    ggplot(aes(x=date,y=wealth,color=name))+geom_line()
  
  return(gg) 
}
#------------- mutate_cond -------------------------
# from https://stackoverflow.com/questions/34096162/dplyr-mutate-replace-on-a-subset-of-rows/45443415#45443415
mutate_cond <- function(.data, condition, ..., envir = parent.frame()) {
  condition <- eval(substitute(condition), .data, envir)
  condition[is.na(condition)] = FALSE
  .data[condition, ] <- .data[condition, ] %>% mutate(...)
  .data
}
