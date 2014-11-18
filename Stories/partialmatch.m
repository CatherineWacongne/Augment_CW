function s=partialmatch(str,strarray)
%%%% finds the first element of strarray that contains str

s='';
for i=1:length(strarray)
    if strfind(str,strarray{i})
        s=strarray(i);
        break;
    end
end