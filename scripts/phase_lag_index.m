%code adapted from https://github.com/spm/DAiSS/blob/master/bf_output_PLI.m
data_path = 'C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data';
cd(data_path);
%load index of electrodes
load('data_el.mat')
cell_subj = cell(1,5);
all_sub_clust = cell(1,5);
for subj = 1:length(data)
    cd(['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\', data(subj).folder,'\preprocessed data']);
    spm_data = spm_eeg_load(['wm_edfspm_ft_data_',data(subj).id,'.mat']);
    D = spm_data(:,:,:);
    disp(data(subj).id)
    %get all channel combinations - ipsilateral
    rcomb1 = allcomb(data(subj).r_amy, data(subj).r_hc_post);
    rcomb2 = allcomb(data(subj).r_amy,  data(subj).r_hc_ant);
    lcomb1 = allcomb(data(subj).l_amy, data(subj).l_hc_post);
    lcomb2 = allcomb(data(subj).l_amy, data(subj).l_hc_ant);
    comb_ch = [rcomb1; rcomb2; lcomb1; lcomb2];
    %comb_ch = [rcomb2; lcomb2];
    %all hemispheres
    comb_ch = allcomb(data(subj).chanALwm,data(subj).chanHwm);
    %load bad trials
    bad_trials = data(subj).badtrialsWM;
    condlist = spm_data.conditions;
    PLI = zeros(size(D,3), length(comb_ch));
    sub_clust = zeros(1,length(comb_ch));
    if ~isempty(comb_ch)
        for comb = 1:length(comb_ch)
            D_chan = D;
            %exclude bad trials
            %get index of channel
            ch_ind1 = find([data(subj).badtrialsWM.channel] == comb_ch(comb));
            %get bad trials
            exclude1 = [bad_trials(ch_ind1).trial];
            %get index of channel
            ch_ind2 = find([data(subj).badtrialsWM.channel] == comb_ch(comb,2));
            %get bad trials
            exclude2 = [bad_trials(ch_ind2).trial];
            exclude = union(exclude1,exclude2);
            D_chan(:,:,exclude) = NaN;
            for tri = 1:size(D_chan,3)
                % set up filter (4th order bandpass Butterworth)
                [b, a] = butter(2, [80, 120]./(spm_data.fsample/2)); %cutoff: 1 to 8 Hz
                Dnew = filtfilt(b, a, D_chan(comb_ch(comb),:,tri)); %amygdala channels
                complex_ref(1, :) = hilbert(Dnew);
                %second source
                Dtemp = filtfilt(b, a, D_chan(comb_ch(comb,2),:,tri)); %hippocampus channels
                complex_temp = hilbert(Dtemp);
                PLI(tri,comb) = abs(mean(sign(angle(complex_temp./complex_ref(1, :)))));
                PLI(tri,length(comb_ch)+1)=subj;
                PLI(tri, length(comb_ch)+2) = tri;
                if strcmp(condlist{tri},'CS+')
                    PLI(tri, length(comb_ch)+3) = 1;
                else
                    PLI(tri,length(comb_ch)+3) = 0;
                end
            end
%             %run t-test on PLI data
%             %get indices of conditions
%             cond_chan = condlist;
%             ind_pl = strcmp(cond_chan,'CS+');
%             ind_min = strcmp(cond_chan,'CS-');
%             %         ind_pl(exclude) = [];
%             %         ind_min(exclude) = [];
%             [tvals,pvals,~,stats] = ttest2(PLI(ind_pl,comb),PLI(ind_min,comb),'Vartype','unequal');
%             %run permutations test
%             ns = spm_data.nsamples;
%             nch = length(comb_ch);
%             %make an empty array to hold all t and p values
%             all_tvals = zeros(1,1001);
%             all_pvals = zeros(1,1001);
%             all_tvals(:,1) = tvals; %true label t-value is the first element
%             tvals = permute(tvals,[2 1]);
%             pvals = permute(pvals,[2 1]);
%             disp('starting permutation test')
%             for perm = 2:1001
%                 %fprintf('running permutation %s \n', num2str(m));
%                 %get random label order
%                 ind_perm = randperm(size(cond_chan,2));
%                 cond_perm = cond_chan(ind_perm);
%                 %get new indices
%                 ind_pl_p = strcmp(cond_perm,'CS+');
%                 ind_min_p = strcmp(cond_perm,'CS-');
%                 [tvals_p,pvals_p,stats_p] = ttest2(PLI(ind_pl_p,comb),PLI(ind_min_p,comb),'Vartype','unequal');
%                 all_tvals(:,perm) = tvals_p;
%                 all_pvals(:,perm) = pvals_p;
%             end
%             disp('finished permutation test')
%             disp('implementing cluster-level correction')
%             %run cluster correction (on original t and p values and permutation results)
%             pcluster = permtest(tvals,pvals,all_tvals(2:1001),all_pvals(2:1001));
%             sub_clust(1,comb) = pcluster;
%             all_sub_clust{1,subj} = sub_clust;
        end
        %Create table headings
        names = cell(1,length(comb_ch));
        for c = 1:length(comb_ch)
            names{1,c} = ['ch_' num2str(comb_ch(c)) '_' num2str(comb_ch(c,2))];
        end
        headers = {names{:} 'subject' 'trial' 'condition'};
        %Make table
        subtab = array2table(PLI,'VariableNames',headers);
        subtab = stack(subtab,1:length(comb_ch),'NewDataVariableName','PLI','IndexVariableName','channel');
        cell_subj{1,subj} = subtab;
    end
end
all_PLI = vertcat(cell_subj{1,:});
cd('C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data')
writetable(all_PLI,'PLI_hg_ALHC_xhem.csv');
