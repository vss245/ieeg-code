library(tictoc)
library(foreach)
samplelist = list()
tic('read')
nsamples = 271
nperms = 1000
nvals = nperms+1
for (n in 1:nsamples) {
  file1 <- read.csv(paste("C:\\Users\\prakt_bach\\Desktop\\Veronika\\Intracranial_AL - Copy\\data_R\\TF\\avg_freq_bands\\sample_",n,".csv",sep = ''),header=FALSE)
  colnames(file1) = c('subject', 'channel', 'trial', 'condition', 'frequency', 'power')
  file1$frequency = factor(file1$frequency)
  file1$condition = factor(file1$condition)
  levels(file1$condition)[1] <- 'CS-'
  levels(file1$condition)[2] <- 'CS+'
  levels(file1$frequency)[1] <- 'theta'
  levels(file1$frequency)[2] <- 'alpha'
  levels(file1$frequency)[3] <- 'beta'
  levels(file1$frequency)[4] <- 'gamma'
  levels(file1$frequency)[5] <- 'high.gamma'
  samplelist[[n]] = file1
}
toc()
cl <- makeCluster(6, outfile = '')
registerDoParallel(cl)
tic('orig')
orig <- foreach(i=1:nsamples, .combine='cbind') %dopar% {
  library(nlme)
  #Run LME on original data
  tf.model = lme(power ~ condition * frequency * trial,  data=samplelist[[i]],random = ~1|subject/channel,control=lmeControl(opt = 'optim', returnObject=TRUE))
  tvals <- data.frame(conditiont = double(),
                      trialt = double(),
                      conxtrialt = double())
  pvals = data.frame(conditionp = double(),
                     trialp= double(),
                     conxtrialp = double())
  tvals[1,]$conditiont <- summary(tf.model)$tTable[,'t-value'][2]
  tvals[1,]$trialt <- summary(tf.model)$tTable[,'t-value'][3]
  tvals[1,]$conxtrialt <- summary(tf.model)$tTable[,'t-value'][4]
  pvals[1,]$conditionp <- summary(tf.model)$tTable[,'p-value'][2]
  pvals[1,]$trialp <- summary(tf.model)$tTable[,'p-value'][3]
  pvals[1,]$conxtrialp <- summary(tf.model)$tTable[,'p-value'][4]
  c(tvals,pvals)
}
write.csv(orig,file = paste("C:\\Users\\prakt_bach\\Desktop\\Veronika\\Intracranial_AL - Copy\\data_R\\TF\\avg_freq_bands\\orig_pt.csv",sep = ''))
toc()
tic('perm')
perm <- foreach(i=1:nsamples, .combine='rbind') %:%
  foreach(p = 1:nperms, .combine='cbind') %dopar% {
    library(nlme)
    library(gtools)
    tvals <- data.frame(conditiont = double(),
                        trialt = double(),
                        conxtrialt = double())
    pvals = data.frame(conditionp = double(),
                       trialp = double(),
                       conxtrialp = double())
    df.tf_permuted = samplelist[[i]]
    df.tf_permuted$condition <- permute(df.tf_permuted$condition)
    tf.model_perm = lme(power ~ condition * frequency * trial, random = ~1|subject/channel, data=df.tf_permuted,control=lmeControl(opt = 'optim',returnObject=TRUE))
    tvals[1,]$conditiont <- summary(tf.model_perm)$tTable[,'t-value'][2]
    tvals[1,]$trialt <- summary(tf.model_perm)$tTable[,'t-value'][3]
    tvals[1,]$conxtrialt <- summary(tf.model_perm)$tTable[,'t-value'][4]
    pvals[1,]$conditionp <- summary(tf.model_perm)$tTable[,'p-value'][2]
    pvals[1,]$trialp <- summary(tf.model_perm)$tTable[,'p-value'][3]
    pvals[1,]$conxtrialp <- summary(tf.model_perm)$tTable[,'p-value'][4]
    c(tvals,pvals)
  }
write.csv(perm,file = paste("C:\\Users\\prakt_bach\\Desktop\\Veronika\\Intracranial_AL - Copy\\data_R\\TF\\avg_freq_bands\\perm_pt.csv",sep = ''))
toc()
stopCluster(cl)