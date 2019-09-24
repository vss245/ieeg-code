%Function that takes a cell array
%{s_id} {cs_plus_data} {cs_minus_data} {pcluster} {reg}
function multiplot(arr)
figure
nonempty_idx = find(~cellfun(@isempty,arr(:,1)));
if length(nonempty_idx) <= 3
    rownum = 1;
else
    rownum = ceil(length(nonempty_idx)/2);
end
colnum = round(length(nonempty_idx)/rownum);
mypos = axpos(rownum, colnum, 0.1, 0.1, 0.1, 0.1, 0.1);
ctr_mypos = 1;
for i = 1:size(arr,1)
    if isempty(arr{i})
        continue;
    else
        time = (1:size(arr{i,2},2))/240;
        axes('position',mypos(ctr_mypos,:))
        hold on
        plot(time,arr{i,2}','r')
        hold on
        plot(time,arr{i,3}','k')
        title([arr{i,1} arr{i,5}],'Interpreter','none')
        xlim([0 3.5])
        pcluster = arr{i,4};
        for n = 1:length(pcluster)
            if pcluster(n)~=-1 && pcluster(n) < 0.05
                plot(n/240,12,'k*','DisplayName','significant clusters')
            end
        end
        ctr_mypos = ctr_mypos+1;
    end
end
end