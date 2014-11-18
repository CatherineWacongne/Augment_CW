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
i=i+1;r{i}.match='_T_P1';r{i}.subst = {'_T_P0','_T_COMP'}; 

i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_N_SPEC','_N_P1'}; 
i=i+1;r{i}.match='_N_P2';r{i}.subst = {'_N_SPEC','_N_P1'}; %% allow up to two NPs in the sentence
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_N_L_ADJUNCT','_N_P1'}; 
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ANIMAL_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_ANIMAL_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_OBJECT_N_P0'};  %%% different sorts of Nouns, allowing for complements or not
i=i+1;r{i}.match='_N_P1';r{i}.subst = {'_OBJECT_N_P0'};  %%% different sorts of Nouns, allowing for complements or not

i=i+1;r{i}.match='_V_P2';r{i}.subst = {'_V_P1'}; 
i=i+1;r{i}.match='_V_P1';r{i}.subst = {'_VT_V_P1'}; 
i=i+1;r{i}.match='_VT_V_P1';r{i}.subst = {'_VT_V_P0','_VT_COMP',}; %% different sorts of verbs take different sorts of complements

i=i+1;r{i}.match='_A_P2';r{i}.subst = {'_A_P1'}; 
i=i+1;r{i}.match='_A_P1';r{i}.subst = {'_A_P0'}; % no complementizer for adjectives that qualify nouns

%%% more specific determination of possible SPECs, _ADJUNCTS and COMPs

i=i+1;r{i}.match='_T_SPEC';r{i}.subst = {'_N_P2'};r{i}.addi={{'$NOMINATIVE'}};
i=i+1;r{i}.match='_N_SPEC';r{i}.subst = {'_DET'};
i=i+1;r{i}.match='_N_SPEC';r{i}.subst = {'_DET'};
i=i+1;r{i}.match='_N_SPEC';r{i}.subst = {'_NUM'};
i=i+1;r{i}.match='_N_SPEC';r{i}.subst = {'_NUM'};

i=i+1;r{i}.match='_N_L_ADJUNCT';r{i}.subst = {'_A_P2'};

i=i+1;r{i}.match='_T_COMP';r{i}.subst = {'_V_P2'};
i=i+1;r{i}.match='_VT_COMP';r{i}.subst = {'_N_P2'};r{i}.addi={{'$ACCUSATIVE'}};

%%% word categories
i=i+1;r{i}.match='_A_P0';r{i}.subst = {'_PHYSICAL_A_P0'};

%%% terminals
%%% words are frequent and short (max 8 letters, usually much less)

i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'hit'};
i=i+1;r{i}.match='_VT_V_P0';r{i}.subst = {'touch'};

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

i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'lion'};
i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'dog'};
i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'whale'};
i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'bird'};
i=i+1;r{i}.match='_ANIMAL_N_P0';r{i}.subst = {'snake'};

i=i+1;r{i}.match='_OBJECT_N_P0';r{i}.subst = {'hammer'};
i=i+1;r{i}.match='_OBJECT_N_P0';r{i}.subst = {'chair'};
i=i+1;r{i}.match='_OBJECT_N_P0';r{i}.subst = {'truck'};
i=i+1;r{i}.match='_OBJECT_N_P0';r{i}.subst = {'arrow'};
i=i+1;r{i}.match='_OBJECT_N_P0';r{i}.subst = {'book'};

i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'big'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'small'};
i=i+1;r{i}.match='_PHYSICAL_A_P0';r{i}.subst = {'heavy'};

%%i=i+1;r{i}.match='';r{i}.subst = {''};
