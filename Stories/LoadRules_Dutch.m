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
i=i+1;r{i}.match='_CLAUSE';r{i}.subst = {'_C_SPEC' '_C_P1'};
i=i+1;r{i}.match='_C_P1';r{i}.subst = {'_C_P0' '_T_P2'};
%i=i+1;r{i}.match='_C_SPEC';r{i}.subst = {'In my opinion'};
i=i+1;r{i}.match='_C_SPEC';r{i}.subst = {'#temporaryempty'};
i=i+1;r{i}.match='_C_P0';r{i}.subst = {'#temporaryempty'};


%%% basics of XBAR theory  
%%% here _P2, _P1 and _P0 refer to the three
%%% levels of "bars" or "primes" in the XBAR structure. 
%%% So _T_P2 = TP in the classical sense, _N_P2 = NP
i=i+1;r{i}.match='_T_P2';r{i}.subst = {'_T_SPEC','_T_P1'}; 
i=i+1;r{i}.match='_T_P2';r{i}.subst = {'_T_SPEC','_T_P1'}; %% allow up to two TPs in the stimuli
%i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_L_ADJUNCT','_T_P1'}; 
%i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_P1','_T_R_ADJUNCT',}; 
i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_COMP', '_T_P0'}; 
i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_COMP', '_T_P0'}; 
%i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#empty'}; 
i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};
i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};

i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_N_SPEC','_N_P1'}; 
i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_N_SPEC','_N_P1'}; %% allow up to two NPs in the sentence
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_L_ADJUNCT','_N_P1'}; 
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_P1','_N_R_ADJUNCT',}; 
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_HUMAN_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_HUMAN_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ROLE_N_P0','_N_COMP',}; %% 
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ROLE_N_P0'}; 

i=i+1;r{i}.match='_V_P2';r{i}.subst = {'_V_SPEC','_V_P1'}; 
%i=i+1;r{i}.match='_V_P2';r{i}.subst = {'_V_SPEC','_V_P1'}; %%% allow up to two VPs, e.g. a relative sentence
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'};%% repeated to increase its frequency 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VI_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VI_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1'}; 
%i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VI_V_P1'}; 
%i=i+1;r{i}.match='_VT_V_P1';r{i}.subst = {'_VT_COMP','_VT_V_P0'}; %% different sorts of verbs take different sorts of complements
i=i+1;r{i}.match='_VT_V_P1';r{i}.subst = {'_VT_COMP','_VT_V_P0'}; %% different sorts of verbs take different sorts of complements
i=i+1;r{i}.match='_VI_V_P1';r{i}.subst = {'_VI_V_P0'}; 


i=i+1;r{i}.match='_P_P2';r{i}.subst = {'_P_SPEC','_P_P1'}; 
i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P0','_P_COMP',}; 

i=i+1;r{i}.match='_P_P2';r{i}.subst = {'_CITY_P_P1'}; 
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

i=i+1;r{i}.match='_N_L_ADJUNCT';r{i}.subst = {'_PHYSICAL_A_P2'};
i=i+1;r{i}.match='_N_R_ADJUNCT';r{i}.subst = {'_EMOTION_A_P2'};
i=i+1;r{i}.match='_V_L_ADJUNCT';r{i}.subst = {'_ADV'};
i=i+1;r{i}.match='_V_L_ADJUNCT';r{i}.subst = {'_P_P2'};


i=i+1;r{i}.match='_N_COMP';r{i}.subst = {'van_P','_PROPER'};r{i}.addi={{''},{'$GENITIVE'}};
i=i+1;r{i}.match='_VT_COMP';r{i}.subst = {'_N_P2'};r{i}.addi={{'$ACCUSATIVE'}};
%i=i+1;r{i}.match='_VM_COMP';r{i}.subst = {'_INF_T_P2'};
i=i+1;r{i}.match='_INF_T_P2';r{i}.subst = {'_INF_T_SPEC','_INF_T_P1'};
i=i+1;r{i}.match='_INF_T_SPEC';r{i}.subst = {'#PRO'};
i=i+1;r{i}.match='_INF_T_P1';r{i}.subst = {'_INF_T_P0','_V_P2'}; %r{i}.addi={{''},{'$INFINITIVE'}};
i=i+1;r{i}.match='_INF_T_P0';r{i}.subst = {'#inf'};
i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'over_P','_PROPER'};r{i}.addi={{''},{'$GENITIVE'}}; %%% only for predicates
i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'om_P','_INF_T_P2'};

