## ---------------------------
## Author: Isi Seeger
## Project: annotation_scripts
## Date created: 2025-01-13
## Date updated:
##
## Description/purpose of script:
##
## Make dummy data for annotation-scripts public repo
## assumption: 3 judgments collected per data point, with both radio labels and checkboxes
## ---------------------------

## load packages:

library(tidyverse)
library(irr)
library(plyr)
library(stringr)
library(data.table)
library(janitor)
library(reshape2)

set.seed(1337)

no_of_annotators <- 3

## create dummy variables: datapoints and labels
string <- "data_point"
nums <- c(1:10)
data_points <- paste0(string,nums)

# create available labels
available_labels <- c("radio_option1", "radio_option2", "radio_option3")
available_checkboxes <- c("checkbox1", "checkbox2", "checkbox3", "checkbox4", "checkbox5")

### First dataset: An aggregated output with all given judgments in one character string/cell

# make df
df <- as.data.frame(data_points)

###----- 1 create raw judgments for the radio labels (one option selected by 1 annotator)---

# empty column for raw "judgments"
df$label_judgments <- NA

for (i in 1:nrow(df)) {
  # randomly sample 3 "judgments" from available judgments, per row, write to column
  judgments_given <- c()
  judgments_given <- sample(available_labels, replace = T)
  
  judgments_given <- paste(judgments_given, collapse = "\n") # mimic platform output
  
  df$label_judgments[i] <- judgments_given
}

#manually change 2 to full agreement:
df$label_judgments[3]<- "radio_option2\nradio_option2\nradio_option2"

df$label_judgments[8]<- "radio_option3\nradio_option3\nradio_option3"

###----- 2 create checkbox selection per annotator (several are possible)-----

df$checkbox_judgments <- NA

possible_selection_counts <- 1:5  #annotators can select between one and all checkboxes

for (j in 1:nrow(df)) {
  checkbox_judgments <- c()
  for (k in 1:no_of_annotators) {
    # for each "annotator", create a random selection of checkbox labels (1-5 is possible)
    indiv_judgment <- c()
    indiv_judgment <- sample(available_checkboxes, 
                              size= sample(possible_selection_counts, 1), #random how many checkboxes are selected
                              replace = F)
    
    indiv_judgment <- paste(indiv_judgment, collapse="|")
    checkbox_judgments <- c(checkbox_judgments, indiv_judgment) #collect all in the other vector
    
  }
  checkbox_judgments <- paste(checkbox_judgments, collapse = "\n")
  df$checkbox_judgments[j] <- checkbox_judgments
}

aggr_df <- df  #rename

###--- Second dataset: create a "Full" report with single judgment per row -----

annotator_ids <- c("annotator1", "annotator2", "annotator3")

by_annotator_df_1 <-as.data.frame(data_points)

by_annotator_df_1$annotator1 <- NA
by_annotator_df_1$annotator2 <- NA
by_annotator_df_1$annotator3 <- NA

by_annotator_df_1$judgment_type <- "label_judgments"

## for the radio labels
for (m in 1:nrow(aggr_df)) {
  judgs <- aggr_df$label_judgments[m]
  judgs <- unlist(str_split(judgs, pattern="\n"))
  
  by_annotator_df_1$annotator1[m] <- judgs[1]
  by_annotator_df_1$annotator2[m] <- judgs[2]
  by_annotator_df_1$annotator3[m] <- judgs[3]
  
}

## for the checkboxes 
by_annotator_df_2 <-as.data.frame(data_points)

by_annotator_df_2$annotator1 <- NA
by_annotator_df_2$annotator2 <- NA
by_annotator_df_2$annotator3 <- NA

by_annotator_df_2$judgment_type <- "checkbox_judgments"

## for the radio labels
for (m in 1:nrow(aggr_df)) {
  judgs_x <- aggr_df$checkbox_judgments[m]
  judgs_x <- unlist(str_split(judgs_x, pattern="\n"))
  
  by_annotator_df_2$annotator1[m] <- judgs_x[1]
  by_annotator_df_2$annotator2[m] <- judgs_x[2]
  by_annotator_df_2$annotator3[m] <- judgs_x[3]
  
}

annotator_df_wide <- rbind(by_annotator_df_1, by_annotator_df_2)  #combine

##--- reshape the df to desired format:

# first step: wide to long - one col for "annotator_id"
annotator_df_wide$data_points <- as.factor(annotator_df_wide$data_points)

annotator_df_long1 <- gather(annotator_df_wide, key = annotator_id,
                             value = judgment, annotator1:annotator3, factor_key=TRUE)

#second step: need to make the "judgment type" wide again so we have 2 columns for each judgment type

df_by_annotator <- spread(annotator_df_long1, key="judgment_type", "judgment")


##--- make "gold" data - correct labels for datapoints

gold_labels <- c("radio_option3","radio_option2","radio_option1","radio_option3",
                 "radio_option3","radio_option2","radio_option2","radio_option1",
                 "radio_option3","radio_option1")

gold_df <- data.frame(data_points, gold_labels)





### write outputs

#write.csv(df_by_annotator, "dummy_data_by_annotator.csv", row.names = F)
#write.csv(aggr_df,"dummy_data_aggr-output.csv", row.names = F)
#write.csv(gold_df,"dummy_data_gold-labels.csv", row.names = F)

