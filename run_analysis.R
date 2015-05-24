# Global variable stating the file URL where the data is located, the basePath of
# the unzipped directory and the method to download the data file.
uciFileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
uciBasePath <- "./"
downloadMethod <- "wget"

# Download the files if local path do not contains the data files to process
downloadData <- function() {
  tempfile <- tempfile()
  download.file(uciFileUrl, tempfile, method=downloadMethod)
  if(file.exists(tempfile)) {
    unzip(tempfile)
    unlink(tempfile)
  } else {
    stop("Error downloading UCI data file from ", uciFileUrl)
  }
  
}

# Get the UCI gyro & accel data reading for all activities, based on dataType "test" or "train"
# sets. The y_ data describe the activity of each reading from the X_ data sets.
# The function will also extract only variables that are mean and standard deviation,
# based on the measurement name stated in features_info.txt, as this is the only set
# require to calculte the average on.
# At the end, it will create 2 new variable name ActivityID and SubjectID, ActivityID
# will be merged with activity_label later to categorized the actual ActivityName.
getGyroData <- function(dataSetsType) {
  # Assume dataset zip file is extracted to uciBasePath, read the datasets type
  # for row info
  path <- file.path(uciBasePath, dataSetsType, paste0("y_", dataSetsType, ".txt"))
  y_data <- read.table(path, header=F, col.names=c("ActivityID"))
  
  # Get the measurement column names from the features.txt file
  data_cols <- read.table(file.path(uciBasePath, "features.txt"),
                          header=F, as.is=T, col.names=c("ID", "MeasurementName"))
  
  # Read the measurements
  path <- file.path(uciBasePath, dataSetsType, paste0("X_", dataSetsType, ".txt"))
  data <- read.table(path, header=F, col.names=data_cols$MeasurementName)
  
  # filter only the sets for mean and standard deviation (std)
  subsetCol <- grep(".*mean\\(\\)|.*std\\(\\)", data_cols$MeasurementName)
  
  # subset the data with the filter columns
  data <- data[,subsetCol]

  # Get the subject ID info
  path <- file.path(uciBasePath, dataSetsType, paste0("subject_", dataSetsType, ".txt"))
  subject <- read.table(path, header=F, col.names=c("SubjectID"))
  
  # Adds 2 additional column, ActivityID and the subjectID
  data$ActivityID <- y_data$ActivityID
  data$SubjectID <- subject$SubjectID
  data
}


# This function will get data for test and train sets, combine in rows on same column.
# Rename the columns for mean and std to call AvgMean and AvgStdDev as we going to
# calculate the avarage of those measurements.
# The data is also being merged with ActivityName based on key ActivityID
mergeAndTidy <- function() {
  testData <- getGyroData("test")
  trainData <- getGyroData("train")
  # Append trainData rows to testData
  data <- rbind(testData, trainData)
  
  # Rename all the measurement names
  colNames <- colnames(data)
  colNames <- gsub("\\.+mean\\.+", colNames, replacement="AvgMean")
  colNames <- gsub("\\.+std\\.+",  colNames, replacement="AvgStdDev")
  colnames(data) <- colNames

  # Get the activity lables and merge with the data set based on the ActivityID
  activities <- read.table(file.path(uciBasePath, "activity_labels.txt"),
                                header=F, col.names=c("ActivityID", "ActivityName"))
  #activities$ActivityName <- as.factor(activities$ActivityName)
  data <- merge(data, activities)
  data
}

# Create the tidy data set and save it on to the named file
makeTidyDataFile <- function(fname) {
  require(reshape2)
  # Default to error message if file path does not exists, to prevent download from
  # server, if you need to download, uncomment downloadData and comment the stop
  if(!file.exists(uciBasePath)) {
    #  downloadData()
    stop("Please download UCI dataset from ", uciFileUrl,
         "\nand extract it to current working folder ", uciBasePath)
  }
  mergedData <- mergeAndTidy()
  
  # Using reshape2, create the melted data for long format based on category column
  id_vars = c("ActivityID", "ActivityName", "SubjectID")
  measureVars = setdiff(colnames(mergedData), id_vars)
  meltedData <- melt(mergedData, id=id_vars, measure.vars=measureVars)
  
  # Recast and calculate the mean for each measurements using ActivityName and SubjectID 
  tidyData <- dcast(meltedData, ActivityName + SubjectID ~ variable, mean, na.rm=T)
  # Finally write the tidy data to file.
  write.table(tidyData, fname, row.names=FALSE)
  message("Done.")
}


#makeTidyDataFile("tidy.txt")
