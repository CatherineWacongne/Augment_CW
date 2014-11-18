%%%%% substitution rules for a simple language

%%% by convention:
%%% each line in the rule matrix r codes for a matching rule of the type: match-->subst
%%% where "match" is a node type and "subst" are its children nodes.
%%% Children can have additional properties which are indicated in the
%%% optional field "addi".
%%%  _ indicates a non-terminal item (the program knows that it should
%%%  continue to expand these nodes, and that if it can't find a match, the
%%%  sentence will be ill-formed)
%%%  # indicates a special, phonologically empty or bound morpheme
%%%  $ indicates additional properties case, number, gender 
%%%  all other items are terminal words

clear r;
i=0;
%%% _CLAUSE is the start symbol
i=i+1;r{i}.match='_CLAUSE';r{i}.subst = {'_T_P2'};

%%% basics of XBAR theory  
%%% here _P2, _P1 and _P0 refer to the three
%%% levels of "bars" or "primes" in the XBAR structure. 
%%% So _T_P2 = TP in the classical sense, _N_P2 = NP
i=i+1;r{i}.match='_T_P2';r{i}.subst = {'_T_SPEC','_T_P1'}; 
i=i+1;r{i}.match='_T_P2';r{i}.subst = {'_T_SPEC','_T_P1'}; %% allow up to two TPs in the stimuli
%i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_L_ADJUNCT','_T_P1'}; 
%i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_P1','_T_R_ADJUNCT',}; 
i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_P0','_T_COMP'}; 
i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_P0','_T_COMP'}; 

i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_N_SPEC','_N_P1'}; 
i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_N_SPEC','_N_P1'}; %% allow up to two NPs in the sentence
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_L_ADJUNCT','_N_P1'}; 
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_L_ADJUNCT','_N_P1'}; 
%i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_P1','_N_R_ADJUNCT',}; 
%i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ANIMAL_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_HUMAN_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_HUMAN_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ROLE_N_P0','_N_COMP',}; %% 
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ROLE_N_P0'}; 

i=i+1;r{i}.match='_V_P2';r{i}.subst = {'_V_SPEC','_V_P1'}; 
i=i+1;r{i}.match='_V_P2';r{i}.subst = {'_V_SPEC','_V_P1'}; %%% allow up to two VPs, e.g. a relative sentence
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; %% repeated to increase its frequency
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VM_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VM_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1','_V_R_ADJUNCT',}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1','_V_R_ADJUNCT',}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VI_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VI_V_P1','_V_R_ADJUNCT',}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VI_V_P1','_V_R_ADJUNCT',}; 
i=i+1;r{i}.match='_VT_V_P1';r{i}.subst = {'_VT_V_P0','_VT_COMP',}; %% different sorts of verbs take different sorts of complements
i=i+1;r{i}.match='_VM_V_P1';r{i}.subst = {'_VM_V_P0','_VM_COMP',}; 
i=i+1;r{i}.match='_VI_V_P1';r{i}.subst = {'_VI_V_P0'}; 

i=i+1;r{i}.match='_A_P2';r{i}.subst = {'_A_SPEC','_A_P1'}; 
i=i+1;r{i}.match='_A_P2';r{i}.subst = {'_A_SPEC','_A_P1'}; 
%i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_L_ADJUNCT','_A_P1'}; 
%i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P1','_A_R_ADJUNCT',}; 
i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P0'}; % no complementizer for adjectives that qualify nouns
i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P0'}; % no complementizer for adjectives that qualify nouns

i=i+1;r{i}.match='_P_P2';r{i}.subst = {'_P_SPEC','_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_L_ADJUNCT','_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P1','_P_R_ADJUNCT',}; 
i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P0','_P_COMP',}; 

i=i+1;r{i}.match='_P_P2';r{i}.subst = {'_CITY_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_L_ADJUNCT','_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P1','_P_R_ADJUNCT',}; 
i=i+1;r{i}.match='_CITY_P_P1';r{i}.subst = {'in_P_P0','_CITY_P_COMP',}; 

