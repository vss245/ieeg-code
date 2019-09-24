library(ggplot2)
library(easyGgplot2)
pt_alpha=0.2
colors= c("#0072B2", "#D55E00")
lims=c('CS+','CS-')
linesize=2

amy_th <- ggplot(data=theta_amy) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(theta_model,level=0),color=condition),size=linesize) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE)+
  #theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('Amygdala')+
  theme_classic(base_size=22)

hip_th <- ggplot(data=theta_hip) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(theta_model_hip,level=0),color=condition),size=linesize) + 
  geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('Hippocampus')+
  theme_classic(base_size=22)

ggplot2.multiplot(amy_th,hip_th)

ant_hip <- ggplot(data=ant) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(ant_theta_hip,level=0),color=condition),size=linesize) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('Anterior hippocampus')+
  theme_classic(base_size=22)


post_hip <- ggplot(data=post) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(post_theta_hip,level=0),color=condition),size=linesize) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('Posterior hippocampus')+
  theme_classic(base_size=22)

ggplot2.multiplot(ant_hip,post_hip)

# gamma by region
gam_ant_hip <- ggplot(data=ant) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(gamma_ant_model,level=0),color=condition),size=linesize) + 
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=c('#66CC99',"#CC6666")) +
  ggtitle('Anterior hippocampus')+
  theme_classic(base_size=22)


gam_post_hip <- ggplot(data=post) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(gamma_post_model,level=0),color=condition),size=linesize) + 
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=c('#66CC99',"#CC6666")) +
  ggtitle('Posterior hippocampus')+
  theme_classic(base_size=22)


ggplot2.multiplot(gam_ant_hip,gam_post_hip)


#initial learning
# pred_amy_init <- gamma_amy_init
# pred_amy_init$power <- predict(m_init2,level=0)
# pred_amy_init$group = 'Predicted'
# gamma_amy_init$group = 'Original'
# all_amy_init = rbind(pred_amy_init,gamma_amy_init)
# 
# amy_init <- ggplot() +
#   geom_line(data=all_amy_init, aes(x=trial,y=power,color=condition,alpha=group)) + 
#   theme_classic() +
#   labs(x = 'Trials', y = 'Power', color = 'Condition') +
#   scale_colour_hue(l=50)  + 
#   ggtitle('Original and predicted gamma values in the amygdala')

#gamma amygdala

amy_gam <- ggplot(data=gamma_amy) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(gamma_model,level=0),color=condition),size=2) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-2.5,2.5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('Amygdala')+
  theme_classic(base_size=22)


#gamma hippocampus

hip_gam <- ggplot(data=gamma_hip) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(gamma_model_hip,level=0),color=condition),size=2) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-2.5,2.5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('Hippocampus')+
  theme_classic(base_size=22)


ggplot2.multiplot(amy_gam,hip_gam)

# pred_all <- all_gamma_reg
# pred_all$power <- predict(all_model,level=0)
# all_gamma_reg$group = 'Original'
# pred_all$group <- 'Predicted'
# all_gamma = rbind(all_gamma_reg,pred_all)
# 
# all_plot <- ggplot() +
#   geom_line(data=pred_all, aes(x=trial,y=power,color=condition,linetype=region)) + 
#   coord_cartesian(ylim = c(-1,1)) + 
#   theme_classic() +
#   labs(x = 'Trials', y = 'Power', color = 'Condition',linetype = 'Region') +
#   scale_colour_hue(l=50)  + 
#   ggtitle('gamma')
# 
# print(all_plot)

p1 <- ggplot(data=delta) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(low_theta_model,level=0),color=condition),size=1) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('1-4 Hz power in the amygdala')+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"))


p2 <- ggplot(data=theta48) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(high_theta_model,level=0),color=condition),size=1) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('4-8 Hz power in the amygdala')+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"))


p3 <- ggplot(data=delta_hip) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(low_theta_model_hip,level=0),color=condition),size=1) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('1-4 Hz power in the hippocampus')+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"))


p4 <- ggplot(data=theta48_hip) + 
  geom_point(aes(x=trial, y=power, colour=condition),alpha=.25) +
  geom_line(aes(x=trial,y=predict(high_theta_model_hip,level=0),color=condition),size=1) + 
  #geom_smooth(aes(x=trial,y=power,color=condition),method='lm',se = TRUE) +
  theme_classic() +
  coord_cartesian(ylim = c(-5,5)) +
  labs(x = 'Trials', y = 'Power', color = 'Condition') +
  scale_colour_hue(l=50)  + 
  scale_color_manual(values=colors) +
  #scale_alpha_manual(values=c(0.5, 1),guide=F) +
  ggtitle('4-8 Hz power in the hippocampus')+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=18,face="bold"))


ggplot2.multiplot(p1,p2,p3,p4)
