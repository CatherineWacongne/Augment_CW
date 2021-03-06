close all
PngDir = 'C:\Users\wacongne\Documents\Post_doc\Modeling\AuGMEnT_Matlab\Results\141122\';
t=8; % time of interest
p_results = zeros(nw.ny,3,7);
p_respond = zeros(nw.ny,3,7);
Fano_Up_Targ = [];
Fano_Up_NTarg = [];
Fano_Down_targ = [];
Fano_Down_Ntarg = [];
mean_targ_1 = [];
mean_non_targ_1 = [];
mean_targ_0 = [];
mean_non_targ_0 = [];

for n = ny_normal+1:nw.ny%95
   %figure;
    for col = 1:3
        for p = 1:7
            stim_present = input_acts(:,7,(col-1)*8+p+1)==1;
            stim_absent = input_acts(:,7,(col-1)*8+p+1)~=1;
            X =  hidden_acts(stim_present,t,n);
            Y =  hidden_acts(stim_absent,t,n);
            [H,p_respond(n,col,p)] = ttest2(X',Y',0.05, 'right');
        end
    end
end
H = p_respond<0.001;
figure; imagesc(squeeze(sum(H(ny_normal+1:nw.ny,:,:),2)))
figure; imagesc(squeeze(sum(H(ny_normal+1:nw.ny,:,:),3)))
%%
for n = ny_normal+1:nw.ny%95
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
            H=0;
            % perform an unpaired two sample ttest
            if (mean(X)- mean(Y))<0
                POS=0;
                p_results(n,col,p)=2;
                %[H,p_results(n,col,p)] = ttest2(X',Y');
            else
                 POS=1;
                [H,p_results(n,col,p)] = ttest2(X',Y');
                if 0%H
                    subplot(3,7,(col-1)*7+p);boxplot([X; Y],[ones(numel(X),1); 2*ones(numel(Y),1)]);%ylim([0 0.04]);
                end
                
                
            end
            k = 1.5;           
            Q1 = quantile(X, 0.25);
            Q3 = quantile(X, 0.75);
            

            
            [i1,j1] = find(X < Q1 -k*(Q3-Q1));
            [i2,j2] = find(X > Q3 + k*(Q3-Q1));
            
            if POS
                if H
                mean_targ_1 = [mean_targ_1 mean(X)];
                mean_non_targ_1 = [mean_non_targ_1 mean(Y)];
                Fano_Up_Targ = [Fano_Up_Targ var(X)/mean(X)];%numel([i1 i2])  
                Fano_Up_NTarg = [Fano_Up_NTarg var(Y)/mean(Y)];  %
                end
                
            else
                if H
                mean_targ_0 = [mean_targ_0 mean(X)];
                mean_non_targ_0 = [mean_non_targ_0 mean(Y)];
                Fano_Down_targ = [Fano_Down_targ var(X)/mean(X)];%numel([i1 i2]) 
                Fano_Down_Ntarg = [Fano_Down_Ntarg var(Y)/mean(Y)];%
                end
            end
            
        end
    end
end
% for n =  ny_normal+1:nw.ny
%     imagesc(squeeze(H(n,:,:))); colorbar;
%     pause
% end
H = p_results<0.05;
figure; imagesc(squeeze(sum(H(ny_normal+1:nw.ny,:,:),2)))
figure; imagesc(squeeze(sum(H(ny_normal+1:nw.ny,:,:),3)))

col_select = squeeze(sum(H(ny_normal+1:nw.ny,:,:),3));
col_select = col_select>0;
pos_select = squeeze(sum(H(ny_normal+1:nw.ny,:,:),2));
pos_select = pos_select>0;
if 0
figure('Color', [1 1 1], 'Position', [70 489 712 420]); subplot(1,2,1); hist(sum(col_select,2), 0:3); xlim([0 3]); ylim([0 15]); ylabel('number of memory units'); title({'distribution of the number of colors for which '; 'memory units present positive target modulation'})
subplot(1,2,2); hist(sum(pos_select,2), 0:7); xlim([0 8]); ylim([0 15]); title({'distribution of the number of positions for which '; 'memory units present positive target modulation'})
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'PosTargModulation_Selectivity.png']) 

