library(tictoc)
library(nlme)
library(doParallel)
samplelist = list()
nsamples = 211
nperms = 1000
nvals = nperms+1
cl <- makeCluster(16, outfile='')
registerDoParallel(cl)
tic('reading files..')
for (n in 1:nsamples) {
  file1 <-read.csv(paste('../mydata/TFold/sample_HC',n+59,'.csv',sep=''),header=FALSE)
  file.df <- as.data.frame(file1)
  colnames(file.df) = c('subject', 'channel', 'trial', 'condition', 'frequency', 'power')
  samplelist[[n]] <- file.df
}
toc()
# for (f in 100:120) {
#   tic()
#   out_orig <- foreach(s=1:length(samplelist), .combine='rbind') %dopar% {
#     library(nlme)
#     #Run LME on original data
#     data1 = samplelist[[s]]
#     data1 = data1[data1$frequency==f,]
#     tf.model = lme(power ~ condition * trial,  data=data1,random = ~1|subject/channel, control=lmeControl(opt = 'optim'))
#     tvals <- data.frame(conditiont = double(),
#                         trialt = double(),
#                         conxtrialt = double())
#     pvals = data.frame(conditionp = double(),
#                        trialp= double(),
#                        conxtrialp = double())
#     tvals[1,]$conditiont <- summary(tf.model)$tTable[,'t-value'][2]
#     tvals[1,]$trialt <- summary(tf.model)$tTable[,'t-value'][3]
#     tvals[1,]$conxtrialt <- summary(tf.model)$tTable[,'t-value'][4]
#     pvals[1,]$conditionp <- summary(tf.model)$tTable[,'p-value'][2]
#     pvals[1,]$trialp <- summary(tf.model)$tTable[,'p-value'][3]
#     pvals[1,]$conxtrialp <- summary(tf.model)$tTable[,'p-value'][4]
#     c(tvals,pvals)
#   }
#   write.csv(out_orig,file = paste('../mydata/TF_HC/output/orig_TF_freq',f,'.csv',sep = ''))
#   toc()
# }
#permutations
for (f in 100:120) {
  print(paste('freq', f))
  out_perm <- foreach(s=1:length(samplelist), .combine='cbind') %:%
    foreach(p=1:nperms, .combine='rbind') %dopar% {
      library(nlme)
      print(paste(s,p))
      tvals <- data.frame(conditiont = double(),
                          trialt = double(),
                          conxtrialt = double())
      pvals = data.frame(conditionp = double(),
                         trialp = double(),
                         conxtrialp = double())
      data2 = samplelist[[s]]
      data2 = data2[data2$frequency==f,]
      df.tf_permuted = data2
      df.tf_permuted$condition <- sample(df.tf_permuted$condition)
      result <- tryCatch({ #try to catch the matrix is singular error
        tf.model_perm = lme(power ~ condition * trial, random = ~1|subject/channel, data=df.tf_permuted, control=lmeControl(opt = 'optim'))
        tvals[1,]$conditiont <- summary(tf.model_perm)$tTable[,'t-value'][2]
        tvals[1,]$trialt <- summary(tf.model_perm)$tTable[,'t-value'][3]
        tvals[1,]$conxtrialt <- summary(tf.model_perm)$tTable[,'t-value'][4]
        pvals[1,]$conditionp <- summary(tf.model_perm)$tTable[,'p-value'][2]
        pvals[1,]$trialp <- summary(tf.model_perm)$tTable[,'p-value'][3]
        pvals[1,]$conxtrialp <- summary(tf.model_perm)$tTable[,'p-value'][4]
        c(tvals,pvals)
      },
      error = function(err) {
        print('error, permuting data again')
        data2 = samplelist[[s]]
        data2 = data2[data2$frequency==f,]
        df.tf_permuted = data2
        df.tf_permuted$condition <- sample(df.tf_permuted$condition)
        tf.model_perm = lme(power ~ condition * trial, random = ~1|subject/channel, data=df.tf_permuted, control=lmeControl(opt = 'optim'))
        tvals[1,]$conditiont <- summary(tf.model_perm)$tTable[,'t-value'][2]
        tvals[1,]$trialt <- summary(tf.model_perm)$tTable[,'t-value'][3]
        tvals[1,]$conxtrialt <- summary(tf.model_perm)$tTable[,'t-value'][4]
        pvals[1,]$conditionp <- summary(tf.model_perm)$tTable[,'p-value'][2]
        pvals[1,]$trialp <- summary(tf.model_perm)$tTable[,'p-value'][3]
        pvals[1,]$conxtrialp <- summary(tf.model_perm)$tTable[,'p-value'][4]
        c(tvals,pvals)
      }) #ending trycatch block
      return(result)
    }
  write.csv(out_perm,file = paste('../mydata/TFold/outputHC/perm_TF_freq',f,'.csv',sep = ''))
}
stopCluster(cl)