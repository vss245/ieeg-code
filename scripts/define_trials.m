function define_trials(sid,sfolder)
%Function for making a trial definition file
cd('C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data');
load('data_el.mat')
disp(['making trial definition file for subject ', sid])
p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\',sfolder];
cd(p.path)
event = ft_read_event('try');
D = spm_eeg_load([p.path,'\preprocessed data\d240fspm_ft_data_',sid,'.mat']);
%Define trials
%Clean up empty neuralynx triggers (value = 0) and US triggers (value =
%8)
event = event([event.value] > 8);
event = event([event.value] <= 128);
prestim = -1;
poststim = 6;
%------------------------------------------------------
%try using indexes file
load([p.path,'\indexes.mat'])
%------------------------------------------------------
% compare indexes.cs (this is from cogent files) with event.value(this is
% from neuralynx)
%convert to neuralynx codes
for i = 1:length(indexes.cs)
    if indexes.cs(i) == 1
        indexes.cs(i) = 128;
    else
        indexes.cs(i) = 64;
    end
end
tri = 1; %index to iterate over trials
badctr = 0; %count bad trials
while (tri ~= length(event)-badctr)
    if indexes.cs(tri) ~= event(tri).value
        event(tri) = [];
        badctr = badctr+1;
    else
        tri = tri+1;
    end
end
disp(['removed ', num2str(badctr), ' bad NLX trials']);

%compare inter-trial intervals for first 3 and last 3 trials
iti_nlx = diff([event.sample])/4000;
thr = 11/2;
if any(iti_nlx<thr)
    disp('lost trials')
end

%make trial definition file from neuralynx events
trl = [];
conditionlabels = cell(length(event),1);
for j = 1:length(event)
    trl = [trl; (event(j).sample*fsample(D)/4000)+(prestim*fsample(D)),(event(j).sample*fsample(D)/4000)+(poststim*fsample(D))];
    if event(j).value == 64
        conditionlabels(j) = {'CS-'};
    else
        conditionlabels(j) = {'CS+'};
    end
end
save([p.path,'\preprocessed data\trlfile.mat'],'trl', 'conditionlabels');
end