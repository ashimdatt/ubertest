#####Uber User Retaintion problem

### Author- Ashim Datta
### Email- datta.ashim2@gmail.com

# Answers 1. Percent of retained users: 37.608

# Asnwer 2. Significant variables includes the following. For all variables remaining equal the following holds true for people being retained:
#1. Being from King's Landing and Winterfell increases the log odds by 1.8 and .408 respectively
# 2. Being an iPhone user increase the log odds by 1.5 
# 3. Being an uber black user increase the log odds by .89 
# 4. An unit increase in trips during the first 30 days increases the log odds by .09 
# 5. An unit increase in average distance travelled reduces the log odds by .04
# 6. An unit increase in ratings given by driver reduces the log odds by .2 

## Model accuracy: 75.4% accurate in predicting True positives for outcomes for a threshold of .5

#Answer 3. Key insights from the model:
# 1. Incentivising people: Smooth onboarding for users and make sure that they take more rides during the first few days, incentivise/encourage them to use uber black and make sure that iPhone customers are always happy.
# 2. Optimising not just based on ratings: Think about optimising rides for users not just by their ratings by drivers but also based on the number of rides they have taken with uber
# 3. Operations and services: Learn from the way the cities of King's Landing and Winterfell are managed. Think about increasing services to nearby cities if it does not exist already.

##Read below for detailed solution and methodology

## Extracting Data
setwd("/Users/ashimd/Documents/utest_files_ashimdatta_correction")
library(RJSONIO)
data_raw<-fromJSON('uber_data_challenge.json')

#testing that the data is loaded correctly
data_raw[[1]][[1]]
city<-sapply(data_raw, function(x) x[[1]])

head(city)

#converting the data into a dataframe format 

library(gdata) # for the trim function
grabInfo<-function(var){
  print(paste("Variable", var, sep=" "))  
  sapply(data_raw, function(x) returnData(x, var)) 
}

returnData<-function(x, var){
  if(!is.null( x[[var]])){
    return( trim(x[[var]]))
  }else{
    return(NA)
  }
}


rides_data<-data.frame(sapply(1:12, grabInfo), stringsAsFactors=FALSE)

# column names
columns<-c('city','trips_in_first_30_days','signup_date','avg_rating_of_driver','avg_surge',
           'last_trip_date','phone','surge_pct','uber_black_user','weekday_pct',
           'avg_dist','avg_rating_by_driver')
names(rides_data)<-columns
#assuming that the at least one user had used uber on the day this data was pulled

todays_date<-max(rides_data$last_trip_date)
summary(rides_data)

#creating a column for unique ids of users

id<-rownames(rides_data)
rides_data<-cbind(id=id,rides_data) 


#defining retained users- users who took a trip in the 30 days prior to today's date

rides_data$retained<-ifelse(as.Date(todays_date)-as.Date(rides_data$last_trip_date)<=30,1,0)

percent_users_retained<-(sum(rides_data$retained)/nrow(rides_data))*100

# Answer to question 3.1 Percent of retained users:
print(percent_users_retained)

#univariate analysis to learn more about each independent variable

# City

city<-table(rides_data$city)
x<-barplot(city)

# Most of the users are from Winterfell- Need to know if there was heavy campaigning in this city or 
#if the size of the city is bigger compared to all other cities

# trips in the first 30 days- This is a good indicator how active the user was in the first few days
trips_in_first_30_days<-table(rides_data$trips_in_first_30_days)
print(quantile(as.numeric(rides_data$trips_in_first_30_days),probs=c(.5,.75,.9,1)))
plot(trips_in_first_30_days)

#50 percent of users took at least 1 trip and 90 percent of users took at least 6 rides in the first 30 days. This might vary by cities. Will be interesting to explore if this turns out to be an important variable

# Average Rating of driver

avg_rating_of_driver<-table(rides_data$avg_rating_of_driver)
print(quantile(as.numeric(rides_data$avg_rating_of_driver),probs=c(.5,.75,.9,1),na.rm = T))
plot(avg_rating_of_driver)

# Intersting to note that on an average people rate drivers very highly. 

# Average surge: 

