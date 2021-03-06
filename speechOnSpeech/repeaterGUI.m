function repeaterGUI(options)
         
    iTrial = 1;
    
    %  Create and then hide the UI as it is being constructed.
    f = figure('Visible', 'off', 'Position', [360,500,450,285], ...
        'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');
    hstart = uicontrol('Style','pushbutton',...
        'String','START','Position',[315,180,70,25], ...
        'CallBack', @runNextTrial);
    
    % Assign the a name to appear in the window title.
    %f.Name = 'Speech on speech task';
    f.Name = options.experiment;
    % Move the window to the center of the screen.
    movegui(f,'center')
    f.Visible = 'on';       

    % VU_zinnen are here!! It is now loading the text and playing the same
    % file all time
%     load ~/gitStuff/nawalMike/Speech-on-Speech/interface/VU_zinnen.mat;
    stimuli = chooseStimuli(options);
%     rndSequence = randperm(length(VU_zinnen));
    rndSequence = randperm(length(stimuli));
    subID = '01';
    
    function runNextTrial(~,~)
        if iTrial >1    
            set(hstart, 'String', 'CONTINUE');
        end
%         scorerGUI(VU_zinnen{rndSequence(iTrial)}, subID);
        scorerGUI(stimuli{rndSequence(iTrial)}, subID);
        iTrial = iTrial + 1;
    end

    
end