if(!file.exists("./data")) {dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
downloaded_time <- Sys.time()
download.file(fileUrl, destfile="./data/dataset.zip", method="curl")

# unzip the file
unzip("./data/dataset.zip", exdir = "./data")

paths <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(paths, recursive=TRUE)
files

# read the data

ActivityTest  <- read.table(file.path(paths, "test" , "Y_test.txt" ), header = FALSE)
ActivityTrain <- read.table(file.path(paths, "train", "Y_train.txt"), header = FALSE)
SubjectTrain <- read.table(file.path(paths, "train", "subject_train.txt"), header = FALSE)
SubjectTest  <- read.table(file.path(paths, "test" , "subject_test.txt"), header = FALSE)
FeaturesTest  <- read.table(file.path(paths, "test" , "X_test.txt" ), header = FALSE)
FeaturesTrain <- read.table(file.path(paths, "train", "X_train.txt"), header = FALSE)
FeaturesNames <- read.table(file.path(paths, "features.txt"), header = FALSE)

# combine the data

Subject <- rbind(SubjectTrain, SubjectTest)
Activity<- rbind(ActivityTrain, ActivityTest)
Features<- rbind(FeaturesTrain, FeaturesTest)

# chages variable names
names(Subject) <- "subject"
names(Activity) <- "activity"
names(Features) <- FeaturesNames$V2

# merges the data by columns
data <- cbind(Subject, Activity, Features)
str(data)

SubsetFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
data <- subset(data, select = c(as.character(SubsetFeaturesNames), "subject", "activity" ))
str(data)

# change the names
activityLabels <- read.table(file.path(paths, "activity_labels.txt"),header = FALSE)
names(activityLabels) <- c("activity", "activitynames")
data <- merge(data, activityLabels, by = "activity")
data$activity <- NULL
names(data)[names(data) == "activitynames"] <- "activity"

# replace variable names with more descriptive ones
names(data) <- gsub('^t', 'time', names(data))
names(data) <- gsub('^f', 'frequency', names(data))
names(data) <- gsub('Acc', 'Accelerometer', names(data))
names(data) <- gsub('Gyro','Gyroscope', names(data))
names(data) <- gsub('mean[(][)]','Mean',names(data))
names(data) <- gsub('std[(][)]','Std',names(data))
names(data) <- gsub('-','',names(data))
names(data) <- gsub("Mag", "Magnitude", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))

output_data <- aggregate(. ~subject + activity, data, mean)
output_data <- output_data[order(output_data$subject, output_data$activity),]
str(output_data)

write.table(output_data, file = "tidydata.txt", row.name=FALSE)