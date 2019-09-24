%Exporting TF data for every sample
data_path = 'C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data';
cd(data_path)
load('data_el.mat');
freqlist = {1:8,8:12,12:30,30:80,80:100};
fnames = {'theta','alpha','beta','gamma','high_gamma'};
all_samples_cell = cell(1,271);
variable_names = {'subject','channel','trial','condition','freq_band','power'};
%Preload channels
subj_spm = cell(2,5);
disp('Loading SPM data...')
for i = 1:5
    tic
    nchans = length(data(i).chanALwm);
    sub_chan = cell(1, nchans);
    spath = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\' data(i).folder '\preprocessed data'];
    cd(spath);
    spm_data = spm_eeg_load(['rtf_wm_edfspm_ft_data_',data(i).id,'.mat']);
    subj_spm{1,i} = spm_data;
    for n = 1:nchans
        ch_id = data(i).chanALwm(n);
        sub_chan{1,n} = squeeze(spm_data(ch_id,:,:,:));
        subj_spm{2,i} = sub_chan;
    end
    toc
end
disp('Extracting TF data for every sample...')
for s = 1:271
    disp(['Sample ' num2str(s)])
    tic
    sub_data_cell = cell(1,5);
    for i = 1:5
        spm_data = subj_spm{1,i};
        nsample = size(spm_data,3);
        nfreq = 5;
        ntri = size(spm_data,4);
        condlist = spm_data.conditions;
        bad_trials = data(i).badtrialsWM;
        nchans = length(data(i).chanALwm);
        tri_data_cell = cell(1,ntri);
        ch_data_cell = cell(1,nchans);
        for ch = 1:nchans
            ch_id = data(i).chanALwm(ch);
            ch_ind = find(data(i).chanALwm(ch) == [data(i).badtrialsWM.channel]);
            exclude = [bad_trials(ch_ind).trial];
            good = 1:ntri;
            good(exclude) = [];
            chan_data = subj_spm{2,i}{1,ch};
            freq = zeros(1,nfreq);
            power = zeros(1,nfreq);
            subj = repmat(i, 1, nfreq);
            chan = repmat(ch, 1, nfreq);
            for t = 1:length(good);
                tri = repmat(good(t),1,nfreq);
                if strcmp((condlist(good(t))),'CS+')
                    cond = ones(1,nfreq);
                else
                    cond = zeros(1,nfreq);
                end
                for f = 1:nfreq
                    freq(f) = f;
                    power(f) = squeeze(mean(chan_data(freqlist{f},s,good(t))));
                end
                one_tri = transpose(vertcat(subj,chan,tri,cond,freq,power));
                tri_data_cell{1,t} = one_tri;
            end
            all_tri_data = vertcat(tri_data_cell{:});
            ch_data_cell{1,ch} = all_tri_data;
        end
        sub_data = vertcat(ch_data_cell{:});
        sub_data_cell{1,i} = sub_data;
    end
    sample_data = vertcat(sub_data_cell{:});
    all_samples_cell{1,s} = sample_data;
    toc
end
disp('Done processing subjects')
toc
clearvars -except all_samples_cell variable_names data fpath
cd('C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\data_R\TF\avg_freq_bands');
disp('Writing table...')
for i = 1:271
    fid = fopen(['sample_' num2str(i) '.csv'],'w+');
    sample_data = all_samples_cell{1,i}';
    fprintf(fid, '%d, %d, %d, %d, %d, %f\n',sample_data);
    fclose(fid);
end