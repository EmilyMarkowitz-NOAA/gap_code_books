#' ---------------------------------------------
#' title: Create code books
#' author: EH Markowitz
#' start date: 2022-04-21
#' Notes: 
#' ---------------------------------------------

# This has a specific username and password because I DONT want people to have access to this!
# source("C:/Users/emily.markowitz/Work/Projects/ConnectToOracle.R")
# source("C:/Users/emily.markowitz/Documents/Projects/ConnectToOracle.R")
source("C:/Users/christopher.anderson/Work/8_R Files/connect_to_Oracle.R")

# I set up a ConnectToOracle.R that looks like this: 
#   
#   PKG <- c("RODBC")
# for (p in PKG) {
#   if(!require(p,character.only = TRUE)) {  
#     install.packages(p)
#     require(p,character.only = TRUE)}
# }
# 
# channel<-odbcConnect(dsn = "AFSC",
#                      uid = "USERNAME", # change
#                      pwd = "PASSWORD", #change
#                      believeNRows = FALSE)
# 
# odbcGetInfo(channel)

# Download Oracle Data Column information --------------------------------------

locations <- c("RACE_DATA", "RACEBASE")

sink("./data/oracle/record_data_dl_table_info.txt") #sinks the data into connection as text file
print(Sys.Date())

a_col <- data.frame()
a_table <- data.frame()

for (i in 1:length(locations)) {

  print(locations[i])
  
# --TABLE METADATA QUIERY FROM NANCY
# SELECT
# table_name,
# comments
# FROM
# all_tab_comments
# WHERE
# owner = 'RACEBASE'
# AND comments IS NOT NULL
# AND comments NOT LIKE '%without metadata%'
# ORDER BY
# table_name ASC

a <- RODBC::sqlQuery(channel = channel, 
                   query = paste0("SELECT table_name, comments FROM all_tab_comments WHERE owner = '",locations[i],"' ORDER BY table_name")) # AND comments IS NOT NULL AND comments NOT LIKE '%without metadata%'  ASC

# a <- RODBC::sqlQuery(channel = channel, query = paste0("SELECT
# table_name, ",locations[i],"
# FROM
# user_tables
# ORDER BY
# owner, table_name"))

a_col <- dplyr::bind_rows(a_col, 
                          a %>% 
                            dplyr::mutate(schema = locations[i]))


# Download Oracle Data Table information ---------------------------------------

# -COLUMN METDATA QUIERY FROM NANCY
# SELECT DISTINCT
# ( table_name ),
# comments
# FROM
# all_col_comments
# WHERE
# owner = 'RACEBASE'
# AND comments IS NOT NULL
# AND table_name LIKE '%_ORIG%'
# GROUP BY
# table_name,
# comments
# ORDER BY
# table_name ASC

a <- RODBC::sqlQuery(channel = channel, 
                  query = paste0("SELECT DISTINCT ( table_name ), comments FROM all_col_comments WHERE owner = '",locations[i],"' AND comments IS NOT NULL GROUP BY table_name, comments ORDER BY table_name ASC"))

a_table <- dplyr::bind_rows(a_table, 
                            a %>% 
                              dplyr::mutate(schema = locations[i]))

}

write.csv(x=a_col, paste0("./data/oracle/table_metadata.csv"))
write.csv(x=a_table, paste0("./data/oracle/column_metadata.csv"))

sink()

# Download Oracle Data ---------------------------------------------------------

locations<-c(
  # "RACEBASE.CATCH",
  # "RACEBASE.HAUL",
  # "RACE_DATA.V_CRUISES",
  "RACEBASE.SPECIES",
  "RACE_DATA.VESSELS"
)

sink("./data/oracle/record_data_dl_table.txt") #sinks the data into connection as text file

print(Sys.Date())

for (i in 1:length(locations)){
  print(locations[i])
  if (locations[i] == "RACEBASE.HAUL") { # that way I can also extract TIME
    
    a<-RODBC::sqlQuery(channel, paste0("SELECT * FROM ", locations[i]))
    
    a<-RODBC::sqlQuery(channel, 
                       paste0("SELECT ",
                              paste0(names(a)[names(a) != "START_TIME"], 
                                     sep = ",", collapse = " "),
                              " TO_CHAR(START_TIME,'MM/DD/YYYY HH24:MI:SS') START_TIME  FROM ", 
                              locations[i]))
  } else {
    a<-RODBC::sqlQuery(channel, paste0("SELECT * FROM ", locations[i]))
  }
  
  if (locations[i] == "AI.CPUE") {
    filename <- "cpue_ai"
  } else if (locations[i] == "GOA.CPUE") {
    filename <- "cpue_goa"
  } else {
    filename <- tolower(strsplit(x = locations[i], 
                                 split = ".", 
                                 fixed = TRUE)[[1]][2])
  }
  
  write.csv(x=a, 
            paste0("./data/oracle/",
                   filename,
                   ".csv"))
  remove(a)
}

sink()


