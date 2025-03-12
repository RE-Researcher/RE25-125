######################################################################
# It was created using RStudio for OSX
#   Version: 2024.04.1+748
# which required R 3.6.0+ (but we used the R 4.2.2 binary).
######################################################################

######################################################################
# Part 0: Separate data into appropriate files.
######################################################################
library(readr)  #To read the data.
library(dplyr)

# Get raw data.
headers = read.csv("class-study/raw-anonymous.csv", header = F, nrows = 1, as.is = T)
dfInput = read.csv("class-study/raw-anonymous.csv", skip = 3, header = F)
colnames(dfInput) = headers

# Create quantitative data set and backup.
dfQuan <- dfInput[c("ID","A1","A3","B2","B3","B4","C2","C3","C4",  
                    "D1","D2","D3","E1","E2","F2","F3","G2","G3","H1","H2")]
write.csv(dfQuan, "quantitative-data.csv")

# Store qualitative data for adjudication.
dfQual <- dfInput[c("ID","A2","A4","B1","C1","D4","E3","E4","F1",
                  "F4","G1","G2_3_TEXT","G4","G5","H3","H4")] 
write.csv(dfQual, "qualitative-data.csv")
rm(dfQual)

# Store student recommendations for manual analysis.
recc <- dfInput[c("ID","Wrap-1","Wrap-1_2_TEXT","Wrap-2","Wrap-2_2_TEXT",
                  "Wrap-3","Wrap-4","Wrap-5_1","Wrap-5_2","Wrap-5_3","Wrap-5_4",
                  "Wrap-5_5","Wrap-5_6","Wrap-5_5_TEXT","Wrap-6","Wrap-7","Wrap-8","Wrap-Comments")]
write.csv(recc, "recommendations-data.csv")

# Remove data frames.
rm(headers)
rm(dfInput)

######################################################################
# Part 1: Merge qualitative and quantitative data to create scores.
#
#   Note: this part requires the file 'qualitative-data-adjudicated.csv'
#   With is the final step of the manual adjudication process completed in
#   'qualitative-data-anotated.xlsx'
######################################################################
library(dplyr)
library(rlang)
library(purrr)

dfQual = read.csv("class-study/qualitative-data-adjudicated.csv") #, check.names = FALSE)
dfQual$X= NULL  # Remove column X from the data frames

# Join two tables.
dfResponse = full_join(x=dfQuan, y=dfQual, by="ID")
colnames(dfResponse)

rm(dfQuan)
rm(dfQual)

header = colnames(dfResponse) # Gets column names
data = transpose(as.list(dfResponse)) # Converts csv data to a list of lists

questions = c('A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3', 
              'C4', 'D1', 'D2', 'D3', 'D4', 'E1', 'E2', 'E3', 'E4', 'F1', 'F2', 
              'F3', 'F4', 'G1', 'G2', 'G3', 'G4', 'G5', 'H1', 'H2', 'H3', 'H4')
answers   = c('2',  '1',  '1',  '1',  '1',  '4',  '2',  '1',  '1',  '2',  '2',  
              '1',  '3',  '5',  '1',  '1',  '4',  '1',  '1',  '1',  '1',  '2',  
              '1',  '1',  '1',  '2',  '2',  '1',  '1',  '1',  '2',  '1',  '1')  
without   = c('A1', 'A2', 'A3', 'A4', 'D1', 'D2', 'D3', 'D4', 'E1', 'E2', 'E3', 'E4', 'H1', 'H2', 'H3', 'H4')
with      = c('B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3', 'C4', 'F1', 'F2', 'F3', 'F4', 'G1', 'G2', 'G3', 'G4', 'G5')
with_noLB = c('B2', 'B3', 'B4', 'C2', 'C3', 'C4', 'F2', 'F3', 'F4', 'G2', 'G3', 'G4', 'G5')

scores = dfResponse # Duplicating data to create a scores table
scores = scores[, questions] # Removing ID column, rearranging columns to align with the questions/answers vector

for(i in 1:nrow(scores)) { # Looping over rows
  for(j in 1:ncol(scores)) { # Looping over columns
    if(is.na(scores[i,j])) { # Checking if value is NA, if yes, setting score to 0
      scores[i,j] = 0
    }
    else if(scores[i,j] == answers[j]) { # Checking if response is correct, if yes, setting score to 1
      scores[i,j] = 1 
    }
    else { # If answer is incorrect, setting score to 0
      scores[i,j] = 0
    }
  }
}

scores$ID = dfResponse$ID # Re-adding ID column to data frame
# Reordering columns so that ID comes first
scores = scores[, c('ID', 'A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B4', 'C1', 'C2', 'C3', 
                    'C4', 'D1', 'D2', 'D3', 'D4', 'E1', 'E2', 'E3', 'E4', 'F1', 'F2', 
                    'F3', 'F4', 'G1', 'G2', 'G3', 'G4', 'G5', 'H1', 'H2', 'H3', 'H4')]

# Adding up the total score and making a new column total_score
scores$total <- rowSums((scores[, questions]))
# Adding up the score without and making a new column percent_score_without that is formatted __._
scores$tot_WO <- round((rowSums((scores[, without]))/length(without))*100, digits=1)
# Adding up the score with and making a new column percent_score_with that is formatted __._
scores$tot_EX <- round((rowSums((scores[, with]))/length(with))*100, digits=1)
# Adding up the score with noLB and making a new column percent_score_with_noLB that is formatted __._
scores$tot_EX_noLB <- round((rowSums((scores[, with_noLB]))/length(with_noLB))*100, digits=1)

