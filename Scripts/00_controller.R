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
  initial_data = read.csv(file = "Raw_data/ctmax_data.csv") %>% 
    drop_na(ctmax) %>% 
    select(-order, -genus, "exp_notes" = notes) 
  
  ids = read.csv(file = "Raw_data/specimen_ids.csv", dec = ",", sep = ";") %>%  
    janitor::clean_names() %>% select(-x, -x_1) %>% 
    separate_wider_delim(code_order, delim = ",", names = c("specimen", "order")) %>%
    separate_wider_position(specimen, widths = c(data_sheet = 2, tube = 2)) %>%
    mutate(order = str_remove_all(order, "\""), 
           species = str_trim(species), 
           species = if_else(species == "", "sp.", species),
           author = if_else(author == "", NA, str_trim(author)),
           eggs = if_else(eggs == "", "absent", "present"),
           data_sheet = as.numeric(data_sheet),
           tube = as.numeric(tube)) %>%  
    select(data_sheet:body_length_um, "id_notes" = notes) %>% 
    mutate(data_sheet = if_else(data_sheet == 30, 34, data_sheet))
  
  ctmax_data = left_join(initial_data, ids)
  
  write.csv(ctmax_data, "Output/Output_data/ctmax_data.csv", row.names = F)
  
  source(file = "Scripts/01_data_processing.R")
}

##################################
### Read in the PROCESSED data ###
##################################

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