figure('Color', [1 1 1], 'Position', [70 489 712 420]);%subplot(1,2,1); 
%boxplot([mean_non_targ_0  mean_non_targ_1],[ones(numel(mean_non_targ_0),1); 2*ones(numel(mean_non_targ_1),1)]);
subplot(1,2,1); boxplot([mean_targ_1  mean_non_targ_1],[ones(numel(mean_targ_1),1); 2*ones(numel(mean_non_targ_1),1)]); set(gca,'XTickMode','auto','XTickLabel', {'Target', 'Non Target'}, 'XTick', [ 1 2] ); 
title('Mean activity in up regulated conditions')
subplot(1,2,2); boxplot([mean_targ_0  mean_non_targ_0],[ones(numel(mean_targ_0),1); 2*ones(numel(mean_non_targ_0),1)]); set(gca,'XTickMode','auto','XTickLabel', {'Target', 'Non Target'}, 'XTick', [ 1 2] );
title('Mean activity in down regulated conditions')
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'TargetActivityUpDown.png']) 

end
figure('Color', [1 1 1], 'Position', [ 224    64   669   842]);
boxplot([Fano_Up_Targ Fano_Up_NTarg Fano_Down_targ Fano_Down_Ntarg], [ones(1, numel(Fano_Up_Targ)) 2*ones(1, numel(Fano_Up_NTarg)) 3*ones(1, numel(Fano_Down_targ)) 4*ones(1, numel(Fano_Down_Ntarg))] );
set(gca,'XTickMode','auto','XTickLabel', {'Up regulated Target', 'Up regulated Distr',  'DownRegulated Target', 'DownRegulated Distractor'}, 'XTick', [ 1 2  3 4] ); 
title('Fano Factor (Var/Mean) to ')
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'FanoFactor.png']) 


%%
memo_units_reorder = [2  9 10 13 3 5 7 12 15  4 1 6 8 11 14];
t=8;
P_anov = zeros(15,3);
for n = ny_normal+1:nw.ny%95
%     figure;
    for col = 1:3
        X = [];
        G = [];
        for p = 1:7
            
            % get the activity for conditions where the position p is
            % of color c and cue is color c
            targ_trials = input_acts(:,4,(col-1)*8+1)==1 & input_acts(:,7,(col-1)*8+p+1)==1;
            X = [X ; hidden_acts(targ_trials,t,n)];
            G = [G ;p*ones(numel(hidden_acts(targ_trials,t,n)),1)];
                       
        end
        P_anov(n-80, col)= anova1(X,G, 'off');
%         subplot(3,1,(col));boxplot(X,G);%ylim([0 0.04]);
%         if col ==1
%             title(num2str(n))
%         end
    end
end
figure('Color', [1 1 1], 'Position', [70 489 912 420]);
subplot(1,2,1);imagesc(-log10(P_anov(memo_units_reorder,:))); ylabel('unit');xlabel('color'); title({'modulation of hidden memory units response'; 'by position of the target (avova: -log10(p))'})
colorbar
set(gca,'XTickMode','auto','XTickLabel', {'Red', 'Green' 'Blue'}, 'XTick', [ 1 2 3] );
subplot(1,2,2); bar([numel(find(P_anov<0.05 & squeeze(sum(H(ny_normal+1:nw.ny,:,:),3))>0 ))/numel(find(squeeze(sum(H(ny_normal+1:nw.ny,:,:),3))>0 ))    numel(find(P_anov<0.05 & squeeze(sum(H(ny_normal+1:nw.ny,:,:),3))==0 ))/numel(find(squeeze(sum(H(ny_normal+1:nw.ny,:,:),3))==0 ))])  
set(gca,'XTickMode','auto','XTickLabel', {'Up modulated', 'Other'}, 'XTick', [ 1 2] ); 
title({'Probability for the response to targets of a given color of being modulated (p<0.05)'; 'by position depending on the sensitivity to target'})
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'TargetPositionSensitivityPatterns.png']) 
%%
t=5;
DA = zeros(15,3);
for n = ny_normal+1:nw.ny%95
   
    for col = 1:3
        targ_trials = input_acts(:,4,(col-1)*8+1)==1;
        DA(n-ny_normal,col) = mean(hidden_acts(targ_trials,t,n));
        
    end
