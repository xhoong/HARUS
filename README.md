# Human Activity Recognition Using Smartphones (or HARUS)

## Overview

This is part of Data Scientist specialization for Getting and Cleaning Data student project. The data sets here are based on UCI study that recorded smartphones gyroscope and accelerometer measurements during known activities. Refer to the [UCI HARUS](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) project page.

## Running the program

The program is self contain in R script call run_analysis.R, there's a mechanism to enable auto download the data set from the URL provided as part of global variable `uciFileUrl`, and data will be extraced to the current working directory with base `uciBasePath`. You can also change the download method via `downloadMethod` in the script.

However due the data size of the file, it is recommended you download it external to R program and extract it. The default behavior will show error if the base directory is not found. Therefore, all the data will be read from this base directory `uciBasePath`.

The script only require `reshape2` as dependency package, it use melt and dcast to create the tidy data, and save it in a file call *tidy.txt* in the current working directory.

Source the script and call the function `makeTidyDataFile("tidy.txt")`, you can read the file using `tidy <- read.table("tidy.txt", header=T)` and print the summary using `summary(tidy)`

The code book is *CodeBook.Rmd*, it is created using Rstudio R markdown, where it will run the script and generate the summary in the *CodeBook.html*