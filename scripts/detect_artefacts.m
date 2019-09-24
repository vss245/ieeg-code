function detect_artefacts(s_id, folder_name)
p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\',folder_name,'\preprocessed data\'];
cd(p.path);
data = spm_eeg_load([p.path, 'wm_edfspm_ft_data_',s_id]);
spm_eeg_ft_artefact_visual(data);
end
