function [outfile ] = SentenceDisplay(nsentences,varargin)
%%%%% full experiment of sentence reading and ellipsis judgment

global language

if size(varargin,2)>=1
    language = varargin{1};
else
  language = 1; %'English'
  %language = 2; %'French'
end


outfile = StimulusGeneration(nsentences,language);  %%% generate n sentences in language i (1=English, 2 = French)

load(outfile);

%trialOrder = shuffle(trialOrder);
% example of how to change resolution of screen (under windows, requires 3rd party program reschange):
% !reschange -width=800 -height=600 -depth=32


disp('Launching PsychToolBox');

try % use exceptions to return the screen to normal after crash
    
    %Screen('closeall'); % close any orphaned windows
    [window, screenRect] = Screen(0, 'OpenWindow',200);
    %hz=Screen('FrameRate', window);
    
    %HideCursor; % turn off mouse cursor
    Screen('TextFont',window, 'Arial');
    %    Screen('TextStyle', w, 1+2); for Bold = 1, Italics = 2
    
    Screen(window, 'WaitBlanking'); % make sure that waitblanking has been called at least once before entering loop
    
    Priority(2); % set high priority for max performance
    
    
    %WaitForKey(99999); % don't start experiment until user pushes key
    
    for isent = 1:nsentences
        
        %%% prepare the stimuli as a list of words
        
        %% first sentence: in strict numerical order
        sentenceID{isent,1} = isent;
        [ wordlist{isent,1} nodelist{isent,1} ] = ListTerminals(surface{sentenceID{isent,1}},1,{},{});
        
        %% second sentence
        samestruct{isent} = (rand<=0.75); %%% probability that the second sentence has the same structure as the first, after ellipsis
        if samestruct{isent}
            sentenceID{isent,2} = isent;
        else
            sentenceID{isent,2}= random('unid',nsentences); %% pick another second sentence at random
            while sentenceID{isent,2} == sentenceID{isent,1}
                sentenceID{isent,2} = random('unid',nsentences);
            end
        end
        [ wordlist{isent,2} nodelist{isent,2} ] = ListTerminals(shortened{sentenceID{isent,2}},1,{},{});
        
        %%% fixation point
        Screen('TextSize',window, 9);
        DrawFormattedText(window,'+','center','center',100);
        startfix{isent} = Screen(window,'Flip');
        prevtime = GetSecs;
        WaitSecs(0.4);

        %%% Ready?
        Screen('TextSize',window, 24);
 %       DrawFormattedText(window,'Ready?','center','center',0);
        Screen(window,'Flip');
        WaitSecs(0.4);
        
        %%% wait for any key press
%        keyIsDown = 0;
%        while ~keyIsDown
%            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
%        end
        
        %%% fixation point
        Screen('TextSize',window, 9);
        DrawFormattedText(window,'+','center','center',100);
        startfix{isent} = Screen(window,'Flip');
        prevtime = GetSecs;
        WaitSecs(0.6);
        prevtime = GetSecs;
        
        for inum = 1:2
            nwords = length(wordlist{isent,inum});
            wordduration = 0.5;
            interword = 0.2;
            
            for w=1:nwords
                Screen('TextSize',window, 24);
                DrawFormattedText(window, wordlist{isent,inum}{w}, 'center','center',0);
                
                wordonset{isent,inum}{w} = Screen(window,'Flip', prevtime + interword - 0.005);
                prevtime = GetSecs;
                
                Screen('TextSize',window, 9);
                DrawFormattedText(window,'','center','center',100); %%% change to plus for fixation point
                
                wordoffset{isent,inum}{w} = Screen(window,'Flip', prevtime + wordduration - 0.005);
                prevtime = GetSecs;
            end
            
            %%% intersentence fixation point
            Screen('TextSize',window, 9);
            DrawFormattedText(window,'+','center','center',100);
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
        Screen('TextSize',window, 9);
        DrawFormattedText(window,'?','center','center',100);
        choicescreen{isent} = Screen(window,'Flip');
        prevtime = GetSecs;
        
        keyIsDown = 0;
        while ~keyIsDown
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        end
        response{isent} = KbName(find(keyCode));
        RT{isent} = secs - prevtime;
        
        %% show word durations
        worddurations = cell2mat(wordoffset{1,1})- cell2mat(wordonset{1,1})
        
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

