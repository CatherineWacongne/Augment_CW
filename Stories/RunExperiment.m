function [outfile ] = RunExperiment(nsentences,varargin)
%%%%% NeuroSyntax experiment of sentence reading and ellipsis judgment
%%%%% (c) Stanislas Dehaene
%%%%%
%%%%% USAGE:
%%%%% RunExperiment(nsentences,language,recordingsite,control)
%%%%%
%%%%% EXAMPLES:
%%%%%     RunExperiment(80,1,0);
%%%%% for a 10-minute experiment with 80 sentences in English, no recording
%%%%%     RunExperiment(80,2,0);
%%%%% for a 10-minute experiment with 80 sentences in French, no recording
%%%%%
%%%%%     RunExperiment(-1,2,0);
%%%%% for a control experiment yoked to an existing experimental file
%%%%%
%%%%% The first parameter is the number of sentences (rounded to a multiple
%%%%% of 8, in order to equalize the numbers of sentences at different
%%%%% lengths)
%%%%% Using -1 will let you run a "control experiment" that re-uses the
%%%%% same words as an existing recording, but scrambles them
%%%%%
%%%%% The second parameter (optional) is the language (1=English, 2=French, 3=Dutch)
%%%%%
%%%%% The third parameter (optional) is the recording site which defines the convention
%%%%% for sending TTL signals to the recording device (0=just testing, 1=USA,
%%%%% 2=Paris)
%%%%%
%%%%% The program will automatically call the StimulusGeneration routine
%%%%% which will use the appropriate language to generate sentences according to the
%%%%% the current lexicon and rules (this may take a few minutes).
%%%%%
%%%%% Everything will be automatically saved to a dated file.
%%%%%

rand('twister',sum(10*clock)); %%% reset random numbers

global language

if size(varargin,2)>=1
    language = varargin{1};
else
    language = 1; %'English'
    %language = 2; %'French'
    %language = 3; %'Dutch'
end

if size(varargin,2)>=2
    recordingsite = var
    argin{2};
else
    recordingsite = language; %%% 1 = English site, 2 = Paris
end

disp(' ');
disp('NEUROSYNTAX EXPERIMENT')
disp(' ');
disp('You may interrupt the experiment by pressing the ESCAPE key');
disp(' ');
disp('Stimulus generation may take a while, can be interrupted by CTRL-C');
disp(' ');
disp('Press RETURN to begin');
pause;

currentdirectory = pwd;  %%% saves the working directory

nsentences=3

if nsentences > 0
    ControlExperiment = false;
    %%%%%%%% generate and randomize the stimuli for a full NeuroSyntax
    %%%%%%%% experiment
    outfile = StimulusGeneration(nsentences,language);  %%% generate n sentences in language i (1=English, 2 = French)
    load(outfile);
    clear wordonset startfix
    %%%% prepare the lists of randomized parameters
    
    %% Choose the font: large or small
    fontused = ones(1,nsentences);
    fontused(1:round(nsentences/2)) = 2;
    fontused = Shuffle(fontused);
    
    %% choose if second sentence is the same as the first
    samestruct = ones(1,nsentences);
    samestruct(1:round(nsentences/4)) = 0; %% one fourth of trials have a "different" response ie the ellipsis isn't appropriate to sentence 1
    samestruct = Shuffle(samestruct);
    
    %%% generate a random order for the sentences
    trialorder = Shuffle(1:nsentences);
    
    for isent = 1:nsentences  %%% this is the index of the trial in the experiment
        %%%%% note that the original sentences are shuffle through the variable TrialOrder
        
        %%% prepare the stimuli as a list of words
        
        %% first sentence
        inum = 1;
        sentenceID{isent,inum} = trialorder(isent);
        [ wordlist{isent,inum} nodelist{isent,inum} ] = ListTerminals(surface{sentenceID{isent,inum}},1,{},{});
        for iword =1:length(nodelist{isent,inum})
            sentlist{isent,inum}{iword} = sentenceID{isent,inum};
        end
        
        %% second sentence
        inum = 2;
        if samestruct(isent)
            sentenceID{isent,inum} = sentenceID{isent,1};
        else
            sentenceID{isent,inum}= random('unid',nsentences); %% pick another second sentence at random
            while sentenceID{isent,inum} == sentenceID{isent,1}
                sentenceID{isent,inum} = random('unid',nsentences);
            end
        end
        [ wordlist{isent,inum} nodelist{isent,inum} ] = ListTerminals(shortened{sentenceID{isent,inum}},1,{},{});
        for iword =1:length(nodelist{isent,inum})
            sentlist{isent,inum}{iword} = sentenceID{isent,inum};
        end
    end
    
