function s2=stripunderscore(s);

if strfind(s,'_')
   s2 = s(1:strfind(s,'_')-1); 
else
    s2 = s;
end
    