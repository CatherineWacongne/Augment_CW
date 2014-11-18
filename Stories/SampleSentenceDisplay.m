%warning off MATLAB:DeprecatedLogicalAPI;



%trialOrder = shuffle(trialOrder);

% example of how to change resolution of screen (under windows, requires 3rd party program reschange):
% !reschange -width=800 -height=600 -depth=32

try % use exceptions to return the screen to normal after crash
    
    %Screen('closeall'); % close any orphaned windows
    [window, screenRect] = Screen(0, 'OpenWindow',200);
    %hz=Screen('FrameRate', window);
    
    %HideCursor; % turn off mouse cursor
    Screen('TextFont',window, 'Arial');
    %    Screen('TextStyle', w, 1+2); for Bold = 1, Italics = 2
    
    
    %WaitForKey(99999); % don't start experiment until user pushes key
    
    sentence = {'longtemps','je','me','suis','levé','de','bonne','heure'};
    nwords = length(sentence);
    wordduration = 0.2;
    interword = 0.2;
    
    Screen(window, 'WaitBlanking'); % make sure that waitblanking has been called at least once before entering loop
    
    Priority(2); % set high priority for max performance
    
    %%% fixation point
    Screen('TextSize',window, 9);
    DrawFormattedText(window,'+','center','center',100);
    startfix = Screen(window,'Flip');
    prevtime = getSecs;
    
    for w=1:nwords        
        Screen('TextSize',window, 24);
        DrawFormattedText(window, sentence{w}, 'center','center',0);
        
        wordonset(w) = Screen(window,'Flip', prevtime + interword - 0.005);
        prevtime = getSecs;
        
        Screen('TextSize',window, 9);
        DrawFormattedText(window,'','center','center',100); %%% change to plus for fixation point
        
        wordoffset(w) = Screen(window,'Flip', prevtime + wordduration - 0.005);
        prevtime = getSecs;
    end
    
    keyIsDown = 0;
    while ~keyIsDown
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    end
    secs - startfix
    KbName(find(keyCode))
    
    
    %    Screen('CopyWindow', trial(currentTrial).stim(j).buffer, window); % draw on screen (hopefully finishing before blanking period),
    % you can check if this is true by calling
    % screen(window,'WaitBlanking'); and
    % seeing if it returns 0
    
    %     if trial(currentTrial).stim(j).desiredKey == '-' % if desired key == '-' then user cannot skip delay by hitting key
    %         waitSecs(trial(currentTrial).stim(j).delay);
    %         trial(currentTrial).stim(j).pressedKey = '-';
    %         trial(currentTrial).stim(j).correct = '';
    %     else % wait for key press, record it, and see if it matches desired key
    %         [trial(currentTrial).stim(j).pressedKey, trial(currentTrial).stim(j).delay] = ...
    %             waitForKey(trial(currentTrial).stim(j).delay);
    %
    %         trial(currentTrial).stim(j).correct = '0' + ...
    %             ( trial(currentTrial).stim(j).pressedKey == trial(currentTrial).stim(j).desiredKey); % 1 if it matches, 0 if not
    %     end
    
    %    frameCount = frameCount + 1;
    
    
    % The following two lines are useful to find out how long it takes the program to
    % get through each image display loop. The way to test is to setup a
    % stimuli display that takes X time and does not require keyboard input,
    % repeat that stimuli 20 times or so, and see what each timePerImage and
    % the average timePerImage is.
    %timePerImage
    wordonset - startfix
    
catch % if PTB crashes it will land here, allowing us to reset the screen to normal.
    a = lasterror; a.message % find out what the error is
end;

Priority(0);
Screen('closeall'); % this line deallocates the space pointed to by the buffers, and returns the screen to normal.
flushEvents('keyDown'); % removed typed characters from queue.

% example of how you would return screen to "normal resolution"
%!reschange -width=1280 -height=1024 -depth=32