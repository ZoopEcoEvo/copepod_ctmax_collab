# Load in required packages
library(rmarkdown)
library(tidyverse)

#Determine which scripts should be run
process_data = F #Runs data analysis 
make_report = F #Runs project summary
knit_manuscript = F #Compiles manuscript draft

############################
### Read in the RAW data ###
############################

if(process_data == T){
  source(file = "Scripts/01_data_processing.R")
}

##################################
### Read in the PROCESSED data ###
##################################

ctmax_data = read.csv(file = "Raw_data/ctmax_data.csv") %>% 
  drop_na(ctmax)

read.csv(file = "Raw_data/ctmax_data.csv") %>%  
  filter(order != "<NA>") %>%  
  mutate("sheet_char" = if_else(data_sheet <10,
                                as.character(paste0(0, data_sheet)),
                                as.character(data_sheet)),
         "tube_char" = if_else(tube <10,
                                as.character(paste0(0, tube)),
                                as.character(tube)), 
         "code" = paste0(sheet_char, tube_char)) %>% 
  select(code, order, site) %>% 
  filter(order == "Cyclopoid") %>% 
  mutate("species" = "") %>% 
  select(-order) %>% 
  write.csv(file = "Output/Output_data/cyclopoid_ids.csv", row.names = F)
  

if(make_report == T){
  render(input = "Output/Reports/report.Rmd", #Input the path to your .Rmd file here
         #output_file = "report", #Name your file here if you want it to have a different name; leave off the .html, .md, etc. - it will add the correct one automatically
         output_format = "all")
}

##################################
### Read in the PROCESSED data ###
##################################

if(knit_manuscript == T){
  render(input = "Manuscript/manuscript_name.Rmd", #Input the path to your .Rmd file here
         output_file = paste("dev_draft_", Sys.Date(), sep = ""), #Name your file here; as it is, this line will create reports named with the date
                                                                  #NOTE: Any file with the dev_ prefix in the Drafts directory will be ignored. Remove "dev_" if you want to include draft files in the GitHub repo
         output_dir = "Output/Drafts/", #Set the path to the desired output directory here
         output_format = "all",
         clean = T)
}
