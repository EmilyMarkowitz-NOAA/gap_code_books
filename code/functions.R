#' ---------------------------------------------
#' title: Create code books
#' author: EH Markowitz
#' start date: 2022-04-21
#' Notes: 
#' ---------------------------------------------


PKG <- c(
  # other tidyverse
  "tidyr",
  "dplyr",
  "magrittr",
  "readr",
  "rmarkdown",
  "here",
  "flextable",
  "janitor",

  # Text Management
  "stringr")


PKG <- unique(PKG)
for (p in PKG) {
  if(!require(p,character.only = TRUE)) {
    install.packages(p)
    require(p,character.only = TRUE)}
}
