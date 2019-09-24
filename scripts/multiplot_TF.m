%Function that takes a cell array
%{s_id} {tvals} {pcluster} {reg}
function multiplot_TF(arr)
figure
nonempty_idx = find(~cellfun(@isempty,arr(:,1)));
if length(nonempty_idx) <= 3
    rownum = 1;
elseif length(nonempty_idx) <= 6
    rownum = floor(length(nonempty_idx)/2);
else
    rownum = floor(length(nonempty_idx)/4);
end
colnum = round(length(nonempty_idx)/rownum);
mypos = axpos(rownum, colnum, 0.1, 0.1, 0.1, 0.1, 0.1);
ctr_mypos = 1;
for i = 1:length(arr)
    if isempty(arr{i})
        continue;
    else
    axes('position',mypos(ctr_mypos,:))
    imagesc(arr{i,2}')
    colorbar
    caxis([-7 3])
    title([arr{i,1} arr{i,4}],'Interpreter','none')
    xticklabels = (0:0.5:4.5);
    xticks = linspace(1,size(arr{i,2},1),length(xticklabels));
    set(gca,'YDir','normal','XTick',xticks,'XTickLabel',xticklabels);
    xlabel('Time, s');
    ylabel('Frequency, Hz');
    pcluster = arr{i,3};
    thr_ind = find(pcluster<0.05 & pcluster ~=-1);
    if ~isempty(thr_ind)
        hold on
        contour((pcluster<0.05 & pcluster~=-1)','k')
    end
        ctr_mypos = ctr_mypos+1;
    end
end
end