%get averaged power for frequency bands
%defined from Khemka et al 2017
cd('C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data')
%load index of electrodes
load('data_el.mat')
%frequencies = {1:8,8:12,12:30,30:80,80:120};
frequencies = {1:4,4:8};
%fnames = {'theta','alpha','beta','gamma','high_gamma'};
fnames = {'delta','theta'};
nfreq = length(fnames); %frequency bands
cell_subj = cell(1,5);
table_headings = {'subject','channel','trial','condition','delta','theta'};
region_names = {'amy', 'hip'};
chan_names = {'chanALwm', 'chanHwm'};
reg = input('1 for amygdala, 2 for hippocampus: ');
for i=1:5
    p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\' data(i).folder '\preprocessed data\'];
    cd(p.path);
    spm_data = spm_eeg_load(['rtf_wm_edfspm_ft_data_' data(i).id '.mat']);
    disp(data(i).id);
    %get sizes
    nchans = length(data(i).(chan_names{reg}));
    nsample = size(spm_data,3);
    ntri = size(spm_data,4);
    %load bad trials
    bad_trials = data(i).badtrialsWM;
    cp = find(strcmp(spm_data.conditions,'CS+'));
    conditions = zeros(1,ntri);
    conditions(cp) = 1;
    allch = [];
    allcond = [];
    alltri = [];
    allchn = [];
    for k=1:nchans
        tic
        %get index of channel
        ch_ind = find(data(i).(chan_names{reg})(k) == [data(i).badtrialsWM.channel]);
        %get bad trials
        exclude = [bad_trials(ch_ind).trial];
        %get good trials
        good = 1:ntri;
        good(exclude) = [];
        ngood = length(good);
        condchan = conditions';
        condchan(exclude) = [];
        ch_num = data(i).(chan_names{reg})(k);
        disp(['Channel ' num2str(ch_num)])
        channel = zeros(ngood,nfreq);
        for f = 1:length(frequencies)
            channel(:,f) = squeeze(mean(mean(spm_data(ch_num,frequencies{f},60:271,good))));
        end
        %Adjust ch name
        ch_num = repelem(ch_num,length(good));
        allch = vertcat(allch,channel);
        allcond = vertcat(allcond, condchan);
        alltri = vertcat(alltri, good');
        allchn = vertcat(allchn, ch_num');
        toc
    end
    subid = repelem(i,length(allch));
    subject = horzcat(subid', allchn, alltri, allcond, allch);
    subtab = array2table(subject,'VariableNames',table_headings);
    %theta
    subtab = stack(subtab,5:6,'NewDataVariableName','power','IndexVariableName','frequency');
    %subtab = stack(subtab,5:9,'NewDataVariableName','power','IndexVariableName','frequency');
    cell_subj{1,i} = subtab;
end
all_subjects = vertcat(cell_subj{1,:});
cd('C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data')
%writetable(all_subjects,['avg_power_',region_names{reg},'.csv']);
writetable(all_subjects,['avg_power_',region_names{reg},'_theta.csv']);