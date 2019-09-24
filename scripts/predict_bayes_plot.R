library(ggplot2)
library(easyGgplot2)
pt_alpha=0.2
line_wt = 1
colors= c("#0072B2", "#D55E00")
pred_power_bayes <- theta_power_bayes
pred_power_bayes$power <- predict(model_exp,level=0)
pred_power_bayes$group = 'Predicted'
theta_power_bayes$group = 'Original'
all_power_bayes = rbind(pred_power_bayes,theta_power_bayes)

amy <- ggplot() + 
  geom_point(data=theta_power_bayes, aes(x=trial, y=power, colour=condition), size=2, alpha=pt_alpha) + 
  geom_line(data=pred_power_bayes, aes(x=trial,y=power,color=condition),size=line_wt) + 
  theme_classic() +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)+ 
  scale_color_manual(values=colors)+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"))


amy2 <- ggplot() + geom_line(data=all_power_bayes, aes(x=trial,y=power,color=condition,alpha=group),size=line_wt) + 
  theme_classic() +
  labs(x = 'Expectation', y = 'Power', color = 'Condition',alpha = 'Values') +
  scale_colour_hue(l=50)  + 
  ggtitle('Amygdala')

print(amy2)