rm(answers)
rm(header)
rm(i)
rm(j)
rm(questions)
rm(with)
rm(with_noLB)
rm(without)

rm(data)
rm(dfResponse)

summary(scores$total)

######################################################################
# Part 2: Analysis
#####################################################################
library(reshape2) #required for melt

######################################################################
#### (a) Review score data for questions with and without explanations.
df_test <- scores[c("ID","tot_WO","tot_EX")]
df_test_lg <- melt(df_test, id = "ID")
ggplot(df_test_lg, aes(x = variable, y = value)) + geom_boxplot()

rm(df_test)
rm(df_test_lg)

######################################################################
#### (b) Review score data for questions with and without explanations,
####   BUT exclude LLM-Belief questions. 

## (i) Create bar graph for paper of individual scores with and without
##    explanations, excluding LLM-Belief questions.
bar_df <- scores[c("ID","tot_WO","tot_EX_noLB")]
bar_df <- rename(bar_df, c(
  "Without Explanation" = "tot_WO",
  "With Explanation" = "tot_EX_noLB"))

bar_df_long <- melt(bar_df, id = "ID")
p <- ggplot(bar_df_long, aes(fill=variable, y = value, x=ID))
p <- p + geom_bar(width=.7, position=position_dodge(.7), stat='identity') 
p <- p + theme_light()
p <- p + xlab("Student ID")
p <- p + ylab("Percentage Correct")
p <- p + theme(legend.position="bottom")
p <- p + theme(legend.title = element_blank())
p <- p + theme(text = element_text(size = 14))
p <- p + theme(legend.text = element_text(family = "mono",size = 12))
p <- p + scale_fill_grey(start = 0.2, end = 0.8, na.value = "red")
p
#Exported as .png with dimensions 600x300.
rm(bar_df)
rm(bar_df_long)
rm(p)

## (ii) Determine if there is a statistical difference between scores with and 
##      without explanations, excluding LLM-Belief questions.
##      Ref: https://www.seodle.info/toolbox/R_paired_samples_wilcoxon_test.html
## Null hypothesis: The median difference between the percentage scores for 
##  students given the pairs of observations (with and without) equals zero.
## Assumptions: pairs are random and independent.
##      distributions between the groups must be symmetric.
##      no assumption of normality.
# install.packages("dplyr")
# install.packages("devtools")
# install.packages("ggpubr")
# install.packages("ggplot2")
# install.packages("PairedData")
# install.packages("lawstat")
library(dplyr)
library(devtools)
library(ggplot2)
library(ggpubr)
library(magrittr)
library(PairedData)
library(lawstat)

df_wilcox_test <- scores[c("tot_WO","tot_EX_noLB")]
without_ex <- c(df_wilcox_test$tot_WO)
with_ex <- c(df_wilcox_test$tot_EX_noLB)

# Test for symmetry.
paired_difference <- without_ex - with_ex 
summary(paired_difference)
symmetry.test(paired_difference, option = c("MGG", "CM", "M"))

# Finally, run Wilcox test.
wilcox.test(without_ex, with_ex, paired = TRUE) #p-value = 0.03297

rm(paired_difference)
rm(df_wilcox_test)
rm(without_ex)
rm(with_ex)


######################################################################
#### (c) Review the Period 3 data.

## (i) Wrap-3 and Wrap-4 Data Analysis. 
#Wrap-3 LTL was more challenging (1); similarly (2); less challenging (3)
#Get counts of each response.
table(recc$`Wrap-3`)

#Not at all helpful (1); Slightly helpful (2); Moderately helpful (3); Very helpful (4); Extremely helpful (5)
#Get counts of each response.
table(recc$`Wrap-4`)


## (ii) Create graph for subjects finding explanations helpful from Wrap-4
library(psych)
library(ggplot2)
library(xtable)
library(likert)
li <- recc[c("Wrap-4")]
li$"Wrap-4" = factor(li$"Wrap-4", levels = c("1","2","3","4","5"), 
                     labels = c("Not at all","Slightly","Moderately","Very","Extremely"), ordered = TRUE)
li <- rename(li, c("Explanation Helpful" = "Wrap-4"))
result = likert(li)
plot(result,type="bar")



## (iii) Create a table of values for Wrap-5.
library(tidyverse)
chalAspect <- recc[c("Wrap-5_1","Wrap-5_2","Wrap-5_3","Wrap-5_4",
                     "Wrap-5_5","Wrap-5_6")]
dfchall<-data.frame("Syntax", sum(chalAspect$"Wrap-5_1" == 1, na.rm=TRUE))
names(dfchall)<-c("Name","Count")
dfchall[nrow(dfchall) + 1,] <- c(Name = "Operators", Count = sum(chalAspect$"Wrap-5_2" == 1, na.rm=TRUE))
dfchall[nrow(dfchall) + 1,] <- c(Name = "Implication", Count = sum(chalAspect$"Wrap-5_3" == 1, na.rm=TRUE))
dfchall[nrow(dfchall) + 1,] <- c(Name = "Apply Sequence", Count = sum(chalAspect$"Wrap-5_4" == 1, na.rm=TRUE))
dfchall[nrow(dfchall) + 1,] <- c(Name = "Other", Count = sum(chalAspect$"Wrap-5_5" == 1, na.rm=TRUE))
dfchall[nrow(dfchall) + 1,] <- c(Name = "None", Count = sum(chalAspect$"Wrap-5_6" == 1, na.rm=TRUE))
dfchall   # Shows the table.

rm(chalAspect)
rm(li)  
rm(result)
rm(dfchall)
rm(recc)

##############################################################################
# End
rm(scores)