%%% more specific determination of possible SPECs, _ADJUNCTS and COMPs

i=i+1;r{i}.match='_T_SPEC';r{i}.subst = {'_N_P2'};r{i}.addi={{'$NOMINATIVE'}};
i=i+1;r{i}.match='_T_SPEC';r{i}.subst = {'_N_P2'};r{i}.addi={{'$NOMINATIVE'}};%%% allow up to two TPs in the sentence
i=i+1;r{i}.match='_N_SPEC';r{i}.subst = {'_DET'};
i=i+1;r{i}.match='_N_SPEC';r{i}.subst = {'_NUM'};
i=i+1;r{i}.match='_V_SPEC';r{i}.subst = {'#empty'};
i=i+1;r{i}.match='_V_SPEC';r{i}.subst = {'#empty'};
i=i+1;r{i}.match='_V_SPEC';r{i}.subst = {'#empty'}; %% duplicated to allow multiple TPs
i=i+1;r{i}.match='_A_SPEC';r{i}.subst = {'_DEGREE'};
i=i+1;r{i}.match='_P_SPEC';r{i}.subst = {'_INTENSIF'};

i=i+1;r{i}.match='_N_L_ADJUNCT';r{i}.subst = {'_A_P2'};
i=i+1;r{i}.match='_N_L_ADJUNCT';r{i}.subst = {'_A_P2'};
%i=i+1;r{i}.match='_N_R_ADJUNCT';r{i}.subst = {'_P_P2'};
%i=i+1;r{i}.match='_N_R_ADJUNCT';r{i}.subst = {'who','_T_P1'};
i=i+1;r{i}.match='_V_L_ADJUNCT';r{i}.subst = {'_ADV'};
i=i+1;r{i}.match='_V_R_ADJUNCT';r{i}.subst = {'_P_P2'};

i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};
i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};
i=i+1;r{i}.match='_N_COMP';r{i}.subst = {'of_P','_PROPER'};r{i}.addi={{''},{'$GENITIVE'}};
i=i+1;r{i}.match='_VT_COMP';r{i}.subst = {'_N_P2'};r{i}.addi={{'$ACCUSATIVE'}};
i=i+1;r{i}.match='_VM_COMP';r{i}.subst = {'_INF_T_P2'};
i=i+1;r{i}.match='_INF_T_P2';r{i}.subst = {'_INF_T_SPEC','_INF_T_P1'};
i=i+1;r{i}.match='_INF_T_SPEC';r{i}.subst = {'#PRO'};
i=i+1;r{i}.match='_INF_T_P1';r{i}.subst = {'_INF_T_P0','_V_P2'}; %r{i}.addi={{''},{'$INFINITIVE'}};
i=i+1;r{i}.match='_INF_T_P0';r{i}.subst = {'to_#inf'};
%i=i+1;r{i}.match='_VM_COMP';r{i}.subst = {'that','_CLAUSE'};
i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'about_P','_N_P2'};r{i}.addi={{''},{'$GENITIVE'}}; %%% only for predicates
i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'_INF_T_P2'};
%OLDSTUFF i=i+1;r{i}.match='_to_T_P2';r{i}.subst = {'_to_T_SPEC','_to_T_P1'}; 
%i=i+1;r{i}.match='_to_T_SPEC';r{i}.subst = {'#emptysubj'};
%i=i+1;r{i}.match='_to_T_P1';r{i}.subst = {'to_T_P0','_T_COMP'}; 

i=i+1;r{i}.match='_P_COMP';r{i}.subst = {'_LOC_N_P2'}; %% simplified location PP
%i=i+1;r{i}.match='_LOC_N_P2';r{i}.subst = {'the_DET','_LOCN'}; %% simplified location PP
i=i+1;r{i}.match='_LOC_N_P2';r{i}.subst = {'the_DET','_LOC_N_P0'}; %% simplified location PP

%%% special case of proper names
i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_PROPER'}; 

