function pcluster = permtest2(Fstat, pstat, Fstatperm, pstatperm)
% function pcluster = permtest(Fstat, pstat, Fstatperm, pstatperm)
% Dominik R Bach
% last edited 12.01.2017
% adapted for 2D testing 14.03.2017

% stack true over permutation models
Fall = NaN(size(Fstat, 1), size(Fstat, 2), size(Fstatperm, 3) + 1);
pall = Fall;
Fall(:, :, 1) = Fstat;
Fall(:, :, 2:end) = Fstatperm;
pall(:, :, 1) = pstat;
pall(:, :, 2:end) = pstatperm;
% loop over and permutations
for k = 1:size(Fall, 3)
    % find all supra-threshold clusters and define sum F-value
    Ftemp = Fall(:, :, k);
    ptemp = pall(:, :, k);
    L = bwlabeln(ptemp < .05);
    for c = 1:max(unique(L))
        Fsum(c) = sum(Ftemp(L == c));
    end;
    if ~isempty(c)
       [Fsum, clusterindx] = sort(Fsum(:), 1, 'descend');
        % on pass 1, store all values
        if k == 1
            Fcluster = Fsum;
            Fselect = L;
            Findx = clusterindx;
        else
            Fclustermax(k-1) = Fsum(1);
        end;
    elseif k == 1
        Fselect = L;
        break
    else
        Fclustermax(k-1) = 0;
    end;
end
% at the end, assess cluster-level significance
% -1: below inclusion threshold, > 0: exact value
pcluster = -1 * ones(size(Fstat));
for c = 1:max(unique(Fselect))
    pcluster(Fselect == Findx(c)) = (sum(Fcluster(c) < Fclustermax)/numel(Fclustermax));
end