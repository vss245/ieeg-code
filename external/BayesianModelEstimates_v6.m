% BEHAVIORAL MODEL ESTIMATES
% For parametric regressors in model-based fMRI analysis

filepath = fullfile(cd,'..','..','Behavior');
load(fullfile(filepath,'AllSubs_behvecs_v3.mat'))
% Contains sequence of CSs and USs for each subject

plot_on = 1; % Plotting on/off

%% Computing model quantities
%n_blocks = size(behvectors,2); % Number of blocks
n_subj = size(behvectors,2); % Number of subjects
n_cs = 8; % Number of different types of CS
trials = [50 6]; % Number of trials per trial type for the different parts of the experiment

for subj = 1:n_subj
    
    cs = behvectors{subj}.CS;
    us = behvectors{subj}.US;
    
    %loop across CS:
        
    for current_cs = 1:n_cs
        
        clear BV_out BM_out BE_out KL_out BV_out SO_out PE_out seq b_post b_prio a_post a_prio pd_prio
        
        seq = us(cs == current_cs); % Outcome sequence
        n_trials = length(seq); % Number of trials
        
        % Uniform prior
        a_init = 1; % alpha
        b_init = 1; % beta
        % Initialize alpha and beta
        a = nan(n_trials+1, 1);
        b = nan(n_trials+1, 1);
        % Set first a and b
        a(1) = a_init;
        b(1) = b_init;
        
        % Initialize Conditioned Response (CR) results
        BM_out = nan(n_trials, 1);
        BE_out = nan(n_trials, 1);
        BV_out = nan(n_trials, 1);
        
        % Initialize Unconditioned Response (UR) results
        SO_out = nan(n_trials, 1);
        KL_out = nan(n_trials, 1);
        PE_out = nan(n_trials, 1);
   
        % Run all updates and compute CRs and URs
        for i_trial = 1: n_trials

            % Get current a and b
            a_prio = a(i_trial);
            b_prio = b(i_trial);
            
            % Compute all CRs
            % Prior mean
            BM_out(i_trial) = a_prio./(a_prio+b_prio);
            % Volatility
            BV_out(i_trial) = -log(a_prio+b_prio);
            % Prior entropy
            BE_out(i_trial) = log(beta(a_prio,b_prio))-(a_prio-1).*psi(a_prio)-(b_prio-1).*psi(b_prio)+(a_prio+b_prio-2).*psi(a_prio+b_prio);
            
            % Get current US
            outcome = seq(i_trial);

            % Update a and b
            a_post = a_prio + (outcome == 1); % US+
            b_post = b_prio + (outcome == 0); % US-
            
            % Store updated a and b
            a(i_trial+1) = a_post;
            b(i_trial+1) = b_post;
                
            % Compute all URs
            % Information-theoretic surprise
            switch outcome
                case 1 % US+
                    SO_out(i_trial) = log(1./BM_out(i_trial));
                case 0 % US-
                    SO_out(i_trial) = log(1./(1-BM_out(i_trial)));
            end
            % KL divergence between the prior and posterior beliefs
            KL_out(i_trial) = log(beta(a_prio, b_prio)/beta(a_post, b_post))+(a_post-a_prio)*psi(a_post)+(b_post-b_prio)*psi(b_post)+(a_prio-a_post+b_prio-b_post)*psi(a_post+b_post);     
        
            %Weighted prediction error:
            % PE = E(theta)_n+1 - E(theta)_n
            % E(theta)_n = a_prio/(a_prio+b_prio)
            % Expectation before trial n
            % E(theta)_n+1 is expectation after trial n
            % a_prio = a_start + shocks
            % b_prio = b_start + (trials - 1 - shocks)
            % a_start = b_start = 1
            % k = shocks until now (until trial n-1)
            % n = trials until now
            % Therefore: E(theta)_n 
            % = a_prio/(a_prio+b_prio)
            % = (a_start+k) / (a_start+k+b_start+n-1-k)
            % = (1+k) / (1+k+1+n-1-k)
            % = (k+1) / (n+1)
            %    E(theta)_n+1 - E(theta)_n
            % =    1  / (n+2) -    1  / (n+1) if CS-
            % = (k+1) / (n+2) - (k+1) / (n+1) if CS+US-
            % = (k+2) / (n+2) - (k+1) / (n+1) if CS+US+
            %
            % Simplified:
            % =   -1 / (n+2)(n+1) if CS-
            % = -k-1 / (n+2)(n+1) if CS+US-
            % =  n-k / (n+2)(n+1) if CS+US+
            
            n = i_trial; % Trials until now
            k = a(i_trial); % No. of US+ before current trial's outcome
            
            if current_cs == 1 %CS-
                PE_out(i_trial) = -1/((n+2)*(n+1));
                
            elseif current_cs > 1 && seq(i_trial) == 0 %CS+US-
                PE_out(i_trial) = (-k-1)/((n+2)*(n+1));
                
            elseif current_cs > 1 && seq(i_trial) == 1 %CS+US+
                PE_out(i_trial) = (n-k)/((n+2)*(n+1));
                
            end
        
        end
        
        if current_cs<5
            Pred1{subj}.BM(current_cs,:) = BM_out;
            Pred1{subj}.BE(current_cs,:) = BE_out;
            Pred1{subj}.KL(current_cs,:) = KL_out;
            Pred1{subj}.VO(current_cs,:) = BV_out;
            Pred1{subj}.SO(current_cs,:) = SO_out;
            Pred1{subj}.PE(current_cs,:) = PE_out;
        else
            Pred2{subj}.BM(current_cs-4,:) = BM_out;
            Pred2{subj}.BE(current_cs-4,:) = BE_out;
            Pred2{subj}.KL(current_cs-4,:) = KL_out;
            Pred2{subj}.VO(current_cs-4,:) = BV_out;
            Pred2{subj}.SO(current_cs-4,:) = SO_out;
            Pred2{subj}.PE(current_cs-4,:) = PE_out;
        end

    end
    
    %% Plotting
    if plot_on
        
        model_labels = {'Prior mean'; 'Prior entropy'; 'KL divergence - model update'; 'Uncertainty / volatility'; 'Surprise'; 'Weighted prediction error'};
        
        cscol = [189,201,225
            103,169,207
            28,144,153
            1,108,89]./256; % add color
        
        ff = figure;
        
        for cond = 1:4 % Subplots
            
            subplot(3,2,1)
            hold on,
            plot(Pred1{subj}.BM(cond,:), 'Color', cscol(cond,:),'LineWidth',3)
            title(model_labels(1))
            
            subplot(3,2,2)
            hold on,
            plot(Pred1{subj}.BE(cond,:), 'Color', cscol(cond,:),'LineWidth',3)
            title(model_labels(2))
            
            subplot(3,2,3)
            hold on,
            plot(Pred1{subj}.KL(cond,:), 'Color', cscol(cond,:),'LineWidth',3)
            title(model_labels(3))
            
            subplot(3,2,4)
            hold on,
            plot(Pred1{subj}.VO(cond,:), 'Color', cscol(cond,:),'LineWidth',3)
            title(model_labels(4))
            
            subplot(3,2,5)
            hold on,
            plot(Pred1{subj}.SO(cond,:), 'Color', cscol(cond,:),'LineWidth',3)
            title(model_labels(5))
            
            subplot(3,2,6)
            hold on,
            plot(Pred1{subj}.PE(cond,:), 'Color', cscol(cond,:),'LineWidth',3)
            title(model_labels(6))
            
        end
        
        legend('CS-','CS+(1/3)','CS+(2/3)','CS+(1)','Location','best')
        
    end
    
end

save(fullfile(filepath, 'AllSubs_behvecs_Predictions_v3.mat'), 'Pred1', 'Pred2')