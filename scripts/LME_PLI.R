#LME model for PLI
library(nlme)
library(ggplot2)
library(plyr)
library(easyGgplot2)
library(grid)
library(gridExtra)
pt_alpha = 0.05
line_wt = 2
colors= c("#0072B2", "#D55E00")
PLI_csv=read.csv("./data/PLI_th_ALHC_xhem.csv")
PLI_csv <- na.exclude(PLI_csv)
PLI_csv$condition = factor(PLI_csv$condition)
PLI_csv$condition <- revalue(PLI_csv$condition, c('0'='CS-','1'='CS+'))
PLI_model1 = lme(PLI ~ condition * trial, data=PLI_csv, random = ~1|subject/channel)
PLI_pred <- PLI_csv
PLI_pred$PLI <- predict(PLI_model1,level=0)
PLI_pred$group = 'Predicted'
PLI_csv$group = 'Original'
all_PLI = rbind(PLI_pred,PLI_csv)

pli_plot1 <- ggplot() + 
  geom_point(data=PLI_csv, aes(x=trial, y=PLI, colour=condition),alpha=.1) +
  geom_line(data=PLI_pred, aes(x=trial,y=PLI,color=condition),size=1) + 
  theme_classic() +
  coord_cartesian(ylim = c(0,0.5)) +
  labs(x = 'Trials', y = 'PLI', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  theme_classic(base_size = 22) + ggtitle('Theta range')

PLI_csv=read.csv("./data/PLI_lg_ALHC_xhem.csv")
PLI_csv <- na.omit(PLI_csv)
PLI_csv$condition = factor(PLI_csv$condition)
PLI_csv$condition <- revalue(PLI_csv$condition, c('0'='CS-','1'='CS+'))
PLI_model2 = lme(PLI ~ condition * trial, data=PLI_csv, random = ~1|subject/channel)
PLI_pred <- PLI_csv
PLI_pred$PLI <- predict(PLI_model2,level=0)
PLI_pred$group = 'Predicted'
PLI_csv$group = 'Original'
all_PLI = rbind(PLI_pred,PLI_csv)

pli_plot2 <- ggplot() + 
  geom_point(data=PLI_csv, aes(x=trial, y=PLI, colour=condition),alpha=.1) +
  geom_line(data=PLI_pred, aes(x=trial,y=PLI,color=condition),size=1) + 
  theme_classic() +
  coord_cartesian(ylim = c(0,0.3)) +
  labs(x = 'Trials', y = 'PLI', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  theme_classic(base_size = 22) + ggtitle('Low gamma range')


PLI_csv=read.csv("./data/PLI_hg_ALHC_xhem.csv")
PLI_csv <- na.omit(PLI_csv)
PLI_csv$condition = factor(PLI_csv$condition)
PLI_csv$condition <- revalue(PLI_csv$condition, c('0'='CS-','1'='CS+'))
PLI_model3 = lme(PLI ~ condition * trial, data=PLI_csv, random = ~1|subject/channel)
PLI_pred <- PLI_csv
PLI_pred$PLI <- predict(PLI_model3,level=0)
PLI_pred$group = 'Predicted'
PLI_csv$group = 'Original'
all_PLI = rbind(PLI_pred,PLI_csv)

pli_plot3 <- ggplot() + 
  geom_point(data=PLI_csv, aes(x=trial, y=PLI, colour=condition),alpha=.1) +
  geom_line(data=PLI_pred, aes(x=trial,y=PLI,color=condition),size=1) + 
  theme_classic() +
  coord_cartesian(ylim = c(0,0.3)) +
  labs(x = 'Trials', y = 'PLI', color = 'Condition') +
  scale_colour_hue(l=50)  +
  scale_color_manual(values=colors) +
  theme_classic(base_size = 22) + ggtitle('High gamma range')

grid.arrange(pli_plot1,pli_plot2,pli_plot3,ncol=3)