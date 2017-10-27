% test for generalization
Date = '3_';
load resultsCTDeep_3.mat
t = CTTask;
t.mem_dur = 0;
t.active_tracing = 0;
t.distr_curve_on =1;
t.turnoff_fp =0;
n.beta = 0;
n.exploit_prob = 1;
new_input = zeros(1,n.nx);
reward = 0;
trialend = 0;
SaveDir = 'C:\Users\wacongne\Documents\PostDoc\Modeling\AuGMEnT_Matlab\Figures_CT\';

close all
%%
for length = 3:8
    curve_length = length;
    time_steps = 8+length;
    trials = 100;
%     npop = 
    t.curve_length = curve_length;
    fp_activations =  zeros(trials, time_steps, npop);
    mod_target_activations = zeros(trials, time_steps, curve_length,3);
    mod_distr_activations =  zeros(trials, time_steps, curve_length,3);
    hid_target_activations = zeros(trials, time_steps, curve_length,3);
    hid_distr_activations =  zeros(trials, time_steps, curve_length,3);
    Q_target_activation = zeros(trials, time_steps, curve_length);
    Q_distr_activation = zeros(trials, time_steps, curve_length);
    
    %%
    success = 0;
    for tr = 1:trials
        
        for i = 1:time_steps
            [action] = n.doStep(new_input,reward, trialend);
            [new_input, reward, trialend] = t.doStep(action);
            modul = reshape(n.Xmod(2:end),n.grid_size,n.grid_size,3);
            hidden = cat(2,n.Y1{:}); hidden([1 n.ny+1 n.ny*2+1]) = [];hidden = reshape(hidden, n.grid_size,n.grid_size,3);
            Q = reshape(n.qas(2:end),n.grid_size,n.grid_size);
            for c = 1:3
                modul_c = modul(:,:,c);
                hidden_c = hidden(:,:,c);
                mod_target_activations(tr,i,:,c) = modul_c(t.trialTarget);
                mod_distr_activations(tr,i,:,c) = modul_c(t.trialDistr);
                hid_target_activations(tr,i,:,c) = hidden_c(t.trialTarget);
                hid_distr_activations(tr,i,:,c) = hidden_c(t.trialDistr);
            end
            Q_target_activation(tr,i,:) = Q(t.trialTarget);
            Q_distr_activation(tr,i,:) = Q(t.trialDistr);
            if trialend
                if reward>0.7
                    success = success+1;
                end
                break
            end
        end
    end
    
    %%
    
    mod_target_activations = sum(mod_target_activations,4);
    mod_distr_activations = sum(mod_distr_activations,4);
    mean_targactiv = squeeze(mean(mod_target_activations,1));
    mean_distractiv = squeeze(mean(mod_distr_activations,1));
    
    figure; plot(mean_targactiv-mean_distractiv)
    Colororder = [.8 0 0];
    for p = 1:curve_length-2
        Colororder = [Colororder;0 1-p*(.7/curve_length) 0];
    end
    Colororder = [Colororder;0 0 1];
    set(gca, 'ColorOrder', Colororder, 'NextPlot', 'replacechildren');
    plot(mean_targactiv-mean_distractiv); title(['Evolution of modulated units activity for Lenght ' num2str(curve_length) ' curves']); ylabel('target curve - distractor curve activ'); xlabel('time steps');
    set(gcf,'PaperPositionMode','auto')
    print(gcf,'-dpng',[SaveDir Date 'ModActivL' num2str(curve_length) '.png'])
    
    if curve_length>=4
        figure;
    subplot(1,2,1); plot(mean_targactiv(:,2)); hold on; plot(mean_distractiv(:,2));legend('target', 'distractor'); title('Pos 2')
    subplot(1,2,2); plot(mean_targactiv(:,4)); hold on; plot(mean_distractiv(:,4)); title('Pos 4')
    set(gcf,'PaperPositionMode','auto')
    print(gcf,'-dpng',[SaveDir Date 'ModActivfTL' num2str(curve_length) '.png'])
    end
    
    mean_hidtarg = squeeze(mean(hid_target_activations,1));
    mean_hiddistr = squeeze(mean(hid_distr_activations,1));
    figure('Position', [100 100 1000 700]);
    for i=1:3
        subplot(2,2,i);  plot(mean_hidtarg(:,:,i)-mean_hiddistr(:,:,i))
        set(gca, 'ColorOrder', Colororder, 'NextPlot', 'replacechildren');
        plot(mean_hidtarg(:,:,i)-mean_hiddistr(:,:,i)); title(['Evolution of hidden units activity for Lenght ' num2str(curve_length) ' curves']); ylabel('target curve - distractor curve activ'); xlabel('time steps');
        
    end
    set(gcf,'PaperPositionMode','auto')
    print(gcf,'-dpng',[SaveDir Date 'HidActivL' num2str(curve_length) '.png'])
    %
    mean_Qtarg = squeeze(mean(Q_target_activation,1));
    mean_Qdistr = squeeze(mean(Q_distr_activation,1));
    figure; plot(mean_Qtarg-mean_Qdistr);
    set(gca, 'ColorOrder', Colororder, 'NextPlot', 'replacechildren');
    plot(mean_Qtarg-mean_Qdistr); title(['Evolution of q-units activity for Lenght ' num2str(curve_length) ' curves. Success ' num2str(success/tr*100) '%']); ylabel('target curve - distractor curve activ'); xlabel('time steps');
    set(gcf,'PaperPositionMode','auto')
    print(gcf,'-dpng',[SaveDir Date 'QActivL' num2str(curve_length) '.png'])
    
    figure; plot(mean_Qtarg);
    set(gca, 'ColorOrder', Colororder, 'NextPlot', 'replacechildren');
    plot(mean_Qtarg); title(['Evolution of q-units activity for Lenght ' num2str(curve_length) ' curves. Success ' num2str(success/tr*100) '%']); ylabel('target curve activ'); xlabel('time steps');
    set(gcf,'PaperPositionMode','auto')
    print(gcf,'-dpng',[SaveDir Date 'TargQActivL' num2str(curve_length) '.png'])
    
end
