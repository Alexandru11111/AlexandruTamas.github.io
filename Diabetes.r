library(tidyverse)
library(psych)
require(dplyr)
library(Hmisc)
library(dplyr)
library(ggplot2)
library(tidyverse)
library(broom)
library(ggplot2)
library(reshape2)
library(corrplot)
library(readxl)             
if (!requireNamespace("ggplot2", quietly = TRUE)) {
library(caret)

  
                                                                      ######### Basics #############
  
  
#loading the dataset
  data<- read.csv("C:\\Users\\Alexandru\\Desktop\\diabetes.csv")
  view(data)
 
  #used to get an overview of our data
  describe(data)
  summary(data)


  # Checking if dataset cointasin missing values
  sum(is.na(data))
  
  #Visuals 
  library(ggplot2)
  # Histogram for a numerical variable
  ggplot(data, aes(x=BloodPressure)) + geom_histogram(binwidth = 5)
  
  # Boxplot for comparing a numerical variable across different groups
  library(ggplot2)
  
  ggplot(data, aes(x=BloodPressure , y=Insulin)) + 
    geom_boxplot() +
    theme_minimal() +
    labs(title = "Balance Distribution by Marital Status", 
         x = "BloodPressure", 
         y = "Insulin")

  
  # Correlation matrix for numerical variables
  cor(data %>% select_if(is.numeric))
  
  
                                                            ############# Fitting a model (Multiple regression) ###############
  

  model_1 <- glm(Outcome ~ BloodPressure + Age + Pregnancies + BMI + Glucose, data = data, family = "binomial")

  
  summary(model_1)
  
  #Predicting probabiliti of diabetes 

  predicted_probabilities <- predict(model_1, type = "response")
  
  # Convert probabilities to binary outcome based on a cutoff (e.g., 0.5)
  predicted_outcome <- ifelse(predicted_probabilities > 0.5, 1, 0)
  



  #Splitting data for training and for prediction 
  
  library(caret)
  
  # Splitting data into training and test sets i allocate 80% of the current dataset into training and 20% into the predictionset i accordance with standard praxis 
  set.seed(123) # For reproducibility
  splitIndex <- createDataPartition(data$Outcome, p = 0.8, list = FALSE)
  trainingData <- data[splitIndex, ]
  testData <- data[-splitIndex, ]
  
 
  # Fitting the model on the training data
  model_1 <- glm(Outcome ~ BloodPressure + Age + Pregnancies + BMI + Glucose, 
                 data = trainingData, family = "binomial")
  summary(model_1)
  
  # Makeing predictions on the test data
  predicted_probabilities_test <- predict(model_1, newdata = testData, type = "response")
  predicted_outcome_test <- ifelse(predicted_probabilities_test > 0.5, 1, 0)
  
  View(predicted_outcome_test)
  
  # Add predictions back to the test data (optional)
  testData$predicted_diabetes <- predicted_outcome_test
  
  # Evaluate model performance
  confusionMatrix <- table(Predicted = predicted_outcome_test, Actual = testData$Outcome)
  accuracy <- sum(diag(confusionMatrix)) / sum(confusionMatrix)
  print(confusionMatrix)
  print(paste("Accuracy:", accuracy))
  
  # print(confusionMatrix)
 # Actual
# Predicted  0  1
 # 0 84 23
  # 1 17 29
  #>   print(paste("Accuracy:", accuracy))
  #[1] "Accuracy: 0.738562091503268"
   
  # My model managed to predict diabites with a 73.9% accuracy.
  
  
                            ##################### Clustering using unsupervised  machine learning algorithms (K-mean) )###########################
  

  # Selecting numeric variables /// Variables should be scaled to have similar ranges to ensure that no variable dominates the clustering algorithm due to its scale
  data_for_clustering <- data %>% select(BloodPressure, Pregnancies, BMI, Glucose)
    
   # Scale the data
    scale_data <- scale(data_for_clustering)

    
    #Selecting clusters 
    set.seed(123) # For reproducibility
    wss <- sapply(1:10, function(k){kmeans(scale_data, k, nstart = 10)$tot.withinss})
    plot(1:10, wss, type="b", xlab="Number of Clusters", ylab="Total Within-Cluster SS")
    
    # Based on the elbow graph 4 clusters is the ideal number. 
    set.seed(123)
    kmeans_result <- kmeans(scale_data, centers = 4, nstart = 20)
    
    print(kmeans_result$centers) # The cluster centroids
    table(kmeans_result$cluster) # The size of each cluster
    
    #For future use i will save the clusters into the original dataset 
    data$cluster <- as.factor(kmeans_result$cluster)

    
    
                                                        ############### VARIANCE TEST ANOVA ##################   
    #hainv identiryed new groups based on variables of intrest we new can use a variance test to evalute diffrances between groups. 
    #Is there any diffrance in diabetes betwwen groups?

    # Assuming 'kmeans_result' is the output of your kmeans clustering
   
    
     anova_result <- aov(Outcome ~ cluster, data = data)
    summary(anova_result)    
    #summary(anova_result)    
    #Df Sum Sq Mean Sq F value Pr(>F)    
    #cluster       3  28.82   9.606   50.38 <2e-16 ***
    #Residuals   764 145.66   0.191                   
    #Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
                
    
    
                                #We found a significant diffrance, next setp is to preforme T-Test to find what cluster contains the diffrance // Project ends here.
    