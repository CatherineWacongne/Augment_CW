function d=AgreementNouns(d)

LoadLexicon;

%%%% PLURAL OF NOUNS
possiblelabels = {'$SINGULAR','$PLURAL'};
for i=FindInChildren(d,1,[],'_N_P0')
    i=i(1);
    b=d.children{i}(1); %%% this is the noun
    singularform = d.terminalword{b};
    
    currentnumber=intersect(possiblelabels,d.labels{b});
    numberindex = strmatch(currentnumber,possiblelabels);
    
    if numberindex==2 % plural
        inoun = strmatch(singularform,plurals{1});
        if ~isempty(inoun)
            d.terminalword{b} = plurals{2}{inoun};
        else
            d.terminalword{b}= [ singularform, 's' ];
        end
    end
end

%%%% AGREEMENT OF ADJECTIVE
if language == 2 %% French
    for i=FindInChildren(d,1,[],'_A_P0')
        i=i(1);
        b=d.children{i}(1); %%% this is the adjective
        singularform = d.terminalword{b};
        
        possiblelabels = {'$MASC','$FEMI'};
        currentnumber=intersect(possiblelabels,d.labels{b});
        numberindex = strmatch(currentnumber,possiblelabels);
        if numberindex==2 % feminine
            iadj = strmatch(singularform,feminine{1});
            if ~isempty(iadj)
                d.terminalword{b} = feminine{2}{iadj};
            else
                d.terminalword{b}= [ singularform, 'e' ];
            end
        end
        possiblelabels = {'$SINGULAR','$PLURAL'};
        currentnumber=intersect(possiblelabels,d.labels{b});
        numberindex = strmatch(currentnumber,possiblelabels);
        if numberindex==2 % plural
            iadj = strmatch(singularform,plurals{1});
            if ~isempty(iadj)
                d.terminalword{b} = plurals{2}{iadj};
            else
                d.terminalword{b}= [ singularform, 's' ];
            end
        end
    end
end

%%%% AGREEMENT OF DETERMINER
if language == 2 %% French
    for i=FindInChildren(d,1,[],'_DET')
        i=i(1);
        if d.nchildren{i}>0
            b=d.children{i}(1); %%% this is the determiner
        else
            b=i;
        end
        singularform = d.terminalword{b};
        
        possiblelabels = {'$MASC','$FEMI'};
        currentnumber=intersect(possiblelabels,d.labels{b});
        numberindex = strmatch(currentnumber,possiblelabels);
        if numberindex==2 % feminine
            iadj = strmatch(singularform,feminine{1});
            if ~isempty(iadj)
                d.terminalword{b} = feminine{2}{iadj};
            else
%                d.terminalword{b}= [ singularform, 'e' ];
            end
        end
    end
end

