%Function that creates a montage matrix file
function create_montage_matrix()
for i = 1:5
    spath = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\',data(i).folder,'\preprocessed data'];
    cd(spath)
    file = spm_eeg_load(['spm_ft_data_',data(i).id,'.mat']);
    len = nchannels(file);
    labels = chanlabels(file);
    %make array with new channel names
    names = cell(len-1,1);
    for i = 1:(len-1)
        newname = strjoin([labels(i), '-', labels(i+1)]);
        names{i} = char(newname);
    end
    %remove the channels w crossed stripes
    cross_str_ind = [];
    for i = 1:length(names)/8
        cross_str_ind(end+1) = 8*i;
    end
    names(cross_str_ind,:) = [];
    %make transformation matrix
    tra = (eye(len,len)+(-1*circshift(eye(len,len),-1)));
    tra(cross_str_ind,:) = [];
    %create montage matrix
    montage.tra = tra(1:end-1,:);
    montage.labelnew = names;
    montage.labelorg = labels;
    montage.name = 'bipolar';
    save('montage', 'montage');
    %create new names
    names = cell(len,1);
    for k = 1:len
        names(k) = strcat(labels(k), ' - WM');
    end
    %load WM references
    wm = data(i).chanWM;
    %sort by number
    wm = sort(wm);
    %montage matrix - columns of reference channels replaced with -1/number of
    %WM references, the reference channel is replaced by 1+that
    %separate into channels, reference to white matter
    chans = 1:len;
    %get number of references
    numref = length(wm);
    %get number of contacts per channel
    tra = eye(len);
    for j = 1:numref
        channum = length(data(i).chind{j});
        for m = 1:channum
            tra(data(i).chind{j}(m),wm(j))=-1/8;
            tra(wm(j),wm(j))=7/8;
        end
    end
    montage.labelnew = names;
    montage.labelorg = labels;
    montage.name = 'white_matter';
    montage.tra = tra;
    save('montageWM.mat', 'montage')
end