end

figure('Color', [1 1 1], 'Position', [70 489 912 420]);
subplot(1,2,1); imagesc(squeeze(sum(H(memo_units_reorder+80,:,:),3))); title({'Number of positions for which the activity of memory hidden '; 'units (reordered) is up regulate if a target of a given color is present'})
set(gca,'XTickMode','auto','XTickLabel', {'Red', 'Green' 'Blue'}, 'XTick', [ 1 2 3] ); ylabel('Memory Unit')
subplot(1,2,2); imagesc(DA(memo_units_reorder,:)./repmat(mean(DA(memo_units_reorder,:),2),1,3)); title({'Normalized activity of memory units (reordered) during the delay'; 'in function of the cue color'})
set(gca,'XTickMode','auto','XTickLabel', {'Red', 'Green' 'Blue'}, 'XTick', [ 1 2 3] );
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'ColorSelectivityPatterns.png']) 


%%
load('141122_resultsComplete_gen.mat') 
w_xy = n.weights_xy;
input_reorder = [27 35 43 52 60 68 28:34 36:42 44:50 53:59 61:67 69:75];
figure;imagesc(w_xy(input_reorder,memo_units_reorder+80))
line([4.5 4.5], [0.5 54])
line([9.5 9.5], [0.5 54])
line([-0.5 15.5], [3.5 3.5])
line([-0.5 15.5], [6.5 6.5])
line([-0.5 15.5], [13.5 13.5])
line([-0.5 15.5], [20.5 20.5])
line([-0.5 15.5], [27.5 27.5])
line([-0.5 15.5], [34.5 34.5])
line([-0.5 15.5], [41.5 41.5])

figure; imagesc([w_xy(input_reorder(1:3),memo_units_reorder+80)+w_xy(input_reorder(4:6),memo_units_reorder+80) ; w_xy(input_reorder(7:27),memo_units_reorder+80)+w_xy(input_reorder(28:48),memo_units_reorder+80)], [-8 8] )
line([4.5 4.5], [0.5 54])
line([9.5 9.5], [0.5 54])
line([-0.5 15.5], [3.5 3.5])
line([-0.5 15.5], [10.5 10.5])
line([-0.5 15.5], [17.5 17.5])
line([-0.5 15.5], [24.5 24.5])

Wreord = [w_xy(input_reorder(1:3),memo_units_reorder+80)+w_xy(input_reorder(4:6),memo_units_reorder+80) ; w_xy(input_reorder(7:27),memo_units_reorder+80)+w_xy(input_reorder(28:48),memo_units_reorder+80)];
figure('Color', [1 1 1]); imagesc([mean(Wreord(:,1:4),2) mean(Wreord(:,5:9),2) mean(Wreord(:,10:15),2)],[-2 2])
line([1.5 1.5], [0.5 54])
line([2.5 2.5], [0.5 54])
line([-0.5 15.5], [3.5 3.5])
line([-0.5 15.5], [10.5 10.5])
line([-0.5 15.5], [17.5 17.5])
line([-0.5 15.5], [24.5 24.5])
set(gca,'XTickMode','auto','XTickLabel', {'Red-sensitive', 'Green-sensitive' 'Blue-sensitive'}, 'XTick', [ 1 2 3 ] ); xlabel('Target sensitivity')
set(gca,'YTickMode','auto','YTickLabel', {'Red-Cue', 'Green-Cue' 'Blue-Cue', 'Red-Targets', 'Green-Targets' 'Blue-Targets'   }, 'YTick', [ 1 2 3 7 14 21] ); ylabel('Input type')
title('Weights between input(net ON/OFF) and memory units')
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'Weightsxy_summary.png']) 


W_group = [mean(Wreord(:,1:4),2) mean(Wreord(:,5:9),2) mean(Wreord(:,9:15),2)];
figure('Color', [1 1 1]); imagesc([W_group(1:3,:); mean(W_group(4:7:end,:)); mean(W_group(5:7:end,:)) ; mean(W_group(6:7:end,:)) ; mean(W_group(7:7:end,:)); mean(W_group(8:7:end,:)); mean(W_group(9:7:end,:)) ; mean(W_group(10:7:end,:))], [-4 4])


