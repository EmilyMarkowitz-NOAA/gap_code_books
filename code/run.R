#' ---------------------------------------------
#' title: Create code books
#' author: EH Markowitz
#' start date: 2022-04-21
#' Notes: 
#' ---------------------------------------------

# REPORT KNOWNS ----------------------------------------------------------------

# The surveys we will consider covering in this data are: 
# report_yr <- 2022

# Support scripts --------------------------------------------------------------

source('./code/functions.R')
# source('./code/data_dl.R')
source('./code/data.R')


dir_out <- paste0("./output/", Sys.Date())
dir.create(path = dir_out)
rmarkdown::render(paste0("./code/report.Rmd"),
                  output_dir = dir_out,
                  output_file = paste0("report.docx"))

