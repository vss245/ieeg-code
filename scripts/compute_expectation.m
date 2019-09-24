%Bayesian model
%Compute expectation, optional plot and export to csv
data_path = 'C:\Users\prakt_bach\Desktop\Veronika\Intracranial_AL - Copy\Veronika_iEEG_project\data';
cd(data_path);
load data_el.mat data
drawplot = input('draw plot? ');
header = {'subject','channel','trial','expectation'};
all_exp = [];
for subj = 1:5
    %get ntrials
    ntri = length(data(subj).cs_plus);
    %start both a and b at 1
    a_csp = 1;
    b_csp = 1;
    a_csm = 1;
    b_csm = 1;
    exp_csp = nan(ntri+1,1);
    exp_csm = nan(ntri+1,1);
    %get initial priors
    exp_csp(1) = a_csp/(a_csp+b_csp);
    exp_csm(1) = a_csm/(a_csm+b_csm);
    %get trial structure
    trials_csp = data(subj).cs_plus;
    trials_us = data(subj).cs_paired; %get all trials, 1 indicates paired CS+
    expectation = nan(ntri+1,1); %all expectations
    expectation(1) = exp_csp(1); %both 1st exps equal to 0.5
    for tri = 2:ntri+1
        if (trials_csp(tri-1) == 1) && (trials_us(tri-1) == 1) %CS+ and US
            %change CS+ exp
            a_csp = a_csp+1;
            exp_csp(tri) = a_csp/(a_csp+b_csp);
            %don't change CS- exp
            exp_csm(tri) = a_csm/(a_csm+b_csm);
        elseif (trials_csp(tri-1) == 1) && (trials_us(tri-1) == 0) %CS+ and no US
            %change CS+exp
            b_csp = b_csp+1;
            exp_csp(tri) = a_csp/(a_csp+b_csp);
            %don't change CS- exp
            exp_csm(tri) = a_csm/(a_csm+b_csm);
        else %CS-, don't change CS+ exp
            exp_csp(tri) = a_csp/(a_csp+b_csp);
            %adjust CS- exp (never reinforced, so always add 1 to b on CS-
            %trials)
            b_csm = b_csm+1;
            exp_csm(tri) = a_csm/(a_csm+b_csm);
        end
    end
    %Add to overall expectation
    for tri = 1:ntri
        if (trials_csp(tri))
            expectation(tri) = exp_csp(tri);
        else
            expectation(tri) = exp_csm(tri);
        end
    end
    %Plot subject
    if drawplot == 1
        figure
        plot(exp_csp)
        hold on
        plot(exp_csm)
        legend('Expectation for CS+ trials','Expectation for CS- trials')
        title(['Subject ' num2str(subj) ', output of Bayesian model'])
    end
     %Export values for channel
    for ch = 1:length(data(subj).chanHwm)
        %get bad trials
        ch_ind = find(data(subj).chanHwm(ch) == [data(subj).badtrialsWM.channel]);
        exclude = [data(subj).badtrialsWM(ch_ind).trial];
        ch_trials = 1:ntri;
        ch_trials(exclude) = []; 
        ch_ntri = length(ch_trials); %get new length of trials
        all_values = zeros(ch_ntri,4);
        all_values(:,1) = repmat(subj,ch_ntri,1);
        all_values(:,2) = repmat(data(subj).chanHwm(ch),ch_ntri,1);
        all_values(:,3) = ch_trials;
        exp_ch = expectation;
        exp_ch(exclude) = [];
        all_values(:,4) = exp_ch(1:end-1); %disregarding last expectation
        all_exp = vertcat(all_exp,all_values);
    end

end
bayes_data = array2table(all_exp,'VariableNames',header);
writetable(bayes_data,'bayes_data_hip.csv');
