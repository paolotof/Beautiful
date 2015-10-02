function NVA_task_dbSPL(varargin)

    rng('shuffle')

    pathsToAdd = {'../lib/MatlabCommonTools/'};
    for iPath = 1 : length(pathsToAdd)
        addpath(pathsToAdd{iPath})
    end
    
    options.home = getHome;
    
    options.wordsFolder = [options.home '/Dropbox/NVA words/NVA words/NVA individual words/'];
    options.responsesFolder = [options.home '/results/NVA/'];
    if ~exist(options.responsesFolder, 'dir')
        mkdir(options.responsesFolder)
    end
    
    options.listsFile = [options.home '/Dropbox/NVA words/NVA words/Matlab/nvaList.txt'];
    options.nLists = 2;
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
    
    disp(scoreNVA)
    
    for iPath = 1 : length(pathsToAdd)
        rmpath(pathsToAdd{iPath})
    end

end

function nvaLists = getListWords(options)
	
    fileID = fopen(options.listsFile, 'rt');
    lists = textscan(fileID,'%s %s %s %s %s');
    fclose(fileID);
    choosenLists = randperm(size(lists, 2));
    choosenLists = choosenLists(1 : options.nLists);
    
    % make first letter uppercase to match the sound files.
    for iList = 1 : options.nLists
        words = regexprep(lists{choosenLists(iList)}, '#','');
        listName = ['list_' num2str(choosenLists(iList))];
        nvaLists.(listName).wordsLists = ...
            regexprep(words, '(\<[a-z])','${upper($1)}');
        nvaLists.(listName).words2Display = lists{choosenLists(iList)};
        % randomize the word list but the first one
        randomList = randperm(length(words) - 1) + 1;
        nvaLists.(listName).wordsLists( 2:end )  = nvaLists.(listName).wordsLists(randomList);
        nvaLists.(listName).words2Display(2:end) = nvaLists.(listName).words2Display(randomList);
    end
end

function interface(stimulus, options)
   
    screen = monitorSize;
    screen.xCenter = round(screen.width / 2);
    screen.yCenter = round(screen.heigth / 2);

    disp.width = 900; % minBottonWidth * length(stimulus) + 100; % 100 is an arbitrary boundary
    disp.heigth = 400;
    disp.Left = screen.left + screen.xCenter - (disp.width / 2);

    disp.Up = screen.bottom + screen.yCenter - (disp.heigth / 2);

    f = figure('Visible','off','Position',[disp.Left, disp.Up, disp.width, disp.heigth], ...
        'Toolbar', 'none', 'Menubar', 'none', 'NumberTitle', 'off');

    %  Construct the bottons.
    list = fieldnames(stimulus);
    iList = 1;
    iStim = 1;
    
    % buttonName = ['zero' currentWord 'ALL']; % words
    phonemesNum = {'first', 'second', 'third'};
    buttonName = {'zero', phonemesNum{:}, 'ALL'}; % words
    % buttonName = {phonemesNum{:}, 'ALL'}; % words
    nButtons = length(buttonName);
    minBottonWidth = 25;
    nLettersXbutton = cellfun('length', buttonName); % however 2,3,4 are only letters not first, second, third
    nLettersXbutton(2:4) = 2; % i.e. maximmaly 2 letters
    bottonWidth = minBottonWidth + minBottonWidth * nLettersXbutton;
    bottonHeight= 80;
    bottonYpos = round(disp.heigth*3/4) - round(bottonHeight / 2);
    for iButton = 1 : nButtons
%         bottonWidth = minBottonWidth + minBottonWidth * length(buttonName{iButton}); % width botton proportional to number of characters in string
%         Box.(buttonName{iButton}) = uicontrol('Style','pushbutton','String', buttonName{iButton},...
%             'Position',[(disp.width * iButton/(nButtons + 1) - round(bottonWidth / 2)), bottonYpos, bottonWidth, bottonHeight],...
%             'Callback',@keysCallback, 'Visible', 'On', 'FontSize', 20);%, 'enable', 'off');
        Box.(buttonName{iButton}) = uicontrol('Style','pushbutton','String', buttonName{iButton},...
            'Position',[(disp.width * iButton/(nButtons + 1) - round(bottonWidth(iButton) / 2)), ...
                bottonYpos, bottonWidth(iButton), bottonHeight],...
            'Callback',@keysCallback, 'Visible', 'On', 'FontSize', 20);%, 'enable', 'off');
    end
    
    set(Box.zero, 'BackgroundColor', 'red');
    set(Box.ALL, 'BackgroundColor', 'green');
    
    currentWord = strsplit(stimulus.(list{iList}).words2Display{iStim}, '#'); % words
    for phoneme = 1 : length(currentWord)
        Box.(phonemesNum{phoneme}).String = currentWord{phoneme};
    end
    
    bottonWidth = minBottonWidth + minBottonWidth * length('  START  ');
    Box.continue = uicontrol('Style','pushbutton','String', 'START',...
            'Position',[(disp.width/2 - round(bottonWidth/2)), bottonYpos - 2 * bottonHeight, ...
                bottonWidth, bottonHeight],...
            'Callback',@(hObject,callbackdata) continueCallback, 'Visible', 'On', 'FontSize', 20);
    
    % Initialize the GUI.
    % Change units to normalized so components resize automatically.
    f.Units = 'normalized';
    NAMES = fieldnames(Box);
    for iButton = 1 : length(NAMES)
        Box.(NAMES{iButton}).Units = 'normalized';
    end

    % Assign the GUI a name to appear in the window title.
    f.Name = 'NVA task dbSPL';
    % Move the GUI to the center of the screen.
    movegui(f,'center')
    
    % Make the GUI visible.
    f.Visible = 'on';
    
    ipush = 1;
    repeatedPhonemes = {''};
    uiwait;
       
    function keysCallback(source, ~)
        repeatedPhonemes{ipush} = source.String;
        ipush = ipush + 1;
