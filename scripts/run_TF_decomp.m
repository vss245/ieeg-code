%% Function that returns the time-frequency decomposition of all channels for all subjects with x = [CS onset; US onset];
function run_TF_decomp()
data_path = 'C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data';
cd(data_path);
load('data_el.mat')
for subj = 1:5
    %% Run time frequency
    p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\',...,
        data(subj).folder,'\preprocessed data\'];
    cd(p.path);
    f1 = 1;
    f2 = 120;
    %perform time frequency analysis
    tf_setup = struct('D',[p.path, 'new_wm_ed240fspm_ft_data_' data(subj).id '.mat'],'channels','all','frequencies',[f1:f2],...,
        'timewin',[0 7000],'method','morlet');
    %tf_setup.settings.subsample = 4; %subsample at every 4th
    spm_eeg_tf(tf_setup);
    %add rescale
    rs_setup = struct('D', [p.path, 'tf_new_wm_ed240fspm_ft_data_', data(subj).id '.mat'], 'timewin', [0 1000],...,
        'method', 'LogR','prefix','r');
    spm_eeg_tf_rescale(rs_setup);
    %delete([p.path, 'tf_wm_edfspm_ft_data_' data(i).id '.mat'])
    %rs_data = spm_eeg_load([p.path, 'rtf_wm_edfspm_ft_data_' data(i).id '.mat']);
end
end
