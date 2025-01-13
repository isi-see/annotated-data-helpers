## ---------------------------
## Author: Isabell (Isi) Seeger
## Project: annotation_scripts
## Date created: 2025-01-13
##
## Description/purpose of script:
##
## Helper functions to analyse the performance of individual annotators:
## create a plot of judgment distribution per annotator; compare annotator judgments to gold data
## ---------------------------

## load packages:

library(tidyverse)
library(dplyr)
library(janitor)

## load files:
output_by_annotator <- read.csv("dummy_data_by_annotator.csv", stringsAsFactors = F)
gold_data <- read.csv("dummy_data_gold-labels.csv", stringsAsFactors = F)

##--- Check the distribution of judgments given by annotator to check for any anomalies:---

# using tidyverse:
split_by_annotator <- output_by_annotator %>%
  group_by(annotator_id) %>%
  dplyr::count(label_judgments) %>%
  dplyr::mutate(proportion = round(n / sum(n), 2)) %>% #proportions in %
  ungroup()

## ---- plot the data: ---
#prepare data:
split_by_annotator$label_judgments <- as.factor(split_by_annotator$label_judgments)
split_by_annotator$annotator_id <- as.factor(split_by_annotator$annotator_id)

# create stacked barplot:
annotator_plt <- ggplot(split_by_annotator, aes(x=reorder(annotator_id, n), 
                                    y=n, 
                                    fill=label_judgments, label=proportion))+
  geom_bar(stat='identity')+
  geom_text(data = subset(split_by_annotator, proportion > 0.1),position = "stack")+
  ggtitle("Proportional view of Raw Judgements given, by Annotator ID")+
  xlab("Annotator ID")+
  ylab("count")

annotator_plt


###--- Compare indiv. annotator judgments to "gold" data labels (accuracy) ----

# this is a version of "agreement checking" - see where indiv. annotators agreed with gold data
# and return an accuracy score

#1 add gold label to dataset and compare this and the given judgment:

#create lookup vector (works like a dictionary)
gold_labels <- gold_data$gold_labels
names(gold_labels) <- gold_data$data_points

output_by_annotator$gold_label <- NA #empty column

for (i in 1:nrow(output_by_annotator)) {
  #use lookup vector to populate cell with the right gold label:
  output_by_annotator$gold_label[i] <- unlist(
                                  gold_labels[paste0(
                                    output_by_annotator$data_points[i])])
}

output_by_annotator$agreement_w_gold <- NA #empty column

for (j  in 1:nrow(output_by_annotator)) {
  #compare the given judgment and the gold label, and check if agree or not
  if (output_by_annotator$label_judgments[j] == output_by_annotator$gold_label[j]) {
    output_by_annotator$agreement_w_gold[j] <- TRUE
  } else {
    output_by_annotator$agreement_w_gold[j] <- FALSE
  }
}

# check results - using janitor library for a nicer printed table:
tabyl(dat=output_by_annotator, annotator_id, agreement_w_gold)

# write accuracy to a dataframe:
accuracy_by_annotator <- output_by_annotator %>%
  group_by(annotator_id) %>%
  dplyr::count(agreement_w_gold) %>%
  dplyr::mutate(proportion = round(n / sum(n), 2)) %>% #proportions in %
  dplyr::filter(agreement_w_gold == TRUE) %>%
  dplyr::rename(accuracy=proportion) %>%
  select(-c(n,agreement_w_gold)) %>%
  ungroup()
  




