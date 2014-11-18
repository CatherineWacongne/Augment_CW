%%%% display statistics of word and label counts
clear countstruct
countstruct.labelname = {};
LoadRules;

%%%% initialize with the names present in the rules
for j = 1:length(r)
    allitems = union( r{j}.match,r{j}.subst);
    for k= 1:length(allitems)
        name = allitems{k};
        nlab = length(countstruct.labelname);
        foundit = nlab+1;
        for k = 1:nlab
            if strcmp(countstruct.labelname{k},name)
                foundit = k;
            end
        end
        if foundit <= nlab
        else
            countstruct.labelname{foundit}=name;
            countstruct.count(foundit)=0;
        end
    end
end

disp('**********************************************************************');
disp('Count how many times a given word or label is present in the sentences');
disp('**********************************************************************');

for isent = 1:nsentences
    %%%% count words and labels
    countstruct = CountAllLabels(surface{isent},1,countstruct);
    countstruct = CountAllLabels(shortened{isent},1,countstruct);
end
[csc,i]=sort(countstruct.count);
for j=1:length(countstruct.labelname)
    s=sprintf('%25s:  %4d',countstruct.labelname{i(j)},countstruct.count(i(j)));
    disp(s);
end

disp('**************************************');
disp('Statistics of sentence and word length');
disp('**************************************');
for ii = 1:2
    sentlength = zeros(1,12);
    for isent=1:nsentences
        if ii==1
            [ wordlist{isent,ii} nodelist{isent,ii} ] = ListTerminals(surface{isent},1,{},{});
        else
            [ wordlist{isent,ii} nodelist{isent,ii} ] = ListTerminals(shortened{isent},1,{},{});
        end
        %disp(wordlist{isent,ii});
        leng = length(wordlist{isent,ii});
        sentlength(leng) = sentlength(leng) + 1;
    end
    disp(sentlength);
end
