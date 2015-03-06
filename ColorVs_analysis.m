% load 150108_resultsColorVS_gen_fb.mat
% load('150112_resultsColorVS_gen_fb.mat')
PngDir = 'C:\Users\wacongne\Documents\PostDoc\Modeling\AuGMEnT_Matlab\Results\190208\';
n_trials = 2000;
test =  t.generalization_trials(1:n_trials);
trial_types = unique(test);
[net_success, input_acts, hidden_acts,q_acts, fig_hnd, pretty, trial_types, reward_trials ] = test_colorvs_nw(n, test);

%%
figure;imagesc(n.weights_xy(1+[1:25 26 34 42 27 35 43 28 36 44 29 37 45 30 38 46 31 39 47 32 40 48 33 41 49 50],:), [-2 2])
W_xreord = n.weights_xy(1+[1:25 26 34 42 27 35 43 28 36 44 29 37 45 30 38 46 31 39 47 32 40 48 33 41 49 50],:);
W_modul = [mean(W_xreord(26:28,1:25));mean(W_xreord(29:31,1:25));mean(W_xreord(32:34,1:25));...
    mean(W_xreord(35:37,1:25));mean(W_xreord(38:40,1:25));mean(W_xreord(41:43,1:25))...
    ;mean(W_xreord(44:46,1:25));mean(W_xreord(47:49,1:25))];
pos_select = zeros(1,25);
Gpos =  reshape( ones(3,1)*(1:8),[1,24]);
Gcol =  reshape( ones(8,1)*(1:3),[1,24]);
P_anovPos = zeros(1,25);
P_anovCol = zeros(1,25);
for ny = 1:25
    P_anovPos(ny)= anova1(W_xreord(26:49,ny),Gpos, 'off');
    P_anovCol(ny)= anova1(W_xreord(1:24,ny),Gcol, 'off');
    if P_anovPos(ny)<0.05
        [~,pos_select(ny)] = max(W_modul(:,ny));
    end
    
end
yreord = [find(pos_select==0) find(pos_select==1), find(pos_select==2), find(pos_select==3) find(pos_select==4) find(pos_select==5) find(pos_select==6) find(pos_select==7) find(pos_select==8)];
W_xyreord = W_xreord(:,yreord);
figure;imagesc(W_xyreord, [-2 2]); title({'Synaptic Weights between the input units and hidden units '; 'reordered to show position sensitivity'});
ylabel('Input Units')
set(gca,'YTickMode','auto','YTickLabel', {'NormalUnits', 'FP', 'ModulUnits(reordered by position)', 'FP(modul)'}, 'YTick', [ 12 25 37 50] ); xlabel('Hidden Units'); colorbar
set(gcf,'PaperPositionMode','auto')
% print(gcf,'-dpng',[PngDir 'Wxy_TargPosSensitivity.png'])

figure; imagesc([log10(P_anovPos(yreord));log10(P_anovCol(yreord))])
figure; imagesc([P_anovPos(yreord)<0.01;P_anovCol(yreord)<0.01])
figure; bar([numel(find(P_anovPos<0.01&P_anovCol<0.01)), numel(find(P_anovPos>=0.01&P_anovCol<0.01)),numel(find(P_anovPos<0.01&P_anovCol>=0.01)) ])
set(gca,'XTickMode','auto','XTickLabel', {'Color & Position', 'Color only', 'Position only'}, 'XTick', [ 1 2 3] );
ylabel('number of hidden units selective ')

%% hidden unit activity during cue presentation
Gcol = floor(trial_types/1e9);
Gposcue = floor(trial_types/1e8)-10*Gcol;
P_anovPos = zeros(1,25);
P_anovCol = zeros(1,25);
% for ny = 1:25
%      P_anovPos(ny)= anova1(hidden_acts(:,4,ny),Gposcue, 'on');
%      P_anovCol(ny)= anova1(hidden_acts(:,4,ny),Gcol, 'off');
% %      if P_anovPos(ny)<0.05
% %         [~,pos_select(ny)] = max(W_modul(:,ny));
% %      end
%
% end
Data =  zeros(3,8,25);
for col = 1:3
    for pos = 1:8
        Data(col, pos, :) = mean(squeeze(hidden_acts(Gcol==col & Gposcue==pos,4,1:25)));
    end
end

for ny = 1:25
    [P] = anova2(squeeze( Data(:,:,ny)),1,'off');
    P_anovPos(ny) = P(1);
    P_anovCol(ny) = P(2);
end
figure; imagesc([P_anovPos<0.05;P_anovCol<0.05])
[~, I] = sort(P_anovCol, 'ascend');
figure; imagesc(n.weights_yz(I+1,:)); title({'Synaptic Weights between hidden units and q units '; 'reordered by significance (p-value) of color sensitivity of the hidden units'})
set(gca,'XTickMode','auto','XTickLabel', {'R', 'G', 'B', 'FP', 'Positions'}, 'XTick', [ 1 2 3 4 8] ); xlabel('Q Units'); colorbar
ylabel('Hidden Units')
set(gcf,'PaperPositionMode','auto')
% print(gcf,'-dpng',[PngDir 'Wyz_CueColSensitivity.png'])

