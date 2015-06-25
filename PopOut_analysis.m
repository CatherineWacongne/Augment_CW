% load 150108_resultsColorVS_gen_fb.mat
% load('150112_resultsColorVS_gen_fb.mat')
PngDir = 'C:\Users\wacongne\Documents\PostDoc\Modeling\AuGMEnT_Matlab\Results\150603\';
n_trials = 200;
test =  t3.generalization_trials(1:n_trials);%generalization_trials(1:n_trials);
trial_types = unique(test);
[net_success, input_acts, hidden_acts,q_acts, fig_hnd, pretty, trial_types, reward_trials ] = test_popout_nw(n, trial_types);

%%
n_hidden = 21;
figure;imagesc(n.weights_xy, [-2 2])
Gpos =  reshape( (ones(2,1)*(1:8))',[1,16]);
Gcol =  reshape( ones(8,1)*(1:2),[1,16]);
W_xreord = [n.weights_xy(1+([find(Gpos==1), find(Gpos==2), find(Gpos==3), find(Gpos==4), find(Gpos==5), find(Gpos==6), find(Gpos==7), find(Gpos==8)]), 1:20) n.weights_xy(18+([find(Gpos==1), find(Gpos==2), find(Gpos==3), find(Gpos==4), find(Gpos==5), find(Gpos==6), find(Gpos==7), find(Gpos==8)]), 21)];
figure; imagesc(W_xreord, [-2 2]);
W_modul = [mean(W_xreord(1:2,1:n_hidden));mean(W_xreord(3:4,1:n_hidden));mean(W_xreord(5:6,1:n_hidden));...
    mean(W_xreord(7:8,1:n_hidden));mean(W_xreord(9:10,1:n_hidden));mean(W_xreord(11:12,1:n_hidden))...
    ;mean(W_xreord(13:14,1:n_hidden));mean(W_xreord(15:16,1:n_hidden))];
pos_select = zeros(1,n_hidden);

P_anovPos = zeros(1,n_hidden);
P_anovCol = zeros(1,n_hidden);
for ny = 1:n_hidden
    P_anovPos(ny)= anova1(W_xreord(:,ny),reshape( (ones(2,1)*(1:8)),[1,16]), 'off');
    P_anovCol(ny)= anova1(W_xreord(:,ny),reshape( (ones(8,1)*(1:2))',[1,16]), 'off');
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

%% hidden unit activity during display presentation
Gcol = floor(trial_types/1e4);
Gposcue = floor(trial_types/1e3)-10*Gcol;
P_anovPos = zeros(1,n_hidden);
P_anovCol = zeros(1,n_hidden);
% for ny = 1:25
%      P_anovPos(ny)= anova1(hidden_acts(:,4,ny),Gposcue, 'on');
%      P_anovCol(ny)= anova1(hidden_acts(:,4,ny),Gcol, 'off');
% %      if P_anovPos(ny)<0.05
% %         [~,pos_select(ny)] = max(W_modul(:,ny));
% %      end
%
% end
Data =  zeros(2,8,n_hidden);
for col = 1:2
    for pos = 1:8
        Data(col, pos, :) = mean(squeeze(hidden_acts(Gcol==col & Gposcue==pos,4,1:n_hidden)));
    end
end


for ny = 1:n_hidden
    [P] = anova2(squeeze( Data(:,:,ny)),1,'on');
    P_anovPos(ny) = P(1);
    P_anovCol(ny) = P(2);
end
figure; imagesc([P_anovPos<0.05;P_anovCol<0.05])
[~, I] = sort(P_anovPos, 'ascend');
figure; imagesc(n.weights_yz(I+1,:)); title({'Synaptic Weights between hidden units and q units '; 'reordered by significance (p-value) of position sensitivity of the hidden units'})
set(gca,'XTickMode','auto','XTickLabel', {'FP', 'Positions'}, 'XTick', [ 1 5] ); xlabel('Q Units'); colorbar
ylabel('Hidden Units')
set(gcf,'PaperPositionMode','auto')
% print(gcf,'-dpng',[PngDir 'Wyz_CueColSensitivity.png'])

Gpostarg = floor(trial_types/1e3)-10*Gcol;
Data2 =  zeros(2,8,n_hidden);
for col = 1:2
    for pos = 1:8
        Data2(col, pos, :) = mean(squeeze(hidden_acts(Gcol==col & Gpostarg==pos,4,1:n_hidden)));
    end
end

Data2 =  zeros(2,8,51);
for col = 1:2
    for pos = 1:8
        Data2(col, pos, :) = mean(squeeze(input_acts(Gcol==col & Gpostarg==pos,4,1:51)));
    end
end


for ny = 1:n_hidden
    [P] = anova2(squeeze( Data2(:,:,ny)),1,'off');
    P_anovPos(ny) = P(1);
    %     P_anovCol(ny) = P(2);
end
figure; imagesc([P_anovPos<0.01;P_anovCol<0.01])

%%


figure;imagesc(squeeze(mean(squeeze(hidden_acts(:,1:6,1:n_hidden)))));
ndistr = zeros(1,n_trials);
for t=1:n_trials
    a = dec2bin(mod(trial_types(t),1e3) ,7);
    ndistr(t) = numel(strfind(a,'1'));
end
figure;
for neur = 1:n_hidden;
    activ = zeros(1,8);
    for d = 1:8
        activ(d) = squeeze(mean(hidden_acts(find(ndistr==(d-1)& Gcol==1),4,neur)));
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
        activ(n1) = squeeze(mean(q_acts(find(ndistr==(n1-1)),4,neur)));
    end
    
    subplot(3,4,neur);bar(activ(8:-1:1)); ylim([-1.5 1]);set(gca,'XTickMode','auto','XTickLabel', 0:7, 'XTick',1:8 );
    if neur ==2
        title('           Q units activity in function of the number of distractors')
    end
    
end

