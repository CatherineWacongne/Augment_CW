%%%%% additional knowledge of conjugation
%past = {
%    { 'dormir'   ,'courir', 'voir',      'vouloir'  ,'Ítre'   ,'nager'    ,'encourager'    ,'faire'},
%    { 'dormait'   ,'courait', 'voyait' , 'voulait'  ,'Ètait'  ,'nageait'  ,'encourageait'  ,'faisait'},
%{ 'dormaient','couraient','voyaient','voulaient','Ètaient','nageaient','encourageaient','faisaient'}
%    };
%%DUTCH  CHANGE VERB PARTICLE OR ADD A VERB PARTICLE
past = { 
            {'slaan','ontmoeten', 'zingen', 'slapen',  'winkelen', 'rennen', 'zien', 'huilen', 'werken', 'kussen', 'helpen', 'kijken','willen', 'zijn', 'zwemmen', 'doen', 'vinden' },
            {'slaat','ontmoette', 'zong', 'sliep',   'winkelde', 'rende',  'zag',  'huilde', 'werkte', 'kuste',  'hielp',  'keek',  'wou',    'was',  'zwom',    'deed', 'vond'},
            {'slaan','ontmoetten', 'zongen', 'sliepen', 'winkelden','renden', 'zagen','huilden','werkten','kusten', 'hielpen', 'keken','wilden', 'waren','zwommen', 'deden', 'vonden'}
       };
 
 
%%DUTCH [+T present]
present = {
     {'slaan','ontmoeten', 'zingen','slapen',  'winkelen', 'rennen', 'zien', 'huilen', 'werken', 'kussen', 'helpen', 'kijken','willen', 'zijn', 'zwemmen', 'doen', 'vinden' },
     {'sloeg','ontmoet', 'zingt', 'slaapt', 'winkelt' , 'rent',   'ziet', 'huilt',  'werkt',  'kust', 'helpt', 'kijkt', 'wilt', 'is', 'zwemt', 'doet', 'vindt' },
     {'sloegen','ontmoeten', 'zingen', 'slapen',  'winkelen', 'rennen', 'zien', 'huilen', 'werken', 'kussen', 'helpen', 'kijken','willen', 'zijn', 'zwemmen', 'doen', 'vinden' }     
  };
 
%DUTCH: NO FUTURE. THIS IS AN AUXILIARY CONSTRUCTION
%zullen slapen
 
%%DUTCH: PARTICIPLES CAREFUL WITH IPP
pastparticiple = {
    {'slaan','ontmoeten', 'zingen','slapen',  'winkelen', 'rennen', 'zien', 'huilen', 'werken', 'kussen', 'helpen', 'kijken','willen', 'zijn', 'zwemmen', 'doen', 'vinden' },
    {'geslagen','ontmoet', 'gezongen', 'geslapen','gewinkelt','gerend', 'gezien','gehuilt','gewerkt','gekust', 'geholpen','gekeken','gewilt', 'geweest', 'gezwommen','gedaan','gevonden'}
    };
 
%Adjectives: short form, long form
adjectives = { 
    {'verdrietig', 'triest', 'trots', 'blij',  'bang',   'angstig',   'zenuwachtig' , 'klein',   'dik',  'lang',  'ziek',   'dit', 'deze', 'dat', 'die',  'de', 'het', 'een'
},
    {'verdrietige', 'trieste', 'trotse', 'blije',  'bange',   'angstige',  'zenuwachtig' ,  'kleine',  'lange' ,  'dikke',  'zieke',   'dit', 'deze', 'dat', 'die',  'de', 'het', 'een'
} 
};

 
auxiliaries = {
     { 'kunnen',  'moeten'    ,'zijn'  ,'hebben' , 'zullen'},
%PRESENT SG
     { 'kan ', 'moet'   ,'is'   ,'heeft',  'zal' },
%PRES PL
      { 'kunnen ', 'moeten'   ,'zijn'   ,'hebben',  'zullen' },
%DUTCH Past  SG
     { 'kon','moest','was'  ,'had', 'zou'}
%DUTCH Past  PL
     { 'konden','moesten','waren'  ,'hadden', 'zullen'}
     };
 
%%Dutch adjectives do not agree when they are used predicatively
%%They do when they are used prenominally. %
%Here is the rule:
% 
%A are followed by -e, except when the D is indefinite singular neuter (een).
%(Spelling changes (vowels in open syllables are long). I will give the inflected forms  separately. Rule: If A is a L-N adjunct choose long form; 
% unless N is indefinite sg Neuter.
 
%een groot boek
%Pl/de grote boeken

future = {
    { },
    { },
    { }
    };


% TODO
feminine = {
     { 'triest', 'trots', 'blij', 'ongerust', 'aardig', 'groot', 'nieuwsgierig', 'dit', 'deze', 'dat', 'die', 'de', 'het', 'een', 'zero'},
     { 'triest', 'trots', 'blij', 'ongerust', 'aardig', 'groot', 'nieuwsgierig', 'dit', 'deze', 'dat', 'die', 'de', 'het', 'een', 'zero'}
};
 
pronouns = {  %%% in order  singular: masc/fem/neuter  plural: masc fem neuter; and then vertically, nominative, accusative, genitive
    { {'hij', 'zij', 'het'},     {'zij','zij','ze'}},
    { {'hem', 'haar', 'het'},    {'hun', 'hun', 'ze'}   },
    { {'zijn', 'haar', 'hun'},   {'van hem', 'van haar', 'daar van'} },
 };
 
plurals = { { 'zuster', 'jongen', 'vrouw', 'bakker', 'kindje', 'hulp', 'student', 'fan', 'bewondaar', 'minnares'}, 
            { 'zusters', 'jongens', 'vrouwen', 'bakkers', 'kinderen', 'hulpen', 'studenten', 'fans',' bewonderaars', 'minnaressen'}}; 

deictic = {'daar','er'};
%{DUTCH daar strong, er is weak}
 
 