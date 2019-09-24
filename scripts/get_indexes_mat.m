%create indexes file
data_path = 'C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data';
cd(data_path);
load('data_el.mat');
for subj = 1:length(data)
    %Go to folder for subject
    p.path = ['C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\', data(subj).folder];
    b.path = [p.path, '\Behavior'];
    cd(b.path)
    %Read files
    dir_folders = dir(b.path);
    evdata = [];
    cs = [];
    us = [];
    %Pull Block info from folders
    for fol = 3:length(dir_folders)
        cd(b.path);
        cd(dir_folders(fol).name);
        block1 = dir('*_Block1.mat');
        if isempty(block1)
            block1 = dir('*_Block1*.mat');
        end
        block1 = load(block1.name);
        block2 = dir('*_Block2.mat');
        if isempty(block2)
            block2 = dir('*_Block2*.mat');
        end
        resp1 = length(block1.resp);
        block1.indata = block1.indata(1:resp1,:);
        %Add data to arrays
        if size(block2,1) ~= 0
            block2 = load(block2.name);
            resp2 = length(block2.resp);
            block1.indata = block1.indata(1:resp1,:);
            block2.indata = block2.indata(1:resp2,:);
            evdata = vertcat(evdata,block1.indata,block2.indata);
            cs = vertcat(cs, block1.indata(:,2),block2.indata(:,2));
            us = vertcat(us, block1.indata(:,3),block2.indata(:,3));
        else
            evdata = vertcat(evdata,block1.indata);
            cs = vertcat(cs,block1.indata(:,2));
            us = vertcat(us,block1.indata(:,3));
        end
        indexes = struct('cs',cs,'us',us,'evdata',evdata);
    end
cd(p.path);
%Save everything
indexes = struct('evdata',evdata,'cs',cs,'us',us);
save('indexes.mat','indexes')
end
