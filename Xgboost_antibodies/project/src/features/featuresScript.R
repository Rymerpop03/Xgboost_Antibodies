# Features Script
library(tidyverse)
library(caret)
library(data.table)

#Read in raw data
train <- fread('./project/volume/data/raw/Stat_380_train.csv')
test <- fread('./project/volume/data/raw/Stat_380_test.csv')
sub <- fread('./project/volume/data/raw/Stat_380_sample_submission.csv')

#Create an instance of ic50_omicron as null
test[, ic50_Omicron := NA]
master <- rbind(train, test)

#Declare most relevant features and create master dataset
categorical_cols <- c("sex", "centre", "dose_2", "dose_3", "Sx_severity_most_recent", "priorSxAtFirstVisit", "posTest_beforeVisit")
master[, (categorical_cols) := lapply(.SD, as.factor), .SDcols = categorical_cols]

#Create dummy variable 
dummy_model <- dummyVars("~ .", data = as.data.frame(master), fullRank = TRUE)
combined_data_encoded <- data.frame(predict(dummy_model, newdata = as.data.frame(master)))

train <- combined_data_encoded[1:nrow(train), ]
test <- combined_data_encoded[(nrow(train) + 1):nrow(combined_data_encoded), ]

train <- train %>% select(-Id)
test <- test %>% select(-Id, -ic50_Omicron)

#Write out data to interim
fwrite(train,'./project/volume/data/interim/train.csv')
fwrite(test,'./project/volume/data/interim/test.csv')