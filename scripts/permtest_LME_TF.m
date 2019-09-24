%Run permtest on values from LME in R (for TF)
regions = {'Amygdala', 'Hippocampus'};
reg = input('1 for amygdala, 2 for hippocampus: ');
if reg == 1
    %data_path = 'D:\veronika-data\TF_cluster\';
    data_path = '/Users/nika/Desktop/lab/cluster_data/amygdala';
elseif reg == 2
    %data_path = 'D:\veronika-data\TF_cluster_HC\output\';
    data_path = '/Users/nika/Desktop/lab/cluster_data/hippocampus';
end
cd(data_path);
nsamples=211;
fieldnames = {'condition','trial','conxtrial'};
pclust = struct();
nfreq = input('enter number of frequencies: ');
tcond = zeros(nsamples,nfreq,1001);
ttrial = zeros(nsamples,nfreq,1001);
tconxtri = zeros(nsamples,nfreq,1001);
pcond = zeros(nsamples,nfreq,1001);
ptrial = zeros(nsamples,nfreq,1001);
pconxtri = zeros(nsamples,nfreq,1001);
for freq = 1:nfreq
    fname = ['orig_TF_freq' num2str(freq) '.csv'];
    orig_vals = importdata(fname);
    orig_vals = orig_vals.data;
    tcond(:,freq,1) = orig_vals(:,1);
    ttrial(:,freq,1) = orig_vals(:,2);
    tconxtri(:,freq,1)=orig_vals(:,3);
    pcond(:,freq,1) = orig_vals(:,4);
    ptrial(:,freq,1) = orig_vals(:,5);
    pconxtri(:,freq,1)=orig_vals(:,6);
    %for perm = 2:1001
    %end
    fname1 = ['perm_TF_freq' num2str(freq) '.csv'];
    perm_vals = importdata(fname1);
    perm_vals = perm_vals.data;
    ctr = 0;
    for s = 1:nsamples
        tcond(s,freq,2:1001) = perm_vals(:,1+6*ctr);
        ttrial(s,freq,2:1001) =  perm_vals(:,2+6*ctr);
        tconxtri(s,freq,2:1001) = perm_vals(:,3+6*ctr);
        pcond(s,freq,2:1001) = perm_vals(:,4+6*ctr);
        ptrial(s,freq,2:1001) =  perm_vals(:,5+6*ctr);
        pconxtri(s,freq,2:1001) = perm_vals(:,6+6*ctr);
        ctr = ctr+1;
    end
end
pclust.condition = permtest2(tcond(:,:,1),pcond(:,:,1),tcond(:,:,2:1001),pcond(:,:,2:1001));
pclust.trial = permtest2(ttrial(:,:,1),ptrial(:,:,1),ttrial(:,:,2:1001),ptrial(:,:,2:1001));
pclust.conxtri = permtest2(tconxtri(:,:,1),pconxtri(:,:,1),tconxtri(:,:,2:1001),pconxtri(:,:,2:1001));
%%
cd('/Users/nika/Desktop/lab/Veronika_iEEG_project/data')
if reg == 1
    load('average_TF_amy.mat')
elseif reg == 2
    load('average_TF_hc.mat')
end
figure
contrastTF = avg_csp-avg_csm;
contrastTFfreqs = contrastTF(:,1:nfreq);
p1 = imagesc(contrastTFfreqs');
colormap parula
alpha = 0.05;
cb = colorbar;
set(gca,'Ydir','normal')
ylabel(cb, 'Power difference')
ylabel('Frequency, Hz')
names = {'amygdala', 'hippocampus'};
title(['Averaged CS+ power - CS- power in the ' names{reg}])
hold on
[~, c1] = contour(pclust.condition(:,:)' > 0 & pclust.condition(:,:)' < alpha, [0 0.5], 'k');
[~, c2] = contour(pclust.trial(:,:)' > 0 & pclust.trial(:,:)' < alpha, [0 0.5],'m');
[~, c3] = contour(pclust.conxtri(:,:)' > 0 & pclust.conxtri(:,:)' < alpha, [0 0.5],'b');
xlabel('Time, s (CS onset to US onset)')
c1.LineWidth = 3;
c2.LineWidth = 3;
c3.LineWidth = 3;
lg = legend({'Condition','Trial','Condition*trial'}, 'Location', 'northeastoutside');
lg.FontSize = 13;
set(gca,'FontSize',13);
    xticklabels = (0:0.5:3.5);
    xticks = linspace(1,nsamples,length(xticklabels));
    set(gca,'YDir','normal','XTick',xticks,'XTickLabel',xticklabels);