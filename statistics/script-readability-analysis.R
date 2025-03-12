# This R script is used for the RE'25 Submission.
# It was created using RStudio for MAC
#   Version: 2022.12.0+353 | Released: 2022-12-15
# which required R 3.3.0 (but we used the R 4.2.2 binary).
library(readr)  #To read the data.
library(dplyr) #Required for rename operation.
library(rlang)
library(purrr)
library(reshape2) #required for melt
library(ggplot2)

##############################################################################
### Read Common Data
dfGroups = read.csv("readability-data-in/data-codes.csv")

dfFormulas = read.csv("readability-data-in/formula-ids.csv")

dfInput = read.csv("readability-data-in/readability-scores.csv")
colnames(dfInput)
# Exclude unused columns for analysis.
dfEval1 <- dfInput[,!names(dfInput) %in% c("ID", "Expression", "Summary", "Full")]
rm(dfInput)

df = full_join(x=dfGroups, y=dfEval1, by="ORG_Order")
rm(dfEval1)
colnames(df)

dfStudent = read.csv("readability-data-in/readability-scores-student.csv")
colnames(dfStudent)

##############################################################################
#Open and Store Judgement Files.
dfJudgeAIn = read.csv("readability-data-in/readability-judge-a.csv")
dfJudgeAIn <- dfJudgeAIn[,!names(dfJudgeAIn) %in% c("Rand_Order", "ID", "Expression","Notes")]
dfJudgeA = full_join(x=dfGroups, y=dfJudgeAIn, by="ORG_Order")
#todo: remove data where summary is blank

dfJudgeBIn = read.csv("readability-data-in/readability-judge-b.csv")
dfJudgeBIn <- dfJudgeBIn[,!names(dfJudgeBIn) %in% c("Rand_Order", "ID", "Expression")]
dfJudgeB = full_join(x=dfGroups, y=dfJudgeBIn, by="ORG_Order")

dfJudgeCIn = read.csv("readability-data-in/readability-judge-c.csv")
dfJudgeCIn <- dfJudgeCIn[,!names(dfJudgeCIn) %in% c("Rand_Order", "ID", "Expression")]
dfJudgeC = full_join(x=dfGroups, y=dfJudgeCIn, by="ORG_Order")

dfJudgeDIn = read.csv("readability-data-in/readability-judge-d.csv")
dfJudgeDIn <- dfJudgeDIn[,!names(dfJudgeDIn) %in% c("Rand_Order", "ID", "Expression")]
dfJudgeD = full_join(x=dfGroups, y=dfJudgeDIn, by="ORG_Order")

dfJudgeEIn = read.csv("readability-data-in/readability-judge-e.csv")
dfJudgeEIn <- dfJudgeEIn[,!names(dfJudgeEIn) %in% c("Rand_Order", "ID", "Expression")]
dfJudgeE = full_join(x=dfGroups, y=dfJudgeEIn, by="ORG_Order")

dfJudgeA$Judge <- "A"
dfJudgeB$Judge <- "B"
dfJudgeC$Judge <- "C"
dfJudgeD$Judge <- "D"
dfJudgeE$Judge <- "E"
dfJudgeAll <- rbind(dfJudgeA, dfJudgeB, dfJudgeC, dfJudgeD, dfJudgeE)
dfJudgeAll <- dfJudgeAll[!is.na(dfJudgeAll$Summary),]
dfJudgeAll <- dfJudgeAll[,!names(dfJudgeAll) %in% c("ORG_Order","ID","Expression","Summary","Expr_Num")]
write.csv(dfJudgeAll, "readability-data-out/judge-all.csv")

rm(dfJudgeAIn)
rm(dfJudgeBIn)
rm(dfJudgeCIn)
rm(dfJudgeDIn)
rm(dfJudgeEIn)
rm(dfJudgeA)
rm(dfJudgeB)
rm(dfJudgeC)
rm(dfJudgeD)
rm(dfJudgeE)

rm(dfJudgeAll)

##############################################################################
# Figure 6: Boxplots of FRE and DC Data by Group
dfStudent_Read <- dfStudent[c("Flesch", "Dale")]
dfStudent_Read$Source <- "Students"
summary(dfStudent_Read)
dfStudent_Read <- rename(dfStudent_Read, c(
  "Flesch Reading Ease (FRE)" = "Flesch",
  "Dale-Chall (DC)" = "Dale"))
dfStudent_Read$Source <- factor(dfStudent_Read$Source)
dfStudent_Read_lg <- melt(dfStudent_Read, id = "Source")

dfReadSumStu <- df[c("Summary.Flesch.Reading.Ease", "Summary.Dale.Chall.Score", "Source")]
dfReadSumStu <- dfReadSumStu[!(df$Source %in% "Student"),]
dfReadSumStu <- rename(dfReadSumStu, c(
  "Flesch Reading Ease (FRE)" = "Summary.Flesch.Reading.Ease",
  "Dale-Chall (DC)" = "Summary.Dale.Chall.Score"))