else %%%% generate a yoked control experiment
    disp('Select one of the existing data sets (''probably the most recent one'')');
    outfile = uigetfile('ExperimentalRun*.mat');
    load(outfile);
    ControlExperiment = true;
    %%%% begin by listing all the words used in the existing experiment
    totwords = 0;
    for isent=1:nsentences
        nwords = length(wordlist{isent,1});
        for iword=1:nwords
            totwords = totwords +1;
            giantwordlist{totwords}.word = wordlist{isent,1}{iword};
            %%%% keep track of the original sentence and node from which
            %%%% each word was originally drawn
            giantwordlist{totwords}.sentenceID = sentenceID{isent,1};
            giantwordlist{totwords}.nodeID = nodelist{isent,1}(iword);
        end
    end
    
    %%%% shuffle word order
    newwordorder = Shuffle(1:totwords);
    
    itot = 0;
    for isent = 1:nsentences  %% we just change the wordlists
        %%%%% generate a random list replacing the existing one
        inum = 1;
        nwords = length(wordlist{isent,inum});
        for iword=1:nwords
            itot = itot+1;
            newword = newwordorder(itot);
            wordlist{isent,inum}{iword} = giantwordlist{newword}.word;
            nodelist{isent,inum}{iword} = giantwordlist{newword}.nodeID;
            sentlist{isent,inum}{iword} = giantwordlist{newword}.sentenceID;
        end
        
        inum = 2;
        wordlist{isent,2}=cell(1); %%% we reduce the second sentence to one word
        if samestruct(isent)  %%%% draw a word from the previous list
            newword = random('unid',nwords);
            wordlist{isent,inum}{1} = wordlist{isent,1}{newword};
            nodelist{isent,inum}{1} = nodelist{isent,1}{newword};
            sentlist{isent,inum}{1} = sentlist{isent,1}{newword};
        else
            %%% draw a word completely at random, but avoiding any existing
            %%% word in the previous list
            notgood = true;
            while notgood
                newword = random('unid',totwords);
                notgood = false;
                rootword = surface{giantwordlist{newword}.sentenceID}.node{giantwordlist{newword}.nodeID{1}};
                for iword =1:nwords
                    rootwordi = surface{sentlist{isent,1}{iword}}.node{nodelist{isent,1}{iword}{1}};
                    if strcmp(rootword,rootwordi)
                        notgood = true;
                    end
                end
            end
            wordlist{isent,inum}{1} = giantwordlist{newword}.word;
            nodelist{isent,inum}{1} = giantwordlist{newword}.nodeID;
            sentlist{isent,inum}{1} = giantwordlist{newword}.sentenceID;
        end
    end
end
disp('Launching PsychToolBox');