i=i+1;r{i}.match='_P_COMP';r{i}.subst = {'_LOC_N_P2'}; %% simplified location PP
i=i+1;r{i}.match='_LOC_N_P2';r{i}.subst = {'de_DET','_LOCN'}; %% simplified location PP

%%% special case of proper names
i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_PROPER'}; 

%%% special case of TO BE + predicate
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_EMOTION_A_P2','_BE_V_P0'};  
i=i+1;r{i}.match='_EMOTION_A_P2';r{i}.subst = {'_A_SPEC','_EMOTION_A_P1'};
i=i+1;r{i}.match='_EMOTION_A_P1';r{i}.subst = {'_EMOTION_A_P0'};
i=i+1;r{i}.match='_EMOTION_A_P1';r{i}.subst = {'_EMOTION_A_P0','_A_COMP'};
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_PHYSICAL_A_P2','_BE_V_P0'};  
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
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'net'};
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'recht'};

i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'erg'}; %%% 
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'echt'};
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'heel'};

i=i+1;r{i}.match='_ADV';r{i}.subst = {'vaak'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'altijd'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'echt'};

%%% for verbs, we always put the infinitive form


i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'slapen'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'zingen'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'huilen'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'rennen'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'werken'};
 
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'kussen'}; 
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'ontmoeten'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'zien'}; 
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'slaan'}; 
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'helpen '}; 


i=i+1;r{i}.match='_BE_V_P0';r{i}.subst = {'zijn'};

i=i+1;r{i}.match='_DET';r{i}.subst = {'#empty'}; r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'een'}; r{i}.addi={{'$SINGULAR'}};

i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#future'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#perfect'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#present'};  
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#past'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#might'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#should'};

i=i+1;r{i}.match='_NUM';r{i}.subst = {'twee'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'vijf'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'tien'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'elf'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'sommige'};r{i}.addi={{'$PLURAL'}};

i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Barack_FIRSTNAME','Obama_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Bill_FIRSTNAME','Gates_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'George_FIRSTNAME','Bush_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'John_FIRSTNAME','Lennon_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Marylin_FIRSTNAME','Monroe_LASTNAME'};r{i}.addi={{'$SINGULAR','$FEMI'},{'$SINGULAR','$FEMI'}};

i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'zuster'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'jongen'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'vrouw'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'bakker'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'kindje'};r{i}.addi={{'$NEUTER'}};

i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'hulp'};r{i}.addi={{'$MASC'}}; 
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'student'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'fan'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'bewonderaar'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'minnares'};r{i}.addi={{'$FEMI'}};

i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'verdrietig'}; %%% TODO 
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'blij'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'boos'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'tevreden'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'nerveus'};

i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'dun'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'klein'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'dik'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'lang'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'gek'};

i=i+1;r{i}.match='_P_P0';r{i}.subst = {'op'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'onder'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'naast'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'achter'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'voor'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'in'};

i=i+1;r{i}.match='_LOCN';r{i}.subst = {'bed'};r{i}.addi={{'$NEUTER'}};
i=i+1;r{i}.match='_LOCN';r{i}.subst = {'brug'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_LOCN';r{i}.subst = {'boom'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_LOCN';r{i}.subst = {'huis'};r{i}.addi={{'$NEUTER'}};
i=i+1;r{i}.match='_LOCN';r{i}.subst = {'tafel'};r{i}.addi={{'$MASC'}};

i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'New York'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Paris'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Tokyo'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Berlin'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Toulouse'};

%%i=i+1;r{i}.match='';r{i}.subst = {''};