%% Pattern of weights for the distractors 
% memo_units_reorder = [2 4 9 10 13 3 5 7 12 15 1  6 8 11 14];
input_reorder = [27 35 43 52 60 68 28:34 36:42 44:50 53:59 61:67 69:75];
Wreord = [w_xy(input_reorder(1:3),memo_units_reorder+80)+w_xy(input_reorder(4:6),memo_units_reorder+80) ; w_xy(input_reorder(7:27),memo_units_reorder+80)+w_xy(input_reorder(28:48),memo_units_reorder+80)];

figure('Color', [1 1 1], 'Position', [70 489 912 420]);
subplot(1,3,1); plot(reshape(Wreord(11:17,1:4),1,[]), reshape(Wreord(18:24,1:4),1,[]), 'r.');
[RHO,PVAL] = corr([reshape(Wreord(11:17,1:4),[],1), reshape(Wreord(18:24,1:4),[],1)]); 
hold on; plot([-2 3], [-2*RHO(1,2) 3*RHO(1,2)], 'r'); xlim([-2 3]); ylim([-2 3]);  text(-1.5,2.7,['r = ' num2str(RHO(1,2))]); text(-1.5,2.4,['p = ' num2str(PVAL(1,2))])
subplot(1,3,2); plot(reshape(Wreord(4:10,5:9),1,[]), reshape(Wreord(18:24,5:9),1,[]), 'g.')
[RHO,PVAL] = corr([reshape(Wreord(4:10,5:9),[],1), reshape(Wreord(18:24,5:9),[],1)])
hold on; plot([-2 3], [-2*RHO(1,2) 3*RHO(1,2)], 'g'); xlim([-2 3]); ylim([-2 3]);  text(-1.5,2.7,['r = ' num2str(RHO(1,2))]); text(-1.5,2.4,['p = ' num2str(PVAL(1,2))])
subplot(1,3,3); plot(reshape(Wreord(4:10,10:15),1,[]), reshape(Wreord(11:17,10:15),1,[]), 'b.')
[RHO,PVAL] = corr([reshape(Wreord(4:10,10:15),[],1), reshape(Wreord(11:17,10:15),[],1)])
hold on; plot([-2 3], [-2*RHO(1,2) 3*RHO(1,2)], 'b'); xlim([-2 3]); ylim([-2 3]);  text(-1.5,2.7,['r = ' num2str(RHO(1,2))]); text(-1.5,2.4,['p = ' num2str(PVAL(1,2))])
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng',[PngDir 'Corr_DistractorW.png']) 



%% Weights onto Qvals
W_net = zeros(7,15);
for u=1:15
    for p=1:7
        if u<5
            distr = 11:24;
            
        elseif u>4 && u<10
            distr = [4:10 18:24];
        elseif u>9  
            distr = 4:17;
        end
        distr([p p+7])=[];
        
        W_net(p,u) = Wreord(1+(u>4)+(u>9),u)+Wreord(3+7*((u>4)+(u>9))+p,u)+sum(Wreord(distr,u))/2+w_xy(51,memo_units_reorder(u)+80)+w_xy(76,memo_units_reorder(u)+80);
    end
end

w_yz = n.weights_yz;
memo_units_reorder = [2 4 9 10 13 3 5 7 12 15 1  6 8 11 14];
%imagesc(w_yz(memo_units_reorder+80, 6:12))
Wf1 = zeros(7);
for u = 1:4
    Wf1 = Wf1+W_net(:,u) * w_yz(80+memo_units_reorder(u),6:12);
end
figure; imagesc(Wf1)

Wf2 = zeros(7);
for u = 5:9
    Wf2 = Wf2+W_net(:,u)*w_yz(80+memo_units_reorder(u),6:12);
end
figure;imagesc(Wf2)

Wf3 = zeros(7);
for u = 10:15
    Wf3 = Wf3+W_net(:,u)*w_yz(80+memo_units_reorder(u),6:12);
end
figure;imagesc(Wf3)