%%% special case of TO BE + predicate
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_BE_V_P0','_EMOTION_A_P2'};  
i=i+1;r{i}.match='_EMOTION_A_P2';r{i}.subst = {'_A_SPEC','_EMOTION_A_P1'};
i=i+1;r{i}.match='_EMOTION_A_P1';r{i}.subst = {'_EMOTION_A_P0','_A_COMP'};
i=i+1;r{i}.match='_EMOTION_A_P1';r{i}.subst = {'_EMOTION_A_P0'};
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_BE_V_P0','_PHYSICAL_A_P2'};  
i=i+1;r{i}.match='_PHYSICAL_A_P2';r{i}.subst = {'_A_SPEC','_PHYSICAL_A_P1'};
i=i+1;r{i}.match='_PHYSICAL_A_P1';r{i}.subst = {'_PHYSICAL_A_P0'};

%i=i+1;r{i}.match='';r{i}.subst = {''};

%%% word categories

i=i+1;r{i}.match='_A_P0';r{i}.subst = {'_EMOTION_A_P0'};
i=i+1;r{i}.match='_A_P0';r{i}.subst = {'_PHYSICAL_A_P0'};
i=i+1;r{i}.match='_A_P0';r{i}.subst = {'_PHYSICAL_A_P0'};

%%% terminals
%%% words are frequent and short (max 8 letters, usually much less)

i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'#empty'}; %% intensifiers can be omitted
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'#empty'}; %% intensifiers can be omitted
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'#empty'}; %% intensifiers can be omitted
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'right'};
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'just'};
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'straight'};

i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'very'}; %%% 
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'really'};
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'rather'};

i=i+1;r{i}.match='_ADV';r{i}.subst = {'often'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'always'};
%i=i+1;r{i}.match='_ADV';r{i}.subst = {'also'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'really'};

%%% for verbs, we always put the infinitive form
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'sleep'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'sing'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'run'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'shout'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'work'};

i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'kiss'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'help'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'watch'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'attack'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'meet'};

i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'like'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'love'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'prefer'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'hate'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'want'};

i=i+1;r{i}.match='_BE_V_P0';r{i}.subst = {'be'};

i=i+1;r{i}.match='_DET';r{i}.subst = {'the'}; r{i}.addi={{'$UNSPECIFIED'}};%%%% singular or plural will be determined by a special function 
%i=i+1;r{i}.match='_DET';r{i}.subst = {'#empty'}; r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'a'}; r{i}.addi={{'$SINGULAR'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'those'}; r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'this'}; r{i}.addi={{'$SINGULAR'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'these'}; r{i}.addi={{'$PLURAL'}};

i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#future'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#perfect'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#present'};  %% aux can be omitted but signal present or past -- special case!
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#past'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#might'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#should'};

i=i+1;r{i}.match='_NUM';r{i}.subst = {'two'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'five'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'ten'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'many'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'some'};r{i}.addi={{'$PLURAL'}};

i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Barack_FIRSTNAME','Obama_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Bill_FIRSTNAME','Gates_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'George_FIRSTNAME','Bush_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'John_FIRSTNAME','Lennon_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Marylin_FIRSTNAME','Monroe_LASTNAME'};r{i}.addi={{'$SINGULAR','$FEMI'},{'$SINGULAR','$FEMI'}};

% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'lion'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'dog'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'whale'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'bird'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'snake'};

i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'nurse'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'boy'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'woman'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'dancer'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'child'};r{i}.addi={{'$MASC'}};

i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'aid'};r{i}.addi={{'$MASC'}}; %%% default is masculine
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'student'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'fan'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'admirer'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'lover'};r{i}.addi={{'$MASC'}};

i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'sad'}; %%% all of these adjective can be followed by a complement "of X"
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'proud'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'happy'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'scared'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'fearful'};

i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'tired'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'small'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'fat'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'tall'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'sick'};

i=i+1;r{i}.match='_P_P0';r{i}.subst = {'on'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'below'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'above'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'under'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'behind'};

i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'bridge'};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'roof'};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'tree'};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'stage'};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'arch'};

i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Chicago'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Paris'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Tokyo'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Dallas'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'San Diego'};

%%i=i+1;r{i}.match='';r{i}.subst = {''};
