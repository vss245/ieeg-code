%Veronika Shamova
%Go through every folder on the path, in
%folder 'try' get *.ncs files and import into SPM
data_path = 'C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data';
cd(data_path);
load('data_el.mat')
create_montage_matrix;
%Run code on every resulting spm_ft_data file
for subj = 1:length(data)
    nlx2spm(data(subj).id, data(subj).folder)
    disp(['pre-processing data for subject ', data(subj).id])
    spm_preprocess(data(subj).id, data(subj).folder)
    detect_artefacts(data(subj).id, data(subj).folder)
end