avg_surge<-table(rides_data$avg_surge)
quantile(as.numeric(rides_data$avg_surge),probs=c(.5,.75,.9,1),na.rm = T)
plot(avg_surge)

# Not a lot of surge pricing being applied. Perhaps this area is not as crowded. The ratio of drivers to rides is perhaps good

#phones used by uers

phone<-table(rides_data$phone)
phonep<-barplot(phone)

# Most of the users are on iphone. 

# is it percent of amount spent on surge?
surge_pct<-table(rides_data$surge_pct)
print(quantile(as.numeric(rides_data$surge_pct),probs=c(.5,.75,.9,1),na.rm = T))
spctp<-plot(surge_pct)

# not sure what the above variable means but would love to get more context

#if an user has used uber black- Probably and indication of affluence
uber_black_user<-table(rides_data$uber_black_user)
barplot(uber_black_user)

#Expectedly less uber black users. Indicates that the cities have a good mix of affluent and non affluent users. Would be interesting to explore how it compares to the census data from the cities

#is it percent of trips during weekdays
weekday_pct<-table(rides_data$weekday_pct)
quantile(as.numeric(rides_data$weekday_pct),probs=c(.5,.75,.9,1),na.rm = T)
plot(weekday_pct)

#need more clarity on the above variable. Probably means percent of rides during weekdays. If so then it shows most of the users ride during weekdays. Probably uber is their ride to work

#average distance per ride by each user
avg_dist<-table(rides_data$avg_dist)
quantile(as.numeric(rides_data$avg_dist),probs=c(.5,.75,.9,1),na.rm = T)
avgdp<-plot(avg_dist)

#On an average 50 percent of users travel less than 3.88 units of distance. 90% of users travel less than 13 units of distance. This information could be useful to let drivers know about the maximum distance they might have to take each user to

# Average rating by driver
avg_rating_by_driver<-table(rides_data$avg_rating_by_driver)
quantile(as.numeric(rides_data$avg_rating_by_driver),probs=c(0,.25,.5,.75,.9,1),na.rm = T)
plot(avg_rating_by_driver)

# Drivers rate users very highly. Very very few users have ratings below 5. We need to look at all cases with ratings below 4.7 and find out the reasons why. These customers could have specific problems

#Next let us try to answer question 3 part 2. Since our dependent variable is binary, so we will apply logistic regression
# Assuming the data set is randomly arranged- Taking 90 percent data to train and 10 percent to test. Note that I have not used the date of sign up and last trip date as date of sign up is January for everyone and last trip date (this is indirectly our independent variable) was used to determine retained users

rides_data_train<-rides_data[1:4500,c(2,3,5,6,8,9,10,11,12,13,14)]
rides_data_test<-rides_data[4501:5000,c(2,3,5,6,8,9,10,11,12,13,14)]

#applying logistic model. Treating categorical variables as factors and others as numeric

model <- glm(retained ~ 
               factor(city) + factor(phone)+ factor(uber_black_user)+
               as.numeric(trips_in_first_30_days)+ as.numeric(avg_rating_of_driver)+
               as.numeric(avg_surge)+as.numeric(surge_pct)+as.numeric(weekday_pct)+
               as.numeric(avg_dist)+as.numeric(avg_rating_by_driver),family=binomial(link='logit'),data=rides_data_train)
summary(model)


# Lots of interesting observations here. Significant variables includes the following with the following insights. For all variables remaining equal the following holds true for people being retained:

