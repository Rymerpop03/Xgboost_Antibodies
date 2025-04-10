#Model script
library(xgboost)
library(Matrix)
library(data.table)

#Read in data from interim
train <- fread('./project/volume/data/interim/train.csv')
test <- fread('./project/volume/data/interim/test.csv')
sub <- fread('./project/volume/data/raw/Stat_380_sample_submission.csv')

#
y_train <- train$ic50_Omicron
train <- train %>% select(-ic50_Omicron)

x_train <- as.matrix(train)
x_test <- as.matrix(test)

dtrain <- xgb.DMatrix(data = x_train, label = y_train)
dtest <- xgb.DMatrix(data = x_test)

#Define parameters
params <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  eta = 0.1,
  max_depth = 6,
  subsample = 0.8,
  colsample_bytree = 0.8          
)

#Find best nround (cross-validation)
cv_model <- xgb.cv(
  params = params,
  data = dtrain,
  nrounds = 100,
  nfold = 5,
  early_stopping_rounds = 5,
  verbose = 1
)


best_nrounds <- cv_model$best_iteration

#Create xgb model
xgb_model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = best_nrounds,
  verbose = 1
)

#Predict on dtest
predictions <- predict(xgb_model, dtest)

#Prepare submission file
submission <- data.frame(
  Id = sub$Id,
  ic50_Omicron = predictions
)

saveRDS(xgb_model, "./project/volume/models/xgb.model")
fwrite(submission, './project/volume/data/processed/submission.csv', row.names = FALSE)