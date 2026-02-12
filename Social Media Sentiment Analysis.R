install.packages("tm")
install.packages("nnet")
install.packages("e1071")
install.packages("caret")
library(ggplot2)
library(plotly)
library(dplyr)
library(tm)
library(nnet)
library(e1071)
library(caret)
library(caTools)


SocialMediaData <- read.csv(file.choose())

#Handling Null Values
sum(is.na(SocialMediaData))
SocialMediaData <- na.omit(SocialMediaData)

#Preview
head(SocialMediaData)
str(SocialMediaData)
summary(SocialMediaData)

#EDA Exploratory Data Analysis
  #1. Sentiment Distribution Chart

  Count_Table <-table(SocialMediaData$Sentiment.Label)
  barplot(
    Count_Table,
    col = "steelblue",
    border = "black",
    main = "Sentiment Distribution Chart",
    xlab = "Sentiment",
    ylab = "Number of Posts"
  )
 
  #2.Likes vs Sentiment
  Total_Positive_Post_Count <- sum(SocialMediaData$Sentiment.Label == "Positive")
  Total_Negative_Post_Count <- sum(SocialMediaData$Sentiment.Label == "Negative")
  Total_Neutral_Post_Count <- sum(SocialMediaData$Sentiment.Label == "Neutral")
  
  Total_Positive_Likes_Count <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Sentiment.Label=="Positive"])
  Total_Negative_Likes_Count <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Sentiment.Label=="Negative"])
  Total_Neutral_Likes_Count <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Sentiment.Label=="Neutral"])
  
  Average_Positive_Likes <- Total_Positive_Likes_Count / Total_Positive_Post_Count
  Average_Negative_Likes <- Total_Negative_Likes_Count / Total_Negative_Post_Count
  Average_Neutral_Likes <- Total_Neutral_Likes_Count / Total_Neutral_Post_Count
  
  Average_Likes_Sentiment <- data.frame(
   Sentiment = c("Positive","Negative","Neutral"),
    Average_Likes = c(Average_Positive_Likes,Average_Negative_Likes,Average_Neutral_Likes)
  )
  head(Average_Likes_Sentiment)
  #2.1 Bar Plot
  barplot(
    height = Average_Likes_Sentiment $Average_Likes,
    names.arg = Average_Likes_Sentiment $Sentiment,
    col = "coral",
    border = 'black',
    xlab = "Sentiment",
    ylab = "Average Likes",
    main = "Average Likes per Sentiment"
  )
  
  #3. Most Liked Posts (Top 10 Post IDs)
  Sorted_by_likes <- arrange(SocialMediaData,desc(Number.of.Likes))
  head(Sorted_by_likes,10)
  
  #4. Engagement Comparison (Likes, Shares, Comments)
  
  Engagement_score <- data.frame(
    Total_Likes = sum(SocialMediaData$Number.of.Likes),
    Total_Shares = sum(SocialMediaData$Number.of.Shares),
    Total_Comments = sum(SocialMediaData$Number.of.Comments)
  )
  
  engagement_values <- c(
    Engagement_score$Total_Likes,
    Engagement_score$Total_Shares,
    Engagement_score$Total_Comments
  )
  
  engagement_names <- c("Likes", "Shares", "Comments")
  
  barplot(
    height = engagement_values,
    names.arg = engagement_names,
    col = c("darkred", "steelblue", "darkgreen"),
    border = "black",
    ylab = "Total Engagement",
    main = "Engagement Comparison (Likes, Shares, Comments)"
  )
  
  #5. Post Type vs Likes
  Image_post_data <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Post.Type == 'image'])
  Text_post_data <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Post.Type == 'text'])
  Video_post_data <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Post.Type == 'video'])
  
  Post_based_on_likes <- c(
    Image_post_data,
    Text_post_data,
    Video_post_data
  )
  Post_like_names <- c("Image_Posts","Text_Posts","Video_Posts")
  barplot(
    height = Post_based_on_likes,
    names.arg = Post_like_names,
    col = c("steelblue","darkorange","green"),
    border = "black",
    ylab = "Likes Based on Post Types",
    main = "Post Type vs Likes"
  )
  
  #6. Followers vs Likes chart 
  
  ggplot(
    SocialMediaData,
    aes(x = User.Follower.Count, y = Number.of.Likes)
  ) +
    geom_point(color = "steelblue") +
    geom_smooth(method = "lm", se = FALSE, color = "red") +
    labs(
      x = "Follower Count",
      y = "Likes on Post",
      title = "Followers vs Likes Relationship"
    ) +
    theme_minimal()
  #7. Language-wise Engagement
  
  Language_table <- table(SocialMediaData$Language)
  Total_de_post_Likes <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Language == "de"])
  Total_en_post_Likes <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Language == "en"])
  Total_es_post_Likes <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Language == "es"])
  Total_fr_post_Likes <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Language == "fr"])
  Total_zh_post_Likes <- sum(SocialMediaData$Number.of.Likes[SocialMediaData$Language == "zh"])
  
  Language_based_data <- c(
    German_likes = Total_de_post_Likes,
    English_likes = Total_en_post_Likes,
    Spanish_likes = Total_es_post_Likes,
    French_likes = Total_fr_post_Likes,
    Chinese_likes = Total_zh_post_Likes
  )
  languages_cols = c("German","English","Spanish","French","Chinese")
  barplot(
    Language_based_data,
    names.arg = languages_cols,
    col = c("skyblue","green","orange","steelblue","pink"),
    border = "black",
    xlab = "Languages",
    ylab = "Total likes",
    main = "Language-wise Engagement"
  )
    #------ ---or ------------
  
  Language_based_data_short <- tapply(
    SocialMediaData$Number.of.Likes,
    SocialMediaData$Language,
    sum
  )
  
  barplot(
    Language_based_data,
    col = "grey",
    border = "black",
    xlab = "Language",
    ylab = "Total Likes",
    main = "Language-wise Engagement"
  )
  #8.User Engagement Level Analysis
  Low_Followers <- sum(SocialMediaData$Number.of.Likes[
    SocialMediaData$User.Follower.Count < 1000
  ])
  
  Medium_Followers <- sum(SocialMediaData$Number.of.Likes[
    SocialMediaData$User.Follower.Count >= 1000 &
      SocialMediaData$User.Follower.Count < 5000
  ])
  
  High_Followers <- sum(SocialMediaData$Number.of.Likes[
    SocialMediaData$User.Follower.Count >= 5000
  ])
  
  Followers_Based_likes <- c(
    Low_Followers_users = Low_Followers,
    Medium_Followers_Users = Medium_Followers,
    High_Followers_Users = High_Followers
  )
  Followers_cols = c("LowFollowers","MediumFollowers","HighFollowers")
  
  barplot(
    Followers_Based_likes,
    names.arg = Followers_cols,
    col = c("steelblue","darkorange","green"),
    border = "black",
    ylab = "Total Likes",
    main = "Likes Based on Followers"
    )
  legend(
    "topleft",
    legend = Followers_cols,
    col = c("steelblue","darkorange","green"),
    pch = 15
  )
  #Text Pre-processing
  #1. Converting into Lower Case
  SocialMediaData$Clean_Post_Content <- tolower(SocialMediaData$Post.Content)
  
  #2. Removing numbers and Special Characters
  SocialMediaData$Clean_Post_Content <- gsub("[^a-z ]","",SocialMediaData$Clean_Post_Content)
  
  #3. Removing Unused words
  stops_words <- c("the","is","am","are","and","this","that")
  SocialMediaData$Clean_Post_Content <- gsub(paste(stops_words,collapse = "|"),"",SocialMediaData$Clean_Post_Content)
  
  #4. Tokenization
  SocialMediaData$Clean_Post_Content <- strsplit(SocialMediaData$Clean_Post_Content , " ")
  head(SocialMediaData$Clean_Post_Content)
  
  #TF-IDF
  #TF (Term Frequency)
  #IDF (Inverse Document Frequency)
  
  corpus <- VCorpus(VectorSource(SocialMediaData$Clean_Post_Content))
  
  tfidf_df <- DocumentTermMatrix(
    corpus,
    control = list(
      weighting = weightTfIdf
    )
  )
  
  dim(tfidf_df)
  
  #ML Algorithms
  #2.Logistc Regression
  SocialMediaData$Sentiment.Label <- as.factor(SocialMediaData$Sentiment.Label)
  
  multiclass_logistic_model <- multinom(
    Sentiment.Label ~ Number.of.Likes + Number.of.Shares +
      Number.of.Comments + User.Follower.Count,
    data = SocialMediaData
  )
  
  summary(multiclass_logistic_model)
  
  #Predicting Data
  predicted_probs <- predict(multiclass_logistic_model,type = "probs")
  
  predicted_probs_dataframe <- as.data.frame(predicted_probs)
  
  predicted_probs_dataframe$Post_ID <- 1:nrow(predicted_probs_dataframe)
  prob_df_sample <- predicted_probs_dataframe[1:20, ]
  
  plot_ly(prob_df_sample, x = ~Post_ID, y = ~Positive, type = "bar", name = "Positive") %>%
    add_trace(y = ~Neutral, name = "Neutral") %>%
    add_trace(y = ~Negative, name = "Negative") %>%
    layout(
      barmode = "stack",
      title = "Predicted Sentiment Probabilities per Post",
      xaxis = list(title = "Post"),
      yaxis = list(title = "Probability")
    )
  
  
  #2. Naive Bayes model
  
  tfidf_matrix <- as.matrix(tfidf_df)
  
  naive_bayes_data <- data.frame(
    tfidf_matrix,
    Sentiment.Label = SocialMediaData$Sentiment.Label
  )
  set.seed(18)
  
  split <- sample.split(naive_bayes_data$Sentiment.Label, SplitRatio = 0.7)
  test_data <- naive_bayes_data[split == FALSE, ]
  train_data <- naive_bayes_data[split == TRUE, ]
  
  naive_bayes_model <- naiveBayes(Sentiment.Label ~. ,data = train_data)
  summary(naive_bayes_model)
  
  naive_bayes_prediction <- predict(naive_bayes_model, newdata = test_data)
  summary(naive_bayes_prediction)
  
  #Confusion Matrix
  conf_mat <- table(
    Predicted = naive_bayes_prediction,
    Actual = test_data$Sentiment.Label
  )
  

  summary(conf_mat)
  
  #Visualize the Naive Bayes Data
  confusion_matrix_data <- as.data.frame(conf_mat)
  
  plot_ly(
    data = confusion_matrix_data,
    x = ~Actual,
    y = ~Predicted,
    z = ~Freq,
    type = "heatmap",
    colors = colorRamp(c("skyblue", "blue"))
    
  ) %>%
    layout(
      title = "Naive Bayes Confusion Matrix",
      xaxis = list(title = "Actual Sentiment"),
      yaxis = list(title = "Predicted Sentiment")
    )