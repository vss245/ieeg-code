cd('/Users/nika/Desktop/lab/Veronika_iEEG_project/data/')
reg = input('1 for amy, 2 for hc: ');
fnames = {'average_TF_amy.mat','average_TF_hc.mat'};
names = {'Amygdala','Hippocampus'};
load(fnames{reg})
figure
subplot(1,2,1)
imagesc(avg_csp')
set(gca,'Ydir','normal')
xticklabels = (0:0.5:3.5);
caxis([-4 2])
ylim([0 120])
xticks = linspace(1,212,length(xticklabels));
set(gca,'YDir','normal','XTick',xticks,'XTickLabel',xticklabels,'FontSize',13);
xlabel('Time, s');
ylabel('Frequency, Hz')
title('Average of CS+ trials')
subplot(1,2,2)
imagesc(avg_csm')
set(gca,'Ydir','normal')
xticklabels = (0:0.5:3.5);
ylim([0 120])
xticks = linspace(1,212,length(xticklabels));
set(gca,'YDir','normal','XTick',xticks,'XTickLabel',xticklabels,'FontSize',13);
xlabel('Time, s');
caxis([-4 2])
ylabel('Frequency, Hz')
title('Average of CS- trials')
suptitle(names{reg});
colorbar