%         set(Box.(source.String),'enable','off');
%         tmp = fieldnames(Box);
%         for iBotton = 1 : length(tmp)
%             if strcmp(Box.(tmp{iBotton}).String, source.String)
%                 set(Box.(tmp{iBotton}),'enable','off');
%             end
%         end
        switch source.String
            case Box.zero.String
                set(Box.zero, 'enable', 'off');
            case Box.ALL.String        
                set(Box.ALL, 'enable', 'off');
            case Box.first.String
                set(Box.first, 'enable', 'off');
            case Box.second.String        
                set(Box.second, 'enable', 'off');
            case Box.third.String
                set(Box.third, 'enable', 'off');
            otherwise
                fprintf('something odd with setting off buttons\n')
        end
        set(Box.continue, 'enable', 'on');
    end

    function continueCallback
        
        %% phonemes have been clicked
        if ~isempty(repeatedPhonemes{1})
            
            filename = [options.responsesFolder 'responses_' options.subID '.mat'];
            if exist(filename,'file') 
                load(filename) % this will overwrite repeated words
                if isfield(responses, list{iList})
                    responses.(list{iList}).scores{end+1} = repeatedPhonemes;
                    responses.(list{iList}).word{end+1} = stimulus.(list{iList}).wordsLists(iStim-1);
                else % this additional else is to extend the structure
                    responses.(list{iList}).scores{1} = repeatedPhonemes;
                    responses.(list{iList}).word{1} = stimulus.(list{iList}).wordsLists(iStim-1);
                end
            else
                responses.(list{iList}).scores{1} = repeatedPhonemes;
                responses.(list{iList}).word{1} = stimulus.(list{iList}).wordsLists(iStim-1);
            end
            save(filename, 'responses');
     
            % return button status to ON
            for phoneme = 1 : length(repeatedPhonemes)
%                 tmp = fieldnames(Box);
%                 for iBotton = 1 : length(tmp)
%                     if strcmp(Box.(tmp{iBotton}).String, repeatedPhonemes{phoneme})
%                         set(Box.(tmp{iBotton}),'enable','on');
%                     end
%                 end
                switch repeatedPhonemes{phoneme}
                    case Box.zero.String
                        set(Box.zero, 'enable', 'on');
                    case Box.ALL.String
                        set(Box.ALL, 'enable', 'on');
                    case Box.first.String
                        set(Box.first, 'enable', 'on');
                    case Box.second.String
                        set(Box.second, 'enable', 'on');
                    case Box.third.String
                        set(Box.third, 'enable', 'on');
                    otherwise
                        fprintf('something odd with setting off buttons\n')
                end
            end
            
            %% update the button names
            if iStim > length(stimulus.(list{iList}).wordsLists) && (iList) == length(list)
                Box.continue.String = 'FINISHED';
                pause(2);
                close(f)
            else
                
                if iStim > length(stimulus.(list{iList}).wordsLists) && (iList + 1) <= length(list)
                    currentWord = strsplit(stimulus.(list{iList+1}).words2Display{1}, '#');
                else
                    currentWord = strsplit(stimulus.(list{iList}).words2Display{iStim}, '#');
                end
                for phoneme = 1 : length(phonemesNum)
                    Box.(phonemesNum{phoneme}).String = currentWord{phoneme};
                end
                repeatedPhonemes = {''};
                ipush = 1;
            end
        end
        
        
        %% independent of whether phonemes have been clicked or not
        if iStim > length(stimulus.(list{iList}).wordsLists)
            if iList == length(list)
                Box.continue.String = 'FINISHED';
                pause(2);
                close(f)
            else
                iList = iList + 1;
                iStim = 1;
                repeatedPhonemes = {''};
                Box.continue.String = 'START';
            end
        else
            Box.continue.String = sprintf('PLAYING = %d', iStim);
            for iButton = 1 : length(buttonName)
                set(Box.(buttonName{iButton}), 'enable', 'off');
            end
            [y, fs] = audioread([options.wordsFolder stimulus.(list{iList}).wordsLists{iStim} '.wav']);
            what2play = audioplayer(y, fs);
            playblocking(what2play);
            uiresume();
            iStim = iStim + 1;
            Box.continue.String = sprintf('NEXT = %d', iStim);
            if iStim > length(stimulus.(list{iList}).wordsLists)
                Box.continue.String = sprintf('NEXT List  %d', iList + 1);
            end
            for iButton = 1 : length(buttonName)
                set(Box.(buttonName{iButton}), 'enable', 'on');
            end
            set(Box.continue, 'enable', 'off');
        end
        
    end

end

