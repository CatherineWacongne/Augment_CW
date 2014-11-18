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
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_P1','_N_R_ADJUNCT',}; 
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
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_V_L_ADJUNCT','_V_P1'};%% repeated to increase its frequency 
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

% i=i+1;r{i}.match='_A_P2';r{i}.subst = {'_A_SPEC','_A_P1'}; 
% i=i+1;r{i}.match='_A_P2';r{i}.subst = {'_A_SPEC','_A_P1'}; 
% %i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_L_ADJUNCT','_A_P1'}; 
% %i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P1','_A_R_ADJUNCT',}; 
% i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P0'}; % no complementizer for adjectives that qualify nouns
% i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P0'}; % no complementizer for adjectives that qualify nouns

i=i+1;r{i}.match='_P_P2';r{i}.subst = {'_P_SPEC','_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_L_ADJUNCT','_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P1','_P_R_ADJUNCT',}; 
i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P0','_P_COMP',}; 

i=i+1;r{i}.match='_P_P2';r{i}.subst = {'_CITY_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_L_ADJUNCT','_P_P1'}; 
%i=i+1;r{i}.match='_P_P1';r{i}.subst = {'_P_P1','_P_R_ADJUNCT',}; 
i=i+1;r{i}.match='_CITY_P_P1';r{i}.subst = {'à_P_P0','_CITY_P_COMP',}; 

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
%i=i+1;r{i}.match='_N_R_ADJUNCT';r{i}.subst = {'_P_P2'};
%i=i+1;r{i}.match='_N_R_ADJUNCT';r{i}.subst = {'qui','_T_P1'};
i=i+1;r{i}.match='_V_L_ADJUNCT';r{i}.subst = {'_ADV'};
i=i+1;r{i}.match='_V_R_ADJUNCT';r{i}.subst = {'_P_P2'};

i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};
i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};
i=i+1;r{i}.match='_N_COMP';r{i}.subst = {'de_P','_PROPER'};r{i}.addi={{''},{'$GENITIVE'}};
i=i+1;r{i}.match='_VT_COMP';r{i}.subst = {'_N_P2'};r{i}.addi={{'$ACCUSATIVE'}};
i=i+1;r{i}.match='_VM_COMP';r{i}.subst = {'_INF_T_P2'};
i=i+1;r{i}.match='_INF_T_P2';r{i}.subst = {'_INF_T_SPEC','_INF_T_P1'};
i=i+1;r{i}.match='_INF_T_SPEC';r{i}.subst = {'#PRO'};
i=i+1;r{i}.match='_INF_T_P1';r{i}.subst = {'_INF_T_P0','_V_P2'}; %r{i}.addi={{''},{'$INFINITIVE'}};
i=i+1;r{i}.match='_INF_T_P0';r{i}.subst = {'#inf'};
%i=i+1;r{i}.match='_VM_COMP';r{i}.subst = {'qui','_CLAUSE'};
%i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'de_P','_N_P2'};r{i}.addi={{''},{'$GENITIVE'}}; %%% only for predicates
%% suppressed in French, because it creates many problems with "de le", "de les" etc.
i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'de_P','_PROPER'};r{i}.addi={{''},{'$GENITIVE'}}; %%% only for predicates
i=i+1;r{i}.match='_A_COMP';r{i}.subst = {'de_P','_INF_T_P2'};
%OLDSTUFF i=i+1;r{i}.match='_to_T_P2';r{i}.subst = {'_to_T_SPEC','_to_T_P1'}; 
%i=i+1;r{i}.match='_to_T_SPEC';r{i}.subst = {'#emptysubj'};
%i=i+1;r{i}.match='_to_T_P1';r{i}.subst = {'to_T_P0','_T_COMP'}; 

i=i+1;r{i}.match='_P_COMP';r{i}.subst = {'_LOC_N_P2'}; %% simplified location PP
%i=i+1;r{i}.match='_LOC_N_P2';r{i}.subst = {'le_DET','_LOCN'}; %% simplified location PP 
i=i+1;r{i}.match='_LOC_N_P2';r{i}.subst = {'le_DET','_LOC_N_P0'}; %% simplified location PP

%%% special case of proper names
i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_PROPER'}; 

%%% special case of TO BE + predicate
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_BE_V_P0','_EMOTION_A_P2'};  
i=i+1;r{i}.match='_EMOTION_A_P2';r{i}.subst = {'_A_SPEC','_EMOTION_A_P1'};
i=i+1;r{i}.match='_EMOTION_A_P1';r{i}.subst = {'_EMOTION_A_P0'};
i=i+1;r{i}.match='_EMOTION_A_P1';r{i}.subst = {'_EMOTION_A_P0','_A_COMP'};
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
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'juste'};
i=i+1;r{i}.match='_INTENSIF';r{i}.subst = {'pile'};