Gpostarg = floor(trial_types/1e7)-100*Gcol-10*Gposcue;
Data2 =  zeros(3,8,25);
for col = 1:3
    for pos = 1:8
        Data2(col, pos, :) = mean(squeeze(hidden_acts(Gcol==col & Gpostarg==pos,5,1:25)));
    end
end

for ny = 1:25
    [P] = anova2(squeeze( Data2(:,:,ny)),1,'off');
    P_anovPos(ny) = P(1);
    %     P_anovCol(ny) = P(2);
end
figure; imagesc([P_anovPos<0.01;P_anovCol<0.01])

%%
figure; subplot(1,2,1);imagesc(squeeze(input_acts(20,1:6,:)), [-.5 .5]);subplot(1,2,2);imagesc(squeeze(hidden_acts(20,1:6,1:25)), [-.5 .5]);
figure; subplot(1,2,1);imagesc(squeeze(input_acts(22,1:6,:)), [-.5 .5]);subplot(1,2,2);imagesc(squeeze(hidden_acts(22,1:6,1:25)), [-.5 .5]);
figure;imagesc(squeeze(hidden_acts(22,1:6,1:25))- squeeze(hidden_acts(20,1:6,1:25)), [-.5 .5]);

t1 = 522;
t2 = 524;
figure; subplot(1,2,1);imagesc(squeeze(input_acts(t1,1:6,:)), [-.5 .5]);subplot(1,2,2);imagesc(squeeze(hidden_acts(t1,1:6,1:25)), [-.5 .5]);
figure; subplot(1,2,1);imagesc(squeeze(input_acts(t2,1:6,:)), [-.5 .5]);subplot(1,2,2);imagesc(squeeze(hidden_acts(t2,1:6,1:25)), [-.5 .5]);
figure;imagesc(squeeze(hidden_acts(t2,1:6,1:25))- squeeze(hidden_acts(t1,1:6,1:25)), [-.5 .5]);


figure;[y2,x2 ]= hist(reshape(n.weights_yz(1:25,5:12),[1,25*8]),20);  y2 = y2/sum(y2); f2 = fit(x2.',y2.','gauss1'); plot(f2,x2,y2)
figure;[y1,x1 ]= hist(reshape(n.weights_yz(1:25,1:3),[1,25*3]),20);   y1 = y1/sum(y1); f1 = fit(x1.',y1.','gauss1'); plot(f1,x1,y1)
figure; plot(f2,x2,y2); hold on ; plot(f1,'g', x1,y1, 'k.');


figure;imagesc(squeeze(mean(squeeze(hidden_acts(:,1:6,1:25)))));
ndistr = zeros(1,n_trials);
for t=1:n_trials
    a = num2str(mod(trial_types(t),1e7) );
    ndistr(t) = numel(strfind(a,'1'));
end
figure;
for neur = 1:25;
    activ = zeros(1,8);
    for d = 1:8
        activ(d) = squeeze(mean(hidden_acts(find(ndistr==(d-1)),5,neur)));
    end
    
    subplot(5,5,neur);bar(activ(8:-1:1)); ylim([0 1]); set(gca,'XTickMode','auto','XTickLabel', 0:7, 'XTick',1:8 );
    if neur ==3
        title('hidden units activity in function of the number of distractors')
    end
end



figure;
for neur = 1:12;
    activ = zeros(1,8);
    for n1 = 1:8
        activ(n1) = squeeze(mean(q_acts(find(ndistr==(n1-1)),5,neur)));
    end
    
    subplot(3,4,neur);bar(activ(8:-1:1)); ylim([-1.5 1]);set(gca,'XTickMode','auto','XTickLabel', 0:7, 'XTick',1:8 );
    if neur ==2
        title('           Q units activity in function of the number of distractors')
    end
    
end

%% Resp of the modulated input units
targ_resp = zeros(1,n_trials);
other_resp = zeros(24,n_trials);
for trial = 1:n_trials
    targ_resp(trial) =  input_acts(trial,5,25+(Gcol(trial)-1)*8+Gpostarg(trial) );
    p = 1:25;
    p((Gcol(trial)-1)*8+Gpostarg(trial))=[];
    other_resp(:,trial) =  squeeze(input_acts(trial,5,25+p ));
end
figure;boxplot([targ_resp'; reshape(other_resp,[24*n_trials,1])], [ones(n_trials,1); 2*ones(24*n_trials,1)])


t1 = 5;
p_respond = zeros(n.ny_normal,3,8);
for neur = 1:25%95
    %figure;
    for col = 1:3
        for p = 1:8
            stim_present = input_acts(:,5,25+(col-1)*8+p)> 0.9;
            stim_absent = input_acts(:,5,25+(col-1)*8+p+1)~=1;
            X =  hidden_acts(stim_present,t1,neur);
            Y =  hidden_acts(stim_absent,t1,neur);
            [H,p_respond(neur,col,p)] = ttest2(X',Y',0.05, 'right');
        end
    end
end
H = p_respond<0.01;
figure; imagesc(squeeze(sum(H(:,:,:),2)))
figure; imagesc(squeeze(sum(H(:,:,:),3)))
