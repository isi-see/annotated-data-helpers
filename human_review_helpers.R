## ---------------------------
## Author: Isabell (Isi) Seeger
## Project: annotation_scripts
## Date created: 2025-01-13
##
## Description/purpose of script:
##
## Helper functions to make the raw output file from the labeling platform  
## ready for human review/spotchecking (e.g. in a spreadsheet)
## ---------------------------

## load packages:

library(tidyverse)
library(data.table)
library(stringr)

## load files:
aggr_output <- read.csv("dummy_data_aggr-output.csv", stringsAsFactors = F)

##! All helper functions assume that raw judgment data (per data point) comes in
## the format e.g. "label1\nlabel2\nlabel1"
## (one string, indiv. labels separated by newline character)

###---- 1) Count the given labels and return human-readable format, e.g. "2x label1, 1x label3" ----

##-- 1 for radio buttons (only one can be selected by each annotator)
#output format: "label1\nlabel2\nlabel1"

GetCounts_Radios <- function(judgments_raw) {
  #returns human readable counts of given judgments
  if (judgments_raw != "" ) { #only proceed if not empty
    split_judgments <- unlist(strsplit(judgments_raw, "\n", fixed = F))   #split one str into char vec on newline char
    
    split_judgments <- paste0("^", split_judgments) #! so str_count() does not count substring
    
    unique_labels <- unique(split_judgments)  #unique category labels
    
    count <- numeric()  #empty vecs
    label_counts <- c()
    
    for (i in 1:length(unique_labels)) {
      count <- sum(str_count(unique_labels[i], fixed(split_judgments)))  #how many occurrences of label?
      
      label_count <- paste0(count,"x ", unique_labels[i])  #human readable - "3x label"
      
      label_count <- gsub("^", replacement = "", label_count, fixed = T)  #drop the ^
      
      label_counts <- c(label_counts, label_count)
      label_counts <- sort(label_counts, decreasing = T) #sort so highest is first
    }
    label_counts <- paste(label_counts, collapse = '| ')
    
  } else {
    label_counts <- ""  #if NA, write empty str
  }
  return(label_counts)
}

##-- 2 for checkboxes (several can be selected by each annotator):
#output format:e.g. "checkbox1|checkbox3\ncheckbox2|checkbox3|checkbox5\ncheckbox1"
# (indiv. checkboxes separated by pipe symbol, judgments separated by newline)

GetCounts_Checkboxes <- function(judgments_raw) {
  #returns human readable counts of given judgments
  if (judgments_raw != "" ) { #only proceed if not empty
    split_judgments <- unlist(strsplit(judgments_raw, "\n", fixed = F))   #split one str into char vec on newline 
    split_judgments <- unlist(strsplit(split_judgments, "|", fixed = T))   # split again on pipe symbol
    
    split_judgments <- paste0("^", split_judgments) #! so str_count() does not count substring
    
    unique_labels <- unique(split_judgments)  #unique category labels
    
    count <- numeric()  #empty vecs
    label_counts <- c()
    
    for (i in 1:length(unique_labels)) {
      count <- sum(str_count(unique_labels[i], fixed(split_judgments)))  #how many occurrences of label?
      
      label_count <- paste0(count,"x ", unique_labels[i])  #human readable - "3x label"
      
      label_count <- gsub("^", replacement = "", label_count, fixed = T)  #drop the ^
      
      label_counts <- c(label_counts, label_count)
      label_counts <- sort(label_counts, decreasing = T) #sort so highest is first
    }
    label_counts <- paste(label_counts, collapse = '| ')
    return(label_counts)
    
  } else {
    label_counts <- ""  #if NA, write empty str
  }
  return(label_counts)
}


###--- 2) Check annotator agreement in easily reviewable and filterable format ------- 

Check_Agreement <- function(judgments_raw) {
  #returns full_agreement, majority_agreement, or disagreement (no majority label) -- use on radio button output
  if (judgments_raw != "" ) {  #only apply if not empty

  split_judgments <- unlist(strsplit(judgments_raw, "\n", fixed = F))  #split
  
  if  (length(unique(split_judgments)) == 1) { # if all the same = full agreement:
    agreement <- "full_agreement"
    
  } else {
    ##^ count unique labels in judgments vector and return the one with highest count
    
    split_judgments <- paste0("^", split_judgments) #! so str_count() does not count substrings
    
    unique_labels <- unique(split_judgments)  #get unique labels in judgment set
    label_counts <- c()
    
    for (i in 1:length(unique_labels)) {
      label_counts <- append(label_counts, 
                             sum(str_count(split_judgments,
                                           fixed(unique_labels[i]))))
    }
    
    #create named vector
    names(unique_labels) <- label_counts
    
    #find majority label
    highest_count <- max(as.numeric(names(unique_labels)))
    majority_label <- unique_labels[names(unique_labels) == highest_count]
    majority_label <- gsub("^", replacement = "", majority_label, fixed = T)  #drop the ^ again
    
    if (length(majority_label) > 1) {
      # if there is more than 1 label in majority_label, it's a disagreement (e.g. 2/2 split if collecting 4 judgments)
      agreement <- "disagreement"
    } else {
      agreement <- "majority_agreement"
    }
  }
  } else {
    print("no judgments!")
  }
  return(agreement)
}

##---How to call all functions on dummy data - using mapply(): ----
#Do Counts:
#radio buttons:
aggr_output$label_counts <- mapply(GetCounts_Radios, judgments_raw = aggr_output$label_judgments)

#checkboxes:
aggr_output$checkbox_counts <- mapply(GetCounts_Checkboxes, judgments_raw = aggr_output$checkbox_judgments)

#Agreement:
# write to a new column called 'agreement':
aggr_output$label_agreement <- mapply(Check_Agreement, judgments_raw = aggr_output$label_judgments)