i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'#empty'}; %%% degrees can be omitted
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'très'}; %%% 
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'vraiment'};
i=i+1;r{i}.match='_DEGREE';r{i}.subst = {'assez'};

i=i+1;r{i}.match='_ADV';r{i}.subst = {'souvent'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'toujours'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'aussi'};
i=i+1;r{i}.match='_ADV';r{i}.subst = {'parfois'};

%%% for verbs, we always put the infinitive form
%%%% ATTENTION !! FRENCH VERBS should not start with a vowel, for fear of d' (apostrophe)
%%% and the first two categories of verbs should be "voluntary" action verbs
%%% (replaceable by "faire")
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'dormir'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'chanter'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'pleurer'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'crier'};
i=i+1;r{i}.match='_VI_V_P0';r{i}.subst = {'travailler'};

i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'attaquer'}; %féliciter
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'rencontrer'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'embrasser'}; % encourager
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'frapper'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'aider'}; %voir

i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'aimer'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'adorer'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'préférer'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'détester'};
i=i+1;r{i}.match='_VM_V_P0';r{i}.subst = {'vouloir'};

i=i+1;r{i}.match='_BE_V_P0';r{i}.subst = {'être'};

i=i+1;r{i}.match='_DET';r{i}.subst = {'les'}; r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'le'}; r{i}.addi={{'$SINGULAR'}};%%%% masculine or feminine will be determined by a special function 
%i=i+1;r{i}.match='_DET';r{i}.subst = {'#empty'}; r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'un'}; r{i}.addi={{'$SINGULAR'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'ces'}; r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_DET';r{i}.subst = {'ce'}; r{i}.addi={{'$SINGULAR'}};

i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#future'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#perfect'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#present'};  
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#past'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#might'};
i=i+1;r{i}.match='_T_P0';r{i}.subst = {'#should'};

i=i+1;r{i}.match='_NUM';r{i}.subst = {'deux'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'cinq'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'dix'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'onze'};r{i}.addi={{'$PLURAL'}};
i=i+1;r{i}.match='_NUM';r{i}.subst = {'quelques'};r{i}.addi={{'$PLURAL'}};

%i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Jacques_FIRSTNAME'};r{i}.addi={{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Jacques_FIRSTNAME','Chirac_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Nicolas_FIRSTNAME','Sarkozy_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Martine_FIRSTNAME','Aubry_LASTNAME'};r{i}.addi={{'$SINGULAR','$FEMI'},{'$SINGULAR','$FEMI'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'John_FIRSTNAME','Lennon_LASTNAME'};r{i}.addi={{'$SINGULAR','$MASC'},{'$SINGULAR','$MASC'}};
i=i+1;r{i}.match='_PROPER';r{i}.subst = {'Marylin_FIRSTNAME','Monroe_LASTNAME'};r{i}.addi={{'$SINGULAR','$FEMI'},{'$SINGULAR','$FEMI'}};

% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'lion'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'dog'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'whale'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'bird'};
% i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'snake'};

%%%% ATTENTION pour éviter le l' (apostrophe), les noms ne doivent pas
%%%% commencer par une voyelle
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'médecin'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'garçon'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'député'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'danseuse'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_HUMAN_N_P0';r{i}.subst = {'banquière'};r{i}.addi={{'$FEMI'}};

i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'concurrent'};r{i}.addi={{'$MASC'}}; 
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'professeur'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'fan'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'collègue'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_ROLE_N_P0';r{i}.subst = {'copine'};r{i}.addi={{'$FEMI'}};

i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'déçu'}; %%% all of these adjective can be followed by a complement "de + Infinitive or + ProperName"
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'fier'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'content'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'effrayé'};
i=i+1;r{i}.match='_EMOTION_A_P0';r{i}.subst = {'inquiet'};

i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'gentil'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'petit'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'gros'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'grand'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'curieux'};

i=i+1;r{i}.match='_P_P0';r{i}.subst = {'sur'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'sous'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'devant'};
i=i+1;r{i}.match='_P_P0';r{i}.subst = {'derrière'};

i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'pont'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'toit'};r{i}.addi={{'$MASC'}};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'table'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'scène'};r{i}.addi={{'$FEMI'}};
i=i+1;r{i}.match='_LOC_N_P0';r{i}.subst = {'coupole'};r{i}.addi={{'$FEMI'}};

i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'New York'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Paris'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Tokyo'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Berlin'};
i=i+1;r{i}.match='_CITY_P_COMP';r{i}.subst = {'Toulouse'};

%%i=i+1;r{i}.match='';r{i}.subst = {''};
