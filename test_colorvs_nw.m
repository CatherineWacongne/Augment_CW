function [net_success, input_acts, hidden_acts,q_acts, fig_hnd, pretty, trial_types, reward_trials ] = test_colorvs_nw(nw, test)


pretty = false;
%trial_type_labels = {'R-1','R-2','R-3','R-4','R-5','R-6','R-7','G-1','G-2','G-3','G-4','G-5','G-6','G-7','B-1','B-2','B-3','B-4','B-5','B-6','B-7'};
trial_types = unique(test);%[[ones(7,1);2*ones(7,1);3*ones(7,1)] repmat([2:8]', 3,1)];%[1 2; 1 3; 1 4; 1 5]; % p-l;p-r;a-l;a-r


states = zeros(size(trial_types,1), 50);
input_acts = zeros(size(trial_types,1), 50, nw.n_inputs*2);
hidden_acts = zeros(size(trial_types,1), 50,nw.ny);
q_acts = zeros(size(trial_types,1), 50, nw.nz+nw.nzs);

trial_ends = zeros(size(trial_types,1),1);
reward_trials = zeros(size(trial_types,1),1);

% Number of tests
seed = 1;
net_success = true;

% for experiments, fix the random generator:
% rnd_stream = RandStream('mt19937ar','Seed', seed);
% RandStream.setDefaultStream(rnd_stream);

% Stop learning; set to completely greedy strategy
nw.beta = 0;

nw.exploit_prob = 1;
nw.resetTraces();
nw.previous_qa = 0;
nw.delta = 0;

% Test network on all trial-types
for i = 1:numel(trial_types)
    
    epoch = 1;
    
    % Task Settings:
    t = ColorVSTask();
    t.Color_only = 0;
    t.showdistractors = 1;
    t.reward_vs = 1;
    t.reward_color = 0;
    
    %t.setTrialType(trial_types(i,1), trial_types(i,2));
    t.setTrialTypeGen(trial_types(i))
    
    nw.resetTraces();
    nw.previous_qa = 0;
    nw.delta = 0;
    
    new_input = t.nwInput;
    reward = 0;
    trialend = false;
    
    
    
    
    while(true)
        %%% Update Network
        [action] = nw.doStep(new_input,reward, trialend);
        
        states(i,epoch) = t.STATE;
        input_acts(i,epoch, :) =  nw.X';
        hidden_acts(i,epoch,:) = nw.Y';
        q_acts(i,epoch,:) = nw.qas';
        
        
        if (trialend)
            t.stateReset();
            trial_ends(i) = epoch;
            
            if (reward <= 0.7)
                net_success = false;
                reward_trials(i)=0;
            else
                reward_trials(i)=1;
            end
            
            break;
        end
        
        %%% Update Task
        [new_input, reward, trialend] = t.doStep(action);
        epoch = epoch + 1;
    end
end

[ events, offsets, n_evs ] = ggsa_convInputEvent(squeeze(input_acts(1,1:trial_ends(1), : )));
event_idxes = [ offsets ];
xlabels = { 'F', 'C', 'G'};


%% plots and further analysis
n_unit_plot = 7;
cue_col = floor(trial_types/1e4);
target_pos = floor((trial_types-cue_col*1e4)/1e3);
targ_state = 6;
d_input = squeeze(sum(input_acts.*repmat(states==targ_state,[1,1,size(input_acts,3)]),2))./repmat(sum(states==targ_state,2),[1,size(input_acts,3)]);
d_act = squeeze(sum(hidden_acts.*repmat(states==targ_state,[1,1,size(hidden_acts,3)]),2))./repmat(sum(states==targ_state,2),[1,size(hidden_acts,3)]);
p = zeros(1,size(hidden_acts,3));
for h = 1:size(hidden_acts,3)
    p(h)=anova1(d_act(:,h), cue_col, 'off');
end
targ_displ = d_input(:,1:24);

if 0
for t1 = 1:numel(trial_types)-1
    for t2=t1+1:numel(trial_types)
        if all(1-(targ_displ(t1,:)-targ_displ(t2,:)))
            % display the activity of the units in both conditions
            modul_index = mean(abs(squeeze(hidden_acts(t1,5:6,:))-squeeze(hidden_acts(t2,5:6,:))))./mean(abs(squeeze(hidden_acts(t1,5:6,:))+squeeze(hidden_acts(t2,5:6,:)))/2);
            [~,I] = sort(modul_index,'descend');
            hdns = I(1:n_unit_plot);
            
            
            
            % display the final config
            f1 = figure('Color', [1 1 1], 'Position', [560 481 560 470]);axes;hold on
            handles_tv = zeros(1,25);
            
            n_pos = 8;
            for c = 1:3
                col_point = zeros(1,3);
                col_point(c) = 1;
                cue_col = .7*ones(1,3);
                cue_col(c) = 1;
                handles_tv((c-1)*n_pos+1) = plot(gca, 5, 9, 'o', 'MarkerSize', 14, 'MarkerFaceColor', cue_col, 'MarkerEdgeColor', [0 0 0]);
                for p = 1:7
                    handles_tv((c-1)*n_pos+p+1) = plot(gca, 5+2*cos(p*2*pi/7+pi/14), 5+2*sin(p*2*pi/7+pi/14), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
                end
%                 handles_tv((c-1)*n_pos+2) = plot(gca, 5+2*cos(pi/4), 5+2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
%                 handles_tv((c-1)*n_pos+3) = plot(gca, 7, 5, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
%                 handles_tv((c-1)*n_pos+4) = plot(gca, 5+2*cos(pi/4), 5-2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
%                 handles_tv((c-1)*n_pos+5) = plot(gca, 5, 3, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
%                 handles_tv((c-1)*n_pos+6) = plot(gca, 5-2*cos(pi/4), 5-2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
%                 handles_tv((c-1)*n_pos+7) = plot(gca, 3, 5, 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
%                 handles_tv((c-1)*n_pos+8) = plot(gca, 5-2*cos(pi/4), 5+2*cos(pi/4), 'o', 'MarkerSize', 14, 'MarkerFaceColor', col_point, 'MarkerEdgeColor', col_point);
            end
            handles_tv(25) = plot(gca,5,5,'k+'); % FIX
            set(gca, 'Visible','off')
            
            set(gca,'XLim',[0,10],'YLim',[0,10]);
            
            for i = 1:25
                if (input_acts(t1,7,i) == 1 | input_acts(t1,4,i) )
                    set(handles_tv(i),'Visible', 'on');
                else
                    set(handles_tv(i),'Visible','off');
                end
            end
             keyboard;
            for i = 1:25
                if (input_acts(t2,7,i) == 1 | input_acts(t2,4,i) )
                    set(handles_tv(i),'Visible', 'on');
                else
                    set(handles_tv(i),'Visible','off');
                end
            end
%             keyboard;
            
            % display hidden units and Q val activity
            n_cond_plot = 2;
            conds = [t1 t2];
            fig_hnd = figure('Color', [1 1 1]);
            j_max = size(hdns,2)+1;
            subhs = zeros(j_max,n_cond_plot);
            subhs_idc =  zeros(j_max,4);
            
            for i = 1:n_cond_plot
                for j = 1:j_max
                    subhs(j,i) = subplot(j_max,n_cond_plot, (j - 1) * n_cond_plot + i );
                    subhs_idc(j,i) = (j - 1) * n_cond_plot + i;
                    set(subhs(j,i),'NextPlot','add');
                end
            end
            
            colors = ['g','y','c','k','r','m','b' ];
            fcolors = [.5 1 .5; 1 1 .5 ; .5 1 1 ;.5 .5 .5;1 .5 .5 ; 1 .5 1;.5 .5 1 ];
            for i = 1:n_cond_plot
                for j = 1:(j_max-1)
                    area(subhs(j,i),  squeeze(hidden_acts(conds(i),1:trial_ends(conds(i)), hdns(j))), 'FaceColor', fcolors(j,:), 'EdgeColor', colors(j) );
                    axis(subhs(j,i),[1,8,0,1]);
                    if i ==1
                       ylabel(subhs(j,i),num2str(hdns(j))) 
                    end
                    if j==1
                        cue = num2str(trial_types(conds(i)));
                       title(subhs(j,i),['cue ' cue(1)]) 
                    end
                end
            end
            c = colormap('hot');
            c = c(1:6:end,:);
            %set(gca, 'ColorOrder', blues)
            
            for i = 1:n_cond_plot
                set(subhs(j_max,i), 'ColorOrder', c)
                plot(subhs(j_max,i), squeeze(q_acts(conds(i),1:trial_ends(conds(i)), 4:end)));
                axis(subhs(j_max,i),[1,8,0,1.75]);
            end
            
        end
    end
end
else 
    fig_hnd = figure;
end

%% anova to get neurons sensitive to target position and cue color
% average activity for cue*target position conditions 
activ = zeros(3,7,10, nw.ny);
for c = 1:3
    for tp = 1:7
        activ(c,tp,:,:) = mean(hidden_acts(find(floor(trial_types/1e3)==c*10+tp),1:10,:))  ;%hidden_acts(i,epoch,:)
    end
end
%  p = zeros(10,95,2);
%  for t=4:9
%      for n = 1:95
%          p(t,n,:) = anova2(activ(:,:,t,n),1,'off');
%          
%      end
%  end
%% visu in multi dim space
% 
% cl = colormap('hot');
% cl = cl(1:6:end,:);
% m = {'+', 'o', 's'};
% for t=1:9
%     r = squeeze(activ(:,:,t,:));
%     r2 = permute(r,[3 2 1]);
%     % X is n-by-p where p are the neurons and n the mesures
%     X = reshape(r2,[95,21]);
%     [COEFF,SCORE] = princomp(X');
%     p1 = X'*COEFF(:,1);
%     p2 = X'*COEFF(:,2);
%     figure; hold on ; title(['t = ' num2str(t)])
%     for c = 1:3
%         for tp = 1:7
%             plot(activ(c,tp,6,82),activ(c,tp,6,83), m{c}, 'MarkerEdgeColor',cl(tp,:),'MarkerSize',10 )
%             %plot(p1((c-1)*7+tp),p2((c-1)*7+tp), m{c}, 'MarkerEdgeColor',cl(tp,:),'MarkerSize',10 )
%         end
%     end
% end

%%