try % use exceptions to return the screen to normal after crash
    
    %Screen('closeall'); % close any orphaned windows
    [window, ScreenRect] = Screen(0, 'OpenWindow',200);
    FrameRate=60;%Screen('FrameRate', window); %%% just used for the initial signature
    
    % set the rectangle for the photodiode flash
    PhotodiodeSize = 100; %% in pixels
    PhotodiodeRect = [ PhotodiodeSize PhotodiodeSize 2*PhotodiodeSize 2*PhotodiodeSize ];
    
    white = WhiteIndex(window); % pixel value for white
    black = BlackIndex(window); % pixel value for black
    
    %HideCursor; % turn off mouse cursor
    Screen('TextFont',window, 'Arial');
    %    Screen('TextStyle', w, 1+2); for Bold = 1, Italics = 2
    
    Screen(window, 'WaitBlanking'); % make sure that waitblanking has been called at least once before entering loop
    
    Priority(2); % set high priority for max performance
    
    %%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if recordingsite == 2  %%% Paris
        %for intracranial recordings in Paris, first set parallel port to 0
        lptwrite(888,0);
    end
    %%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%% Ready?
    Screen('TextSize',window, 24);
    DrawFormattedText(window,'Start recording NOW, then press a key to launch experiment','center','center',0);
    Screen(window,'Flip');
    % don't start experiment until user pushes key
    keyIsDown = 0;
    while ~keyIsDown
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    end
    %KbPressWait; 
    
    %%%%%% Experiment started -- clear the screen
    Screen('TextSize',window, 9);
    DrawFormattedText(window,'+','center','center',100);
    prevtime = Screen(window,'Flip');
    
    %%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% send a short sequence to unambiguously identify the experiment, just in
    %%% case we get confused in the successive files...
    mark_on  = round(((random('unid',5)+2)/FrameRate)*1000); %%% random duration in milliseconds
    mark_off = round(((random('unid',5)+2)/FrameRate)*1000); %%% random duration in milliseconds
    mark_number = random('unid',5)+5;
    
    if recordingsite == 1  %%% USA -- send flashes to the photodiode
        for imark = 1:mark_number
            DrawFormattedText(window,'+','center','center',100);
            Screen('FillRect',window,white,PhotodiodeRect);
            Screen(window,'Flip',prevtime + mark_on/1000 - 0.005);
            
            DrawFormattedText(window,'+','center','center',100);
            Screen('FillRect',window,black,PhotodiodeRect);
            Screen(window,'Flip',prevtime + mark_off/1000 - 0.005);
        end
    end
    if recordingsite == 2  %%% Paris
        %%% send a short sequence to unambiguously identify the experiment, just in
        %%% case we get confused in the successive files...
        for imark = 1:mark_number
            lptwrite(888,255);
            WaitSecs(mark_on/1000);
            lptwrite(888,0);
            WaitSecs(mark_off/1000);
        end
    end
    %%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    for isent = 1:nsentences  %%% this is the index of the trial in the experiment
        %%%%% note that the original sentences are shuffle through the variable TrialOrder
        
        %%% fixation point
        Screen('TextSize',window, 9);
        DrawFormattedText(window,'+','center','center',100);
        if recordingsite == 1
            Screen('FillRect',window,black,PhotodiodeRect);
        end
        startfix{isent} = Screen(window,'Flip');
        prevtime = GetSecs;
        WaitSecs(0.4);
        
        %%% Ready?
        Screen('TextSize',window, 24);
        if recordingsite == 1
            Screen('FillRect',window,black,PhotodiodeRect);
        end
        %       DrawFormattedText(window,'Ready?','center','center',0);
        Screen(window,'Flip');
        WaitSecs(0.4);
        
        %%% wait for any key press
        %        keyIsDown = 0;
        %        while ~keyIsDown
        %            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        %        end
        
        %%% fixation point, with flash for photodiode if needed
        Screen('TextSize',window, 9);
        DrawFormattedText(window,'+','center','center',100);
        if recordingsite == 1  %%% USA -- send flashes to the photodiode
            Screen('FillRect',window,white,PhotodiodeRect);
        end
        prevtime = Screen(window,'Flip');
        startfix{isent} = prevtime;
        %%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % send a trigger at the onset of the fixation preceding the first sentence of
        % each pair
        if recordingsite == 1  %%% USA -- return to black screen with fixation
            Screen('TextSize',window, 9);
            DrawFormattedText(window,'+','center','center',100);
            if recordingsite == 1
                Screen('FillRect',window,black,PhotodiodeRect);
            end
            Screen(window,'Flip',prevtime + 0.050 - 0.005); %%% 50 millisecond flash
        end
        if recordingsite == 2  %%% Paris
            lptwrite(888,255);
            WaitSecs(0.05);
            lptwrite(888,0);
        end
        %%% TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        prevtime = GetSecs;
        WaitSecs(0.6);
        prevtime = GetSecs;
        
        for inum = 1:2
            nwords = length(wordlist{isent,inum});
            wordduration = 0.2;
            interword = 0.2;
            
            for w=1:nwords
                %%%% set the font
                if fontused(isent) == 1
                    Screen('TextSize',window, 24);
                    Screen('TextStyle',window, 0);  %%% normal
                else
                    Screen('TextSize',window, 36);
                    Screen('TextStyle',window, 1);  %%% bold
                end
                
                %%% show the word
                DrawFormattedText(window, wordlist{isent,inum}{w}, 'center','center',0);
                
                %%%% add photodiode flash
                if recordingsite == 1  %%% USA -- send flashes to the photodiode
                    Screen('FillRect',window,white,PhotodiodeRect);
                end
                
                wordonset{isent,inum}{w} = Screen(window,'Flip', prevtime + interword - 0.005);
                prevtime = GetSecs;
                
                Screen('TextSize',window, 9);
                DrawFormattedText(window,'','center','center',100); %%% change to plus for fixation point
                if recordingsite == 1  %%% USA -- send flashes to the photodiode
                    Screen('FillRect',window,black,PhotodiodeRect);
                end
                
                wordoffset{isent,inum}{w} = Screen(window,'Flip', prevtime + wordduration - 0.005);
                prevtime = GetSecs;
            end
            
            %%% intersentence fixation point
            Screen('TextSize',window, 9);
            DrawFormattedText(window,'+','center','center',100);
            if recordingsite == 1
                Screen('FillRect',window,black,PhotodiodeRect);
            end
            Screen(window,'Flip', prevtime + wordduration - 0.005);  %%% wait for the word duration, then erase the word
            prevtime = GetSecs;
            if (inum==1)
                waittime = 2.0; %%% stick to the fixation screen for a long delay.
                DrawFormattedText(window,'+','center','center',100);
                Screen(window,'Flip', prevtime + waittime - 0.005);  %%% after delay, move on to the next words
                prevtime = GetSecs;
            end
            
        end
        
        %%% response screen
        if recordingsite == 1  %%% USA -- send flashes to the photodiode
            Screen('FillRect',window,black,PhotodiodeRect);
        end
        Screen('TextSize',window, 36);
        DrawFormattedText(window,'?','center','center',0);
        choicescreen{isent} = Screen(window,'Flip');
        prevtime = GetSecs;
        
        keyIsDown = 0;
        while ~keyIsDown
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        end
        response{isent} = KbName(find(keyCode));
        RT{isent} = secs - prevtime;
        
        %% show word durations
        worddurations = cell2mat(wordoffset{isent,1})- cell2mat(wordonset{isent,1})
        
        %%%% interrupt the experiment?
        if strcmp(response{isent},'esc')
            break;
        end
    end
    
    
catch % if PTB crashes it will land here, allowing us to reset the screen to normal.
    a = lasterror; a.message % find out what the error is
end;

Priority(0);
Screen('closeall'); % this line deallocates the space pointed to by the buffers, and returns the screen to normal.
FlushEvents('keyDown'); % removed typed characters from queue.

% example of how you would return screen to "normal resolution"
%!reschange -width=1280 -height=1024 -depth=32

outfile = [ 'ExperimentalRun' sprintf('_%d',fix(clock)) '.mat' ];
save(outfile);  %%% save everything: the wordlist, the sentences, even the rules used to generate the sentences



