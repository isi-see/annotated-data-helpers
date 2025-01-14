annotation-helpers-readme
================
2025-01-14

## Overview

This is a collection of different helper functions I have used in
various data labeling projects. In these projects, individual data
points are annotated by several data annotators/reviewers, and these
reviewers each give a label judgment to the data. These helpers are
mostly for string tidying, wrangling, and processing.

## Application

These functions/scripts are intended to

- **create human-reviewable outputs**, e.g. for further manual review in
  a spreadsheet (`human_review_helpers.R`)
- **aggregate** all given judgments to a final *label* or label set for
  the datapoint (majority label, union of labels)
  (`label_aggregation_helpers.R`)
- **check** the judgments given by individual annotators to review their
  performance, or compare to “gold” labels
  (`annotator_review_helpers.R`)

## Expected format

These functions expect the labeled datasets in *CSV format*.

Different *dummy datasets* are provided to showcase the expected input
and output for different formats (**radio buttons** vs **checkboxes**).

Context: On common data labeling platforms, annotators give their
judgments in the following format:

<figure>
<img src="radio_buttons_UI_example.jpg"
alt="Example UI for Radio buttons" />
<figcaption aria-hidden="true">Example UI for Radio buttons</figcaption>
</figure>

<figure>
<img src="checkboxes_UI_example.jpg" alt="Example UI for Checkboxes" />
<figcaption aria-hidden="true">Example UI for Checkboxes</figcaption>
</figure>

The provided dummy datasets mimic the expected formats:

    ## [1] "Dummy dataset1 (one row per datapoint):"

    ## Rows: 10
    ## Columns: 3
    ## $ data_points        <chr> "data_point1", "data_point2", "data_point3", "data_point4", "data_point…
    ## $ label_judgments    <chr> "radio_option2\nradio_option3\nradio_option2", "radio_option1\nradio_op…
    ## $ checkbox_judgments <chr> "checkbox2|checkbox3\ncheckbox5|checkbox3|checkbox1|checkbox2|checkbox4…

    ## [1] "Dummy dataset2 (one row per judgment): "

    ## Rows: 30
    ## Columns: 4
    ## $ data_points        <chr> "data_point1", "data_point1", "data_point1", "data_point10", "data_poin…
    ## $ annotator_id       <chr> "annotator1", "annotator2", "annotator3", "annotator1", "annotator2", "…
    ## $ checkbox_judgments <chr> "checkbox2|checkbox3", "checkbox5|checkbox3|checkbox1|checkbox2|checkbo…
    ## $ label_judgments    <chr> "radio_option2", "radio_option3", "radio_option2", "radio_option2", "ra…
