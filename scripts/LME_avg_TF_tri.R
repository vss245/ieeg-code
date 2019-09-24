#LME model for avg power
library(nlme)
library(plyr)
library(ggplot2)
library(easyGgplot2)
#amygdala
power_amy=read.csv("./data/avg_power_amy.csv")
power_amy$condition = factor(power_amy$condition)
power_amy$subject = factor(power_amy$subject)
power_amy$condition <- revalue(power_amy$condition, c('0'='CS-','1'='CS+'))
theta_amy = power_amy[power_amy$frequency=='theta',]
gamma_amy = power_amy[power_amy$frequency=='gamma',]
hg_amy = power_amy[power_amy$frequency=='high_gamma',]
power_model = lme(power ~ condition * frequency * trial, data=power_amy, random = ~1|subject/channel)
theta_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=theta_amy)
gamma_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=gamma_amy)
hg_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=hg_amy)

#hippocampus
power_hip=read.csv("./data/avg_power_hip.csv")
power_hip$condition = factor(power_hip$condition)
power_hip$subject = factor(power_hip$subject)
power_hip$condition <- revalue(power_hip$condition, c('0'='CS-','1'='CS+'))
theta_hip = power_hip[power_hip$frequency=='theta',]
ant <- subset(theta_hip, channel <= 3 |channel == 9 | channel ==10)
post <- subset(theta_hip, channel == 57 | channel == 49| channel == 50)
gamma_hip = power_hip[power_hip$frequency=='gamma',]
hg_hip = power_hip[power_hip$frequency=='high_gamma',]
gamma_ant <- subset(gamma_hip, channel <= 3 |channel == 9 | channel ==10)
gamma_post <- subset(gamma_hip, channel == 57 | channel == 49| channel == 50)
hg_ant <- subset(hg_hip, channel <= 3 |channel == 9 | channel ==10)
hg_post <- subset(hg_hip, channel == 57 | channel == 49| channel == 50)
#all bands
power_model_hip = lme(power ~ condition * frequency * trial, random = ~1|subject/channel, data=power_hip)
#theta overall
theta_model_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=theta_hip)
#theta by region
ant_theta_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=ant)
post_theta_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=post)
#gamma overall
gamma_model_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=gamma_hip)
#gamma by region
gamma_ant_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=gamma_ant)
gamma_post_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=gamma_post)
#high gamma overall
hg_model_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=hg_hip)
#high gamma by region
hg_ant_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=hg_ant)
hg_post_model = lme(power ~ condition * trial, random = ~1|subject/channel, data=hg_post)

#delta and theta
sub_th_amy=read.csv("./data/avg_power_amy_theta.csv")
sub_th_amy$condition=factor(sub_th_amy$condition)
sub_th_amy$subject=factor(sub_th_amy$subject)
sub_th_amy$condition=revalue(sub_th_amy$condition, c('0'='CS-','1'='CS+'))
theta48 = sub_th_amy[sub_th_amy$frequency=='theta',]
delta=  sub_th_amy[sub_th_amy$frequency=='delta',]
high_theta_model= lme(power ~ condition * trial, random = ~1|subject/channel, data=theta48)
low_theta_model= lme(power ~ condition * trial, random = ~1|subject/channel, data=delta)

sub_th_hip=read.csv("./data/avg_power_hip_theta.csv")
sub_th_hip$condition=factor(sub_th_hip$condition)
sub_th_hip$subject=factor(sub_th_hip$subject)
sub_th_hip$condition=revalue(sub_th_hip$condition, c('0'='CS-','1'='CS+'))
theta48_hip = sub_th_hip[sub_th_hip$frequency=='theta',]
delta_hip =  sub_th_hip[sub_th_hip$frequency=='delta',]
high_theta_model_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=theta48_hip)
low_theta_model_hip = lme(power ~ condition * trial, random = ~1|subject/channel, data=delta_hip)

