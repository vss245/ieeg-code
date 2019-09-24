%Neuralynx data to Fieldtriptoolbox - continuous data
function nlx2spm(s_id, folder_name)
p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\', folder_name];
cd(p.path)
ft_defaults;
cfg = [];
cfg.dataset = 'try';
data = ft_preprocessing(cfg);
n.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\', folder_name, '\preprocessed data\'];
save([n.path,'\ft_data_', char(s_id),'.mat'], 'data' , '-v7.3')

%convert fieldtrip data to SPM
%based on https://github.com/neurodebian/spm12/blob/master/man/example_scripts/spm_eeg_convert_arbitrary_data.m
disp('converting data to SPM')
spm('defaults','EEG');
load([n.path, 'ft_data_',char(s_id),'.mat'], 'data');
fname = strcat(n.path,'spm_ft_data_', char(s_id));
spm_eeg_ft2spm(data, fname);
end