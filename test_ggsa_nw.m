% Makes a plot like figure 2c.

function [net_success, input_acts, hidden_acts,q_acts, fig_hnd, pretty ] = test_ggsa_nw(nw) 


  pretty = false;
  trial_type_labels = {'P-L','P-R','A-L','A-R'};
  trial_types = [1 0; 1 1; 2 0; 2 1]; % p-l;p-r;a-l;a-r

  input_acts = zeros(size(trial_types,1), 50, nw.n_inputs*3);
  hidden_acts = zeros(size(trial_types,1), 50,nw.ny);
  q_acts = zeros(size(trial_types,1), 50, nw.nz);

  trial_ends = zeros(size(trial_types,1),1);        

  % Number of tests
  seed = 1;
  net_success = true;
  
  % for experiments, fix the random generator:
  rnd_stream = RandStream('mt19937ar','Seed', seed);
  RandStream.setDefaultStream(rnd_stream);

    % Stop learning; set to completely greedy strategy
    nw.beta = 0;

    nw.exploit_prob = 1;
    nw.resetTraces();
    nw.previous_qa = 0;
    nw.delta = 0;

    % Test network on all trial-types
    for i = 1:size(trial_types,1)

      epoch = 1;

      % Task Settings:
      t = GGSATask();
      t.only_pro = false;

      t.setTrialType(trial_types(i,2), trial_types(i,1));
      nw.resetTraces();
      nw.previous_qa = 0;
      nw.delta = 0;

      new_input = t.nwInput;
      reward = 0;
      trialend = false;


      while(true)
        %%% Update Network 
          [action] = nw.doStep(new_input,reward, trialend);


          input_acts(i,epoch, :) =  nw.X';
          hidden_acts(i,epoch,:) = nw.Y';
          q_acts(i,epoch,:) = nw.qas';


        if (trialend)
          t.stateReset();
          trial_ends(i) = epoch;

           if (reward ~= 1.5)
            net_success = false;
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


    %% PRR-style plot (separate graphs for all conditions)
    
    % Indices of hidden units to plot
    hdns = [1,2,3,4,5,6,7];
    %hdns = [3,5,6];

        
    fig_hnd = figure(10);
    j_max = size(hdns,2)+1;
    subhs = zeros(j_max,4);
    subhs_idc =  zeros(j_max,4);
    for i = 1:4
      for j = 1:j_max
       subhs(j,i) = subplot(j_max,4, (j - 1) * 4 + i );
       subhs_idc(j,i) = (j - 1) * 4 + i;
       set(subhs(j,i),'NextPlot','add');
      end
    end
    
    colors = ['g','y','c','k','r','m','b' ];
    
    % Plot association layer unit activations (3 (no) x 4 (conditions))
    for i = 1:4
      for j = 1:(j_max-1)
        area(subhs(j,i),  squeeze(hidden_acts(i,1:trial_ends(i), hdns(j))), 'FaceColor', colors(j), 'EdgeColor', colors(j) );
        axis(subhs(j,i),[1,8,0,1]);
      end
    end
    
    for i = 1:4
      plot(subhs(j_max,i), squeeze(q_acts(i,1:trial_ends(i), :)));
      axis(subhs(j_max,i),[1,8,0,1.75]);
    end
    

   
    for i = 1:4
      for j = 1:j_max
       set(subhs(j,i),'XTickLabel',[]);
       set(subhs(j,i),'XTick',event_idxes);
      
      
      if (j == j_max)
        set(subhs(j,i),'XTickLabel',xlabels);
      end
      
      if (i ~= 1)
        set(subhs(j,i),'YTickLabel',[]);
      end
      
      if(i == 1)
        if (j == j_max)
          ylabel(subhs(j,i),'Q');
        else
          ylabel(subhs(j,i),'Assoc.');
        end
       end
      end
       
    end

end
  