# 1. Being from King's Landing and Winterfell increases the log odds by 1.8 and .408 respectively- It will be useful for uber executives to find out how King's Landing and Winterfell is doing so well. They can learn from the way operations are run in those offices
# 2. Being an iPhone user increase the log odds by 1.5 - iPhone users are loyal customers. Uber executives should try to make sure that iPhone app always runs without any problem. Special offers could be given to iPhone users for being so loyal
# 3. Being an uber black user increase the log odds by .89 - Interesting to learn that the loyal customers are also uber black users. This shows that uber is preferred by customers for its quality of service. Buiding for affluent users can be useful for Uber in the long run. Additionally it will be interesting if uber can incentivise users to use black service once in a while. This can increase their loyalty greatly
# 4. An unit increase in trips during the first 30 days increases the log odds by .09 - Expectedly highly active users are the ones who continue to use uber. This indicates the power of good onboarding. Uber executives should make sure that the service quality to its new users are absolutely impecable. Also perhaps try to incentivise users to do more trips during the 1st few weeks.
# 5. An unit increase in average distance travelled reduces the log odds by .04- Long distance travellers seem to stop using uber. This could because these travellers are perhaps from a differnt city where uber does not have service. So they probably use it whenever they are in the mentioned 3 cities to travel to their cities and are not able to use it when they are out of it. It will be interesting to learn where these people travel to and check if uber has services there.
# 6. An unit increase in ratings given by driver reduces the log odds by .2 - This is very interesting. Apparently it might seem like people rated higher by drivers are better customers specially when we can see that there is only a few users are rated badly (from univariate analysis earlier only 25% of users have ratings below 4.7). This could be because users who have been there for long enough will automatically have a lower rating as they will definitely have some trips with a lower rating. Ratings for retained regular users perhaps saturates at a certain level. Let us explore that quickly below:

### Ratings by drivers for retained users vs un-retained users

retained_users<-rides_data[which(rides_data$retained==1),]
avg_rating_by_driver_for_retained_users<-table(retained_users$avg_rating_by_driver)
quantile(as.numeric(retained_users$avg_rating_by_driver),probs=c(0,.25,.5,.6,.75,.9,1),na.rm = T)
plot(avg_rating_by_driver_for_retained_users)

un_retained_users<-rides_data[which(rides_data$retained==0),]
avg_rating_by_driver_for_un_retained_users<-table(un_retained_users$avg_rating_by_driver)
quantile(as.numeric(un_retained_users$avg_rating_by_driver),probs=c(0,.25,.5,.6,.75,.9,1),na.rm = T)
plot(avg_rating_by_driver_for_un_retained_users)

## Expectedly retained users seem to have a lower rating than un-retained ones. It probably makes sense for uber executives to optimise rides for users not just based on absolute ratings given by drivers but a combination of ratings and number of rides that the user had taken previously.

# Few more stats on measuring deviance to show how it changes as we go on adding variables to the model.
#Annova to find the deviance table
anova(model, test="Chisq")

#Expectedly, the less signficant variables do not change the deviance much. I'm just happy that the 2 variables(surge_pct and weekday_pct) which I could not understand clearly did not turn out to be significant. Sigh... :P

#assesing model fit
library(pscl)
pR2(model)

#  McFadden coefficient is probably an ideal subsitute for R^2 in linear regression. This is a decent coeffiecient. So good to go ahead

# Testing accuracy of the model

fitted.results <- predict(model,
                          newdata=subset(rides_data_test,select=c(1,2,3,4,5,6,7,8,9,10,11)),type='response')
fitted.results <- ifelse(fitted.results > .5,1,0)
fitted.results[is.na(fitted.results)] <- 0
misClasificError <- mean( fitted.results != rides_data_test$retained)
print(paste('Accuracy',1-misClasificError))

# 75.4% accurate in predicting True positives for outcomes for a threshold of .5. This is pretty good since I used a strong threshold. Next let us look how the accuaracy varies as we change the threshold.

#Receiving operator rate for TPR VS FPR at various threshold 

library(ROCR)
p <- predict(model, newdata=subset(rides_data_test,select=c(1,2,3,4,5,6,7,8,9,10,11)), type="response")
pr <- prediction(p, rides_data_test$retained)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")
plot(prf)

#Overall let us look at how accuracy for true positives and false positives vary if we change the threshold

auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc

# This is very close to 1. This indicates that the model is a good one!

# Answer to question 3 part 3
# Overall here my 3 points around the following themes for Uber executives to work on to retain users:

# 1. Incentivising people: Smooth onboarding for users and make sure that they take more rides during the first few days, incentivise/encourage them to use uber black and make sure that iPhone customers are always happy.
# 2. Optimising not just based on ratings: Think about optimising rides for users not just by their ratings by drivers but also based on the number of rides they have taken with uber
# 3. Operations and services: Learn from the way the cities of King's Landing and Winterfell are managed. Think about increasing services to nearby cities if it does not exist already.

##########################-------------------------------Thanks--------------------------------##########

