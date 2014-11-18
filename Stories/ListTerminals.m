function [ wordlist nodelist ] = ListTerminals(s,i,wordlist,nodelist)
%%%% this is a recursively called function that counts the terminal
%%%% node values and labels

if (s.nchildren{i}==0)
    if (~strcmp(s.node{i}(1),'_'))&&(~strcmp(s.terminalword{i}(1),'#'))   %% definition of a terminal node
        iprev = length(wordlist);
        
        compound = false;
        if (iprev>0)
            if strcmp(wordlist{iprev}(end),'''')
                compound = true;
            end
        end
        
        if compound
            %%%% special case of words with an apostrophy: group them
            wordlist{iprev} = [wordlist{iprev} s.terminalword{i} ];
            nodelist{iprev} = [ nodelist{iprev} ,  i ] ;
        else
            wordlist{iprev+1} = s.terminalword{i};
            nodelist{iprev+1} = i ;
        end
    end
else
    for inode = s.children{i}
        [ wordlist nodelist] = ListTerminals(s,inode,wordlist,nodelist);
    end
end