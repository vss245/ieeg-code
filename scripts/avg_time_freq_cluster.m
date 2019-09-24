cd('/Users/nika/Desktop/lab/Veronika_iEEG_project/data')
if reg == 1
    load('average_TF_amy.mat')
elseif reg == 2
    load('average_TF_hc.mat')
end
figure
subplot(1,2,1)
contrastTF = avg_csp-avg_csm;
contrastTFfreqs = contrastTF(:,1:nfreq);
avgfreqs = mean(contrastTFfreqs,1);
imagesc(avgfreqs');
title('Average over frequency')
set(gca,'Ydir', 'normal', 'xtick', [])
ylabel('Frequency, Hz')
colorbar
subplot(1,2,2)
p1 = imagesc(contrastTFfreqs');
avgtime = mean(contrastTFfreqs,2);
imagesc(avgtime');
title('Average over time')
set(gca,'Ydir', 'normal', 'Ytick', [])
set(gca, 'Xtick', linspace(0,212,5), 'Xticklabels', linspace(0, 3.5,5))
xlabel('Time, s')
colorbar