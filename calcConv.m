function [converged, c_epoch, mean_ctime, stdev_ctime] = calcConv(results, perc_check)

  windowsize = 100;
  
 
  
  runs = size(results,1);
  converged = zeros(size(results,1),1);
  c_epoch = zeros(size(results,1),1);
  
  for run = 1:runs
    
    
    tmp_res = results(run,:);
    
    % throw away unused slots:
    last_idx = find(tmp_res == 0,1,'first');
    
    tmp_res((last_idx-1):end) = [];
    
    % 10% of total completed trials
    begin_check =  floor(size(tmp_res,2) - (size(tmp_res,2) * perc_check));
    
    % Failed trials are marked with -1, Succesful trials with 1;
    % To calculate average, mark failed trials with 0;
    tmp_res(tmp_res == -1) = 0;

    % Filter results:
    filtered = filter(ones(1,windowsize)/windowsize,1,tmp_res);

    if (mean(filtered(begin_check:end)) >= 0.9)
      converged(run) = 1;
      c_epoch(run) = find(filtered > 0.9 , 1);
    else
      converged(run) = 0;
      c_epoch(run) = -1;
    end
  
  end
  
  % Print mean c-epoch, std c-epoch
  c_idxs = find(converged);
  mean_ctime = mean(c_epoch(c_idxs));
  stdev_ctime = std(c_epoch(c_idxs));
  
%   fprintf('%.2f\n',median(c_epoch(c_idxs)))
%   fprintf('%.2f (%.2f)', mean(c_epoch(c_idxs)), std(c_epoch(c_idxs)));

  
  
end