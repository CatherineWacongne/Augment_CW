function d=DeepToSurface(s);

d=s; %% start with current sentence;

d=CorrectCaseNumberGender(d);

%% mark agreement of subject and verb
d=CorrectVerb(d);

%% conjugate the verb adequately
d=ConjugateVerb(d,1);

%% mark the plurals and genders correctly
d=AgreementNounAdjDet(d);

%% remove empty branches
d=RemoveEmpty(d,1);

%% move words if needed
d=MoveWords(d);

%% clean-up phonological particulars e.g. a-->an, etc
d=PhonologicalCleanup(d);

%% prepare the additional terminal "labels" for a future analysis of activation induced by each word
%d=PrepareAnalysisLabels(d,1,{});

