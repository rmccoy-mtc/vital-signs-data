
# Import Libraries

library(knitr)
suppressMessages(library(plyr))
suppressMessages(library(dplyr))
library(RCurl)
library(RJSONIO)
library(reshape2)
library(httr)

# Set up census variables and directories for saving final files

key="b901231133cf7da9e4ae3dea1af2470e87b3b9e7"
ACS_year="2015"
ACS_product="5"
city=paste0("00562,00674,01640,02252,03092,05108,05164,05290,06000,08142,08310,09066,",
	"09892,10345,13882,14190,14736,16000,16462,16560,17610,17918,17988,",
	"19402,20018,20956,21796,22594,23168,23182,25338,26000,29504,31708,",
	"33000,33056,33308,33798,39122,40438,41992,43280,43294,44112,46114,",
	"46870,47710,47486,47766,48956,49187,49278,49670,50258,50916,52582,",
	"53000,53070,54232,54806,55282,56784,56938,57288,57456,57764,57792,",
	"58380,60102,60620,60984,62546,62980,64434,65028,65070,67000,68000,",
	"68084,68252,68294,68364,68378,69084,70098,70280,70364,70770,72646,",
	"73262,64140,75630,77000,78666,81204,81554,81666,83346,85922,86440,86930")

source_residence="B19013_ACS15_5YR"
source_work="B08521_ACS15_5YR"

residence_output_csv=paste0("C:/Users/sisrae/Box Sync/Data/2A_Economy/EC4_Income by Place of Residence/2015/",ACS_year,"_")
work_output_csv=paste0("C:/Users/sisrae/Box Sync/Data/2A_Economy/EC5_Income by Place of Work/2015/",ACS_year,"_")

# Import census API data for income and earnings for place of residence and workplace, respectively.

url <- paste0("http://api.census.gov/data/",ACS_year,"/acs",ACS_product,"?get=NAME,B19013_001E,B08521_001E&in=state:06&for=place:",city,"&key=",key)

# Put API data into list file

response <- content(GET(url))

# For length of list file, use first row as header
# Create and append data to data frame. Change null values to "NA."

for (i in 1:length(response))
{
  if (i==1) header <- response [[i]]
  if (i==2) 
  {
    temp <- lapply(response[[i]], function(x) ifelse(is.null(x), NA, x))
    income <- data.frame(temp, stringsAsFactors=FALSE)
    names (income) <- header
  }
  if (i>2)
  {
    temp <- lapply(response[[i]], function(x) ifelse(is.null(x), NA, x))
    tempdf <- data.frame(temp, stringsAsFactors=FALSE)
    names (tempdf) <- header
    income <- rbind (income,tempdf)
    
  }
}

# Append geography variables, apply source variables, separate residence and workplace files, and rename some variables

income$Id <- paste0 ("1600000US06",income$place)
income$Id2 <- paste0 ("6",income$place)
income$Geo <- sapply((strsplit(as.character(income$NAME),'city,')),function(x) x[1])
income$Geo <- sapply((strsplit(as.character(income$Geo),'town,')),function(x) x[1])
income$Year <- ACS_year
income$Median_Income <- income$B19013_001E
income$Median_Earnings <- income$B08521_001E
income$Residence_Source <- source_residence
income$Work_Source <- source_work

residence_income <- income %>% 
  select(Id,Id2,Geo, Median_Income, Residence_Source)
names(residence_income)[3]<-"Residence_Geo"
names(residence_income)[5]<-"Source"

workplace_earnings <- income %>% 
  select(Id,Id2,Geo, Median_Earnings, Work_Source)
names(workplace_earnings)[3]<-"Workplace_Geo"
names(workplace_earnings)[5]<-"Source"

# Write out CSV 

write.csv(residence_income , paste0(residence_output_csv, "5Year_Residence_City_Income.csv"), row.names = FALSE, quote = T)
write.csv(workplace_earnings , paste0(work_output_csv, "5Year_Workplace_City_Earnings.csv"), row.names = FALSE, quote = T)