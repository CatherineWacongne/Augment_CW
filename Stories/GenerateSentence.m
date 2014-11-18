function s = GenerateSentence(r,minlength,maxlength);
%%%%% generate a sentence s, based on the rules r

verbose = 0;  %% turn to 1 to see all of the temporarily generated structures

nrules = length(r);

%% initialize the rules
max_uses=ones(1,nrules);
% initialize the first node
s.node{1}=r{1}.match;  %%% start with the top-most item in the rules
s.satis{1}=0; % not yet satisfied
s.labels{1}={};

%%% apply successive rules until all nodes are satisfied with the
%%% appropriate children
nonsatis = 1;
totnode=1; %%% total number of nodes
while nonsatis>0;
    %%% find the first non-satisfied node
    for inode = 1:length(s.node)
        if s.satis{inode}==0
            break
        end
    end
    
    if strcmp(s.node{inode},'aga') %% track a specific problematic word
        verbose = 1;
        DisplayAllNodes(s,1);
    end
    
    %%%% examine the rules in random order, find the first match
    p=randperm(nrules);
    findmatch = 0;
    for irule2 = 1:nrules
        irule = p(irule2);  %%% random permutation
        if (strcmp(s.node{inode},r{irule}.match)) && (max_uses(irule)>0)
            findmatch = 1;
            break;
        end
    end
    
    if findmatch
        %%%%% apply the rule that was found
        if verbose
            disp(r{irule});
        end
        max_uses(irule) = max_uses(irule) -1;
        s.satis{inode}=1;  %%% the current node is now satisfied
        s.nchildren{inode} = length(r{irule}.subst);
        %%% create all children and link them to the current node
        for ichild = 1:s.nchildren{inode}
            totnode = totnode +1;
            s.children{inode}(ichild)=totnode;
            s.node{totnode} = r{irule}.subst{ichild};
            s.nchildren{totnode} = 0; %%% temporarily set the number of children to zero -- will be overriden if needed
            if strcmp(s.node{totnode}(1),'_')  %%% non terminal node
                s.satis{totnode} = 0;
            else
                %%% terminal node
                s.satis{totnode} = 1;
                s.terminalword{totnode} = stripunderscore(s.node{totnode});
            end
            %%%% now prepare the list of additional labels
            try
                s.labels{totnode} = r{irule}.addi{ichild};
            catch
                s.labels{totnode} = {};
            end
        end
        
        %%% check the number of non-satisfied nodes
        nonsatis = 0;
        for inode = 1:length(s.node)
            if s.satis{inode}==0
                nonsatis = nonsatis + 1;
            end
        end
    end
    
    %%%% do we need to restart the search for a valid sentence?
    reset_all = 0;
    if (~findmatch)
        % disp(sprintf('no remaining matching rule for  %s -- start again',s.node{inode}));
        reset_all = 1;
    end
    leng = CountTrueTerminals(s,1);
    if (leng>maxlength)
        % disp('Maximum number of words attained -- start again');
        reset_all = 1;
    end
    if (nonsatis==0)&&(leng<minlength)
        % disp('Minimum number of words not attained -- start again');
        reset_all = 1;
    end
    if reset_all
        clear s;
        %% initialize the rules
        max_uses=ones(1,nrules);
        % reinitialize the first node
        s.node{1}=r{1}.match;  %%% start with the top-most item in the rules
        s.satis{1}=0; % not yet satisfied
        
        %%% apply successive rules until all nodes are satisfied with the
        %%% appropriate children
        nonsatis = 1;
        totnode=1; %%% total number of nodes
    end
end