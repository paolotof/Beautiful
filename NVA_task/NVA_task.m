function NVA_task(varargin)

    rng('shuffle')

    pathsToAdd = {'../lib/MatlabCommonTools/'};
    for iPath = 1 : length(pathsToAdd)
        addpath(pathsToAdd{iPath})
    end
    
    options.home = getHome;
    
    options.wordsFolder = [options.home '/Dropbox/NVA words/NVA words/NVA individual words/'];
    options.responsesFolder = [options.home '/results/NVA/'];
    options.listsFile = [options.home '/Dropbox/NVA words/NVA words/Matlab/NVA.mat'];
    options.lists2use = 46:60; % these are specific for kids
    nvaLists = getListWords(options);
    
    if nargin == 0
        options.subID = 'testOne'; 
        if ~isempty(dir([options.responsesFolder '*' options.subID '*.mat']))
            delete([options.responsesFolder '*' options.subID '*.mat'])
        end
    else
        options.subID = varargin{1};
    end 

    interface(nvaLists, options);
    
    for iPath = 1 : length(pathsToAdd)
        rmpath(pathsToAdd{iPath})
    end

end

function nvaLists = getListWords(options)
	
    load(options.listsFile);
%     wordsLists = NVA(options.lists2use(randi(length(options.lists2use), 1, 2)), :)
    nLists = 2;
    choosenLists = options.lists2use(randi(length(options.lists2use), 1, nLists));
    % make first letter uppercase to match the sound files.
    for iList = 1 : nLists
        nvaLists.(['list_' num2str(choosenLists(iList))]).wordsLists = ...
            regexprep(NVA(choosenLists(iList), :),'(\<[a-z])','${upper($1)}');
    end
end

function interface(stimulus, options)
   
    screen = monitorSize;
    screen.xCenter = round(screen.width / 2);
    screen.yCenter = round(screen.heigth / 2);

    minBottonWidth = 20;
    disp.width = 800; % minBottonWidth * length(stimulus) + 100; % 100 is an arbitrary boundary
    disp.heigth = 400;
    disp.Left = screen.left + screen.xCenter - (disp.width / 2);

    disp.Up = screen.bottom + screen.yCenter - (disp.heigth / 2);

    f = figure('Visible','off','Position',[disp.Left, disp.Up, disp.width, disp.heigth], ...
        'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');

    %  Construct the bottons.
    
%    buttonName = {'0', '1', '2', '3'}; % strsplit(stimulus, ' '); % DOES
%    NOT WORK
    buttonName = {'zero', 'one', 'two', 'three'}; % strsplit(stimulus, ' '); % words
    nButtons = length(buttonName);
    bottonHeight= 50;
    
    bottonYpos = round(disp.heigth*3/4) - round(bottonHeight / 2);
    
    for iButton = 1 : nButtons
        bottonWidth = minBottonWidth * length(buttonName{iButton}); % width botton proportional to number of characters in string
        Box.(buttonName{iButton}) = uicontrol('Style','pushbutton','String', buttonName{iButton},...
            'Position',[(disp.width * iButton/(nButtons + 1) - round(bottonWidth / 2)), bottonYpos, bottonWidth, bottonHeight],...
            'Callback',@keysCallback, 'Visible', 'On');
    end
    
    bottonWidth = minBottonWidth * length(' START ');

    Box.continue = uicontrol('Style','pushbutton','String', 'START',...
            'Position',[(disp.width/2 - round(bottonWidth/2)), bottonYpos - 2 * bottonHeight, ...
                bottonWidth, bottonHeight],...
            'Callback',@(hObject,callbackdata) continueCallback, 'Visible', 'On');
    
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    f.Units = 'normalized';
    NAMES = fieldnames(Box);
    for iButton = 1 : length(NAMES)
        Box.(NAMES{iButton}).Units = 'normalized';
    end

    % Assign the GUI a name to appear in the window title.
    f.Name = 'NVA task';
    % Move the GUI to the center of the screen.
    movegui(f,'center')
    
    % Make the GUI visible.
    f.Visible = 'on';
    iStim = 1;
    %ipush = 1;
    repeatedWords = {''};
    list = fieldnames(stimulus);
    iList = 1;
    uiwait;
    
       
    function keysCallback(source, ~)
        repeatedWords = {source.String};
        %ipush = ipush + 1;
        set(Box.(source.String),'enable','off');
        
    end

%     function continueCallback(subID)
    function continueCallback
        
        if ~isempty(repeatedWords{:})
            filename = [options.responsesFolder 'responses_' options.subID '.mat'];
            if exist(filename,'file') 
                load(filename) % this will overwrite repeated words
                if isfield(responses, list{iList})
                    responses.(list{iList}).scores(end+1) = repeatedWords;
                    responses.(list{iList}).word{end+1} = stimulus.(list{iList}).wordsLists(iStim);
                else % this additional else is to extend the structure
                    responses.(list{iList}).scores = repeatedWords;
                    responses.(list{iList}).word = stimulus.(list{iList}).wordsLists(iStim);
                end
            else
                responses.(list{iList}).scores = repeatedWords;
                responses.(list{iList}).word = stimulus.(list{iList}).wordsLists(iStim);
            end
            save(filename, 'responses');
            iStim = iStim + 1;
            set(Box.(repeatedWords{:}),'enable','on');
        end
        
        Box.continue.String = sprintf('PLAY %d', iStim);
        
        if iStim > length(stimulus.(list{iList}).wordsLists)
            if iList == length(list)
                Box.continue.String = 'FINISHED';
                pause(2);
                close(f)
            else
                iList = iList + 1;
                iStim = 1;
                repeatedWords = {''};
                Box.continue.String = sprintf('List  %d', iList);
            end
        else
            [y, fs] = audioread([options.wordsFolder stimulus.(list{iList}).wordsLists{iStim} '.wav']);
            what2play = audioplayer(y, fs);
            playblocking(what2play);
            uiresume();
        end
        
    end

end

