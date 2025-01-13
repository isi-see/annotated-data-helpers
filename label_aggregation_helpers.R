## ---------------------------
## Author: Isabell (Isi) Seeger
## Project: annotation_scripts
## Date created: 2025-01-13
##
## Description/purpose of script:
##
## Functions for data aggregation: Turn raw judgments into a final data label
## or a label set (union of given labels)
## ---------------------------

## load packages:

library(tidyverse)
library(stringr)
library(data.table)

## load files:
aggr_output <- read.csv("dummy_data_aggr-output.csv", stringsAsFactors = F)

##! All helper functions assume that raw judgment data (per data point) comes in
## the format e.g. "label1\nlabel2\nlabel1"
## (one string, indiv. labels separated by newline character)

### ---- Get Majority Label: ----------

GetMajorityLabel <- function(judgments_raw) {
  ## returns majority label (or "disagreement" if there is none)
  aggr_label <- as.character()  #empty char vec
  
  if (judgments_raw == "" | is.na(judgments_raw)) { 
    aggr_label <- NA #if there is nothing, return NA
    return(aggr_label)
    
  } else {
    split_judgments <- unlist(strsplit(judgments_raw, "\n", fixed = F))
    
    ## Aggregation:
    if  (length(unique(split_judgments)) == 1) { # if all are the same, return the first
      aggr_label <- split_judgments[[1]] 
      
    } else {
      ##^ count unique labels in judgments vector and return the one with highest count
      
      judgements_vec <- paste0("^", split_judgments) #! so str_count() does not count substring
      
      unique_labels <- unique(judgements_vec)
      label_counts <- c()
      
      for (i in 1:length(unique_labels)) {
        label_counts <- append(label_counts, 
                               sum(str_count(judgements_vec,
                                             fixed(unique_labels[i]))))
      }
      #create named vector
      names(unique_labels) <- label_counts
      
      #find majority label:
      highest_count <- max(as.numeric(names(unique_labels)))
      majority_label <- unique_labels[names(unique_labels) == highest_count]
      majority_label <- gsub("^", replacement = "", majority_label, fixed = T)  #drop the ^ again
      
      if (length(majority_label) > 1) {
        # if there is more than 1 label in majority_label, it's a disagreement (e.g. 2/2 split)
        aggr_label <- "disagreement"
      } else {
        aggr_label <- majority_label
      }
    }
    return(aggr_label)
  }
}

##----- 2 Union of all given labels: -------
# this is most useful for checkbox inputs, e.g. when charateristica of data are selected

## 2.1 for radio button inputs:
GetUnionOfLabels_Radios <- function(judgments_raw) {
  # returns union of labels (a set of all labels given, regardless of count)
  if (judgments_raw != "") { #proceed if not empty
    split_judgments <- unlist(strsplit(judgments_raw, "\n", fixed = F))   #split one str into char vec
    
    labels <- unique(split_judgments)  #unique category labels
    
    labels_flat <- paste(labels, collapse = "|" )
    
    return(labels_flat)
    
  } else {
    labels <- NA
    return(labels)
  }
}


## 2.2 for checkbox inputs:

GetUnionOfLabels_Checkboxes <- function(judgments_raw) {
  # returns union of labels (a set of all labels given, regardless of count)
  if (judgments_raw != "") { #proceed if not empty
    split_judgments <- unlist(strsplit(judgments_raw, "\n", fixed = F))   #split on newline
    split_judgments <- unlist(strsplit(split_judgments, "|", fixed = T))  # split again on pipe symbol
    
    labels <- unique(split_judgments)  #unique category labels
    
    labels_flat <- paste(labels, collapse = "|" )
    
    return(labels_flat)
    
  } else {
    labels <- NA
    return(labels)
  }
}

##---How to call all functions on dummy data - using mapply(): ----

# Get union of labels - checkboxes:
aggr_output$union_checkboxes <- mapply(GetUnionOfLabels_Checkboxes, 
                                       judgments_raw = aggr_output$checkbox_judgments)

# Get majority label - radio buttons:
aggr_output$majority_label <- mapply(GetMajorityLabel, 
                                     judgments_raw= aggr_output$label_judgments)