dfReadSumStu$Source <- factor(dfReadSumStu$Source)
dfReadSumStu_lg <- melt(dfReadSumStu, id = "Source") 

both.dfs <- rbind(dfReadSumStu_lg, dfStudent_Read_lg)
both.dfs$Source <-factor(both.dfs$Source, levels=c("LLM_Org", "LLM_New", "Gold", "Students"))
ggplot(both.dfs, aes(x = variable, y = value, color = Source)) + geom_boxplot()  +
  facet_wrap(~variable, scale="free") + theme_bw() + labs(color = "Groups") +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), axis.text.x=element_blank(), 
        legend.position = "bottom", text = element_text(size = 14), 
        legend.text = element_text(family = "mono",size = 14)) 
#Export 600x300

tapply(dfReadSumStu$`Flesch Reading Ease (FRE)`, dfReadSumStu$Source, summary)
tapply(dfReadSumStu$`Dale-Chall (DC)`, dfReadSumStu$Source, summary)

rm(dfStudent_Read)
rm(dfStudent_Read_lg)
rm(dfReadSumStu)
rm(dfReadSumStu_lg)
rm(both.dfs)


##############################################################################
# Figure 5: Compare new and old prompt.
dfReadFull <- df[c("Full.Flesch.Reading.Ease", "Full.Dale.Chall.Score", "Coherence", "Source")]
dfReadFull <- rename(dfReadFull, c(
  "Flesch (FRE)" = "Full.Flesch.Reading.Ease",
  "Dale-Chall (DC)" = "Full.Dale.Chall.Score"))
dfReadFull$Source <- factor(dfReadFull$Source)
dfReadFull_lg <- melt(dfReadFull, id = "Source") 
dfReadFull_lg <- na.omit(dfReadFull_lg)
ggplot(dfReadFull_lg, aes(x = variable, y = value, color = Source)) + geom_boxplot()  +
  facet_wrap(~variable, scale="free") + theme_bw() + labs(color = "Groups") +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank(), axis.text.x=element_blank(), 
        legend.position = "bottom", text = element_text(size = 14), 
        legend.text = element_text(family = "mono",size = 14)) 
# Export 700 x 300

summary(dfReadFull$Flesch_Full)
summary(dfReadFull$Dale_Full)
summary(dfReadFull$Coherence)

rm(dfReadFull)
rm(dfReadFull_lg)

##############################################################################
# Fun Stats for Figure 6.
# (i) Reorient the data frame.
dfFullOut <- df[c("Full.Flesch.Reading.Ease", "Full.Dale.Chall.Score", "Coherence", "Source", "Expr_Num")]
dfFullOut <- na.omit(dfFullOut)

library(tidyverse)
library(conflicted)
conflicts_prefer(dplyr::select)
dfWilcox <- dfFullOut |>
  pivot_wider(
    names_from = Source,
    values_from = c(Full.Flesch.Reading.Ease, Full.Dale.Chall.Score, Coherence),
    names_glue = "{.value}_{Source}"
  )
rm(dfFullOut)

# (ii) Calculate Wilcoxon signed rank tests
library(dplyr)
library(devtools)
library(ggplot2)
library(ggpubr)
library(magrittr)
library(PairedData)
library(lawstat)

## Check if significant.
flesch_new <- c(dfWilcox$Full.Flesch.Reading.Ease_LLM_New)
flesch_org <- c(dfWilcox$Full.Flesch.Reading.Ease_LLM_Org)
flesch_paired <- flesch_new - flesch_org
# Test for symmetry.  Not Significant - Assume Symmetric.
symmetry.test(flesch_paired, option = c("MGG", "CM", "M"))
wilcox.test(flesch_new, flesch_org, paired = TRUE) #Significant 

dale_new <- c(dfWilcox$Full.Dale.Chall.Score_LLM_New)
dale_org <- c(dfWilcox$Full.Dale.Chall.Score_LLM_Org)
dale_paired <- dale_new - dale_org
# Test for symmetry.  Not Significant - Assume Symmetric.
symmetry.test(dale_paired, option = c("MGG", "CM", "M"))
wilcox.test(dale_new, dale_org, paired = TRUE) #Significant p < 0.001

coherence_new <- c(dfWilcox$Coherence_LLM_New)
coherence_org <- c(dfWilcox$Coherence_LLM_Org)
coherence_paired <- coherence_new - coherence_org
# Test for symmetry.  Not Significant - Assume Symmetric.
symmetry.test(coherence_paired, option = c("MGG", "CM", "M"))
wilcox.test(coherence_new, coherence_org, paired = TRUE) #Significant p < 0.001

rm(flesch_new)
rm(flesch_org)
rm(flesch_paired)
rm(dale_new)
rm(dale_org)
rm(dale_paired)
rm(coherence_new)
rm(coherence_org)
rm(coherence_paired)
rm(dfWilcox)

##############################################################################
# End
rm(df)
rm(dfFormulas)
rm(dfGroups)
rm(dfStudent)

