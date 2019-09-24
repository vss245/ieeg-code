function spm_preprocess(id, folder)
%Function for preprocessing raw EEG data
spm('defaults','eeg');
p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\',folder,'\preprocessed data\'];
cd(p.path);
%~~~~~~~~~~~~~~~~~~~Filter~~~~~~~~~~~~~~~~~~~~~~~~
%Lowpass filter at 120 Hz
D = spm_eeg_load([p.path,'spm_ft_data_', id,'.mat']);
D = chantype(D,1:nchannels(D),'EEG');
save(D);
lp_data = struct('D', D, 'band','low','freq',240,'dir','twopass','order',4,'prefix','240f');
spm_eeg_filter(lp_data);
% Stopband filter between 48-52 Hz
% try without filter due to harmonics
% sb_data = struct('D', [p.path,'fspm_ft_data_S_', data(i).id,'.mat'], 'band','stop','freq',[48 52],'dir','twopass','order',4,'prefix','f');
%spm_eeg_filter(sb_data);
%~~~~~~~~~~~~~~~~~~~Downsample~~~~~~~~~~~~~~~~~~~~~
ds_data = struct('D',[p.path,'240fspm_ft_data_', id,'.mat'],'fsample_new',480,'prefix','d'); %edit for filter
spm_eeg_downsample(ds_data);
define_trials(id,folder); %Create trial definition function and check if triggers are correct
%~~~~~~~~~~~~~~~~~~~Epoch~~~~~~~~~~~~~~~~~~~~~~~~
%Epoch the data
trlfile = load([p.path,'trlfile.mat']);
ep_data = struct('D',[p.path,'d240fspm_ft_data_', id,'.mat']); %edit for no notch filter
ep_data.trl = trlfile.trl;
ep_data.conditionlabels = trlfile.conditionlabels;
spm_eeg_epochs(ep_data);
%~~~~~~~~~~~~~~~~~~~Montage~~~~~~~~~~~~~~~~~~~~~~~~
%Apply white matter montage
wmm_data = struct('D',[p.path,'\ed240fspm_ft_data_', id,'.mat'],'mode','write','montage', [p.path, 'montageWM.mat'],'keepothers',0,'blocksize',655360,'prefix','new_wm_');
spm_eeg_montage(wmm_data);
delete(['240fspm_ft_data_' id '.*at'])
delete(['ed240fspm_ft_data_' id '.*at'])
delete(['d240fspm_ft_data_' id '.*at'])
end