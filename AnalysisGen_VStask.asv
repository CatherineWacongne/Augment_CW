t=8; % time of interest
p_results = zeros(95,3,7);
for n = 1:95%95
%    figure;
    for col = 1:3
        for p = 1:7
            
            % get the activity for conditions where the position p is
            % of color c and cue is color c
            targ_trials = input_acts(:,4,(col-1)*8+1)==1 & input_acts(:,7,(col-1)*8+p+1)==1;
            X = hidden_acts(targ_trials,t,n);
            
            % get the activity for conditions where the position p is
            % of color c and cue is NOT color c
            n_targ_trials = input_acts(:,4,(col-1)*8+1)==0 & input_acts(:,7,(col-1)*8+p+1)==1;
            Y = hidden_acts(n_targ_trials,t,n);
            
            % perform an unpaired two sample ttest
            if (mean(X)- mean(Y))<1e-3
                p_results(n,col,p)=2;
            else
                [H,p_results(n,col,p)] = ttest2(X',Y');
                if 0%H
                    subplot(3,7,(col-1)*7+p);boxplot([X; Y],[ones(numel(X),1); 2*ones(numel(Y),1)]);%ylim([0 0.04]);
                end
            end
            
        end
    end
end
% for n =  81:95
%     imagesc(squeeze(H(n,:,:))); colorbar;
%     pause
% end
H = p_results<0.05;
figure; imagesc(squeeze(sum(H,2)))
figure; imagesc(squeeze(sum(H,3)))

