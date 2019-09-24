%get start and end of significant clusters
function vals = plot_sigclus(clusters,alpha)
%change all values equal to -1 or over alpha to 0
clusters(clusters==-1 | clusters>alpha)=0;
%change all values lower than alpha to 1
clusters(clusters<=alpha & clusters>0)=1;
vals = [];
if length(unique(clusters))>1
    %detect beginning of a sequence of ones
    start1 = strfind([0,clusters==1],[0 1]);
    %detect end of sequence of ones
    end1 = strfind([0,clusters==1],[1 0])-1;
    %if end is at the end of array, add it manually
    if length(start1)>length(end1)
        end1(end+1) = length(clusters);
    end
    vals = [start1;end1];
end
end