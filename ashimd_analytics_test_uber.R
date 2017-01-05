##Answers to Part 3

## 1. ~11% drivers end up driver for Uber after sign up

### 2. Findings from the model

## Everything else remaining same, city of Stark does not have enough drivers driving after signups
## Referral sign ups are good predictor for drivers driving later.
## Drivers with newer cars end up driving for UBER
## The more time it takes to do back ground checks and vehicle addition to the database, the more likely drivers are not to end up driving for UBER




#### 3. Insights that UBER can take a note of:

## Encourage more referrals since drivers can bring in more drivers who actually want to drive
## Partner with 3rdparties to do faster background checks- Reduce the time it takes for back ground checks and vehicle addition
## Partner with car manufacturers and give discount on purchase if cars bought from them would be used for UBER
## City of Stark is doing better, probably time to share some opertional learnings from city of Stark and implement them in Wrouver



setwd("/Users/ashimdatta/Documents/uber analytics test")
library("sqldf")
library("randomForest")
library("ggplot2")
library("gridExtra")
library("lubridate")
library("Hmisc")

driver_signups<-read.csv("Marketing Analytics data set.csv")

#1.What fraction of the driver signups took a first trip?  (2 points)

drivers_who_took_firstrip<-length(unique(driver_signups
                                         [which(driver_signups$first_completed_date!=''),'id']))

## Fraction of driver signups who took a first trip =

print(drivers_who_took_firstrip/length(unique(driver_signups$id))*100)

##2.Build a predictive model to help Uber determine whether or not a driver signup will start driving.

#creating a column for indicating that a driver started driving

driver_signups$start_driving_ind<-ifelse(driver_signups$first_completed_date=='',0,1)

## creating column for days taken for bgc_completed from signup date
driver_signups$days_for_bgc<-as.Date(driver_signups$bgc_date, format = "%m/%d/%y")- 
  as.Date(driver_signups$signup_date, format = "%m/%d/%y")

## creating column for days taken for vehicle adding from bgc complete date
driver_signups$days_for_vehicleadd<-as.Date(driver_signups$vehicle_added_date, format = "%m/%d/%y")- 
  as.Date(driver_signups$signup_date, format = "%m/%d/%y")

### Note there is a bad record= For one driver id- 9269, vehicle add date is smaller than sign up date

### Day of the week week when signup happens may be a predictor for driver retention. Creating a column for day of the week for signup

driver_signups$day_of_week_signup<-weekdays(as.Date(driver_signups$signup_date, format="%m/%d/%y"))

## creating a final dataset which we will use to predict if a driver ends up driving for uber after signup

final_data_driver_signup<-driver_signups[c(2,3,4,8,9,10,13,14,15,12)]

## creating training and test dataset

##75% for training and 25% for testing accuracy

split <- sample(seq_len(nrow(final_data_driver_signup)), size = floor(0.75 * nrow(final_data_driver_signup)))
trainData <- final_data_driver_signup[split, ]
testData <- final_data_driver_signup[-split, ]

## Using logistic regression as the dependent variable is categorical

model <- glm(start_driving_ind ~.,family=binomial(link='logit'),data=trainData)

summary(model)

### too many types of vehicle make and model without any significant variable. We should probably remove them or think about how we can group them into car type

## Recreating the model with lesser variables
final_data_driver_signup<-driver_signups[c(2,3,4,10,13,14,15,12)]

##75% for training and 25% for testing accuracy

split <- sample(seq_len(nrow(final_data_driver_signup)), size = floor(0.75 * nrow(final_data_driver_signup)))
trainData <- final_data_driver_signup[split, ]
testData <- final_data_driver_signup[-split, ]

## Using logistic regression as the dependent variable is categorical

model <- glm(start_driving_ind ~.,family=binomial(link='logit'),data=trainData)

summary(model)

anova(model, test="Chisq")

fitted.results <- predict(model,newdata=testData,type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)

misClasificError <- mean(fitted.results != testData$start_driving_ind, na.rm = TRUE)
print(paste('Accuracy',1-misClasificError))

## This is a pretty good model since it can predict the results with ~78% accuracy

#### All types of os signups are turning out to be significant. Let us try to create a model by removing signup_os

## Recreating the model with lesser variables
final_data_driver_signup<-driver_signups[c(2,4,10,13,14,15,12)]

##75% for training and 25% for testing accuracy

split <- sample(seq_len(nrow(final_data_driver_signup)), size = floor(0.75 * nrow(final_data_driver_signup)))
trainData <- final_data_driver_signup[split, ]
testData <- final_data_driver_signup[-split, ]

## Using logistic regression as the dependent variable is categorical

model <- glm(start_driving_ind ~.,family=binomial(link='logit'),data=trainData)

summary(model)


anova(model, test="Chisq")

fitted.results <- predict(model,newdata=testData,type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)

misClasificError <- mean(fitted.results != testData$start_driving_ind, na.rm = TRUE)
print(paste('Accuracy',1-misClasificError))

## This is a even better model with ~79% accuracy

### 2. Findings from the model

## Everything else remaining same, city of Stark does not have enough drivers driving after signups
## Referral sign ups are good predictor for drivers driving later.
## Drivers with newer cars end up driving for UBER
## The more time it takes to do back ground checks and vehicle addition to the database, the more likely drivers are not to end up driving for UBER




#### 3. Insights that UBER can take a note of:

## Encourage more referrals since drivers can bring in more drivers who actually want to drive
## Partner with 3rdparties to do faster background checks- Reduce the time it takes for back ground checks and vehicle addition
## Partner with car manufacturers and give discount on purchase if cars bought from them would be used for UBER
## City of Stark is doing better, probably time to share some opertional learnings from city of Stark and implement them in Wrouver





