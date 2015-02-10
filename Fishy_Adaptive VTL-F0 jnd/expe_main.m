function expe_main(options, phase)

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-02-24
% RuG / UMCG KNO, Groningen, NL
%--------------------------------------------------------------------------

results = struct();
tmp = load(options.res_filename); % options, expe, results
options = tmp.options;
expe = tmp.expe;
if isfield(tmp, 'results')
    results = tmp.results;
end

clear tmp

nbreak = 0;
starting = 1;

if isempty('../Sounds/buzz.wav')
    fs = 44100;
    buzz = (1:(44100 * .5)) / 44100;
    buzz = sin(2 * pi * 500 * buzz);
else
    
    [buzz, fs] = audioread('../Sounds/buzz.wav');
end
buzzer = audioplayer(buzz, fs);

beginning_of_session = now();

%=============================================================== MAIN LOOP
simulate = strncmp(options.subject_name, 'simulation', 8);
while mean([expe.( phase ).conditions.done])~=1 % Keep going while there are some conditions to do
    

%     instr = strrep(options.instructions.(phase), '\n', sprintf('\n'));
%     if ~isempty(instr) && starting
%         startMessages(options);
%     end
    
    starting = 0;
    
    if simulate
        simulResp = randi([0,1],151,1);
        % less correct answers
        simulResp = repmat([0 0 1], 1, 50);
        simulResp = simulResp(randperm(length(simulResp)));
        % more correct answers
        simulResp = repmat([0 1 1 1 1 1 1 1], 1, 25);
        simulResp = simulResp(randperm(length(simulResp)));

    end
    
    
    % Find first condition not done
    i_condition = find([expe.( phase ).conditions.done]==0, 1);
    fprintf('\n============================ Testing condition %d / %d ==========\n', i_condition, length(expe.( phase ).conditions))
    condition = expe.( phase ).conditions(i_condition);

    % Prepare unitary vector for this voice direction
    u_f0  = 12*log2(options.test.voices(condition.dir_voice).f0 / options.test.voices(condition.ref_voice).f0);
    u_ser = 12*log2(options.test.voices(condition.dir_voice).ser / options.test.voices(condition.ref_voice).ser);
    % PT: why is in options.(phase).voice only phase = test used in this case?
    u = [u_f0, u_ser];
    u = u / sqrt(sum(u.^2));
    
    fprintf('----------\nUnitary vector: %s\n', num2str(u));
    
    %---------------------------------- Adaptive Procedure
    
    difference = options.(phase).starting_difference;
    step_size  = options.(phase).initial_step_size;
    
    response_accuracy = [];
    decision_vector  = [];
    steps = [];
    differences = [difference];
    
    beginning_of_run = now();
    
    %% Game STUFF
    [G, bkg, bigFish, bubbles, scrsz, gameCommands, hourglass] = setUpGame(options.(phase).terminate_on_nturns);
    G.onMouseRelease = @buttonupfcn;
    %% start the game
    if ~simulate
        while starting == 0
            uiwait();
        end
    else
        gameCommands.State = 'empty';
    end
%     G.play(@()bigFishEnters(bigFish));
    
    friendsID = friendNames;
    countTrials = 0;
    newFriend = {};
    
    % Add the response to the results structure
    expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;
    n_attempt = expe.( phase ).conditions(i_condition).attempts;
       
    while true
        countTrials = countTrials + 1;
                
        friends = updateFriend(G.Size(1), G.Size(2), friendsID{mod(countTrials, length(friendsID)) + 1});
        % define trajectory for fishes coming in
        speedSwim = 5; % this is inverted, high number = slow
        for ifriends = 1 : length(friends)
            friends{ifriends} = swim(friends{ifriends}, speedSwim, 'in', G.Size(1));
        end
        G.play(@()friendsEnter(friends));

        fprintf('current number of friends: %i\n' ,length(friends));
        
        fprintf('\n------------------------------------ Trial\n');
        % Prepare the stimulus
        [response.button_correct, player, isi, response.trial] = expe_make_stim(options, difference, u, condition);
                       
        % pause(.5);
        
        %% leftEl
        playSounds(player{1}, friends{1}, bubbles)
        playSounds(isi)
        playSounds(player{2}, friends{2}, bubbles)
        playSounds(isi)
        playSounds(player{3}, friends{3}, bubbles)
        
        tic();
        % Collect the response
        if ~simulate
            uiwait();
        else
            if simulResp(countTrials)
                response.button_clicked = response.button_correct;
            else
                availAnswers = 1:3;
                availAnswers(response.button_correct) = [];
                response.button_clicked = availAnswers(1);
            end
            [response.response_time, response.timestamp]= deal(1);

        end
        
        response.correct = (response.button_clicked == response.button_correct);
        
        response_accuracy = [response_accuracy, response.correct]; % these are used for the plotting in DEBUG
        decision_vector  = [decision_vector,  response.correct]; % these are used for the plotting in DEBUG: PT: do they contain the same information?
        response.condition = condition;
        response.condition.u = u; % what is u?
        
        fprintf('Difference    : %.1f st (%.1f st GPR, %.1f st VTL)\n', difference, difference*u(1), difference*u(2));
        fprintf('Correct button: %d\n', response.button_correct);
        fprintf('Clicked button: %d\n', response.button_clicked);
        fprintf('Response time : %d ms\n', round(response.response_time*1000));
        fprintf('Time since beginning of run    : %s\n', datestr(response.timestamp - beginning_of_run, 'HH:MM:SS.FFF'));
        fprintf('Time since beginning of session: %s\n', datestr(response.timestamp - beginning_of_session, 'HH:MM:SS.FFF'));

        % add fields to the structure
        if ~isfield(results, phase) || ...
                i_condition==length(results.( phase ).conditions)+1
            results.( phase ).conditions(i_condition) = struct('att', struct('responses', struct(), 'differences', [], 'steps', [], 'diff_i_tp', [], 'threshold', NaN, 'sd', []));
        end
        % there is a problem if you go for the second attempts when the ones before failed because the
        % structure should expand to accomodate the second attempt but it does not.
        if n_attempt > length(results.( phase ).conditions(i_condition).att)
            results.( phase ).conditions(i_condition).att(n_attempt).responses = orderfields( response );
        else
            if isempty(fieldnames(results.( phase ).conditions(i_condition).att(n_attempt).responses)) ...
                    || isempty(results.( phase ).conditions(i_condition).att(n_attempt).responses)
                results.( phase ).conditions(i_condition).att(n_attempt).responses = orderfields( response );
            else
                results.( phase ).conditions(i_condition).att(n_attempt).responses(end+1) = orderfields( response );
            end
        end
        [difference, differences, decision_vector, step_size, steps] = ...
            setNextTrial(options, difference, differences, decision_vector, step_size, steps, phase);
%         [difference, differences, decision_vector, step_size, steps] = ...
%             nextTrialValues(options, difference, differences, decision_vector, step_size, steps, phase);
        
%         fprintf('%i ', steps); % display steps completed up to now
        
        availableResponses = 1:3;
        % we need to do something if participants click somewhere that is not
        % allowed... Now we give just a wrong response
        
        availableResponses(response.button_clicked) = [];
        
        correctTrials = sum(response_accuracy == 1);
        use2ndArc = 0;
        if correctTrials >= length(bigFish.availableLocArc1)
            use2ndArc = 1;
        end
        
        if response.correct
            newFriend{end + 1} = friends{response.button_clicked};
            if use2ndArc
                newFriend{end} = getTrajectory(newFriend{end}, [bigFish.arcAround2(:,bigFish.availableLocArc2(mod(correctTrials, 40) + 1))'], [0,0], 4, .5, speedSwim);
            else
                newFriend{end} = getTrajectory(newFriend{end}, [bigFish.arcAround1(:,bigFish.availableLocArc1(correctTrials))']+[0, randi([-15, 15], 1)], ...
                    [0,0], 4, .5, speedSwim);
            end
        else
            friends{response.button_clicked} = swim(friends{response.button_clicked}, speedSwim, 'out', G.Size(1));
        end
        speedSwim = ceil(size(friends{response.button_clicked}.trajectory,1) / 2);
        % these guys start a bit later (i.e., half animation of the clicked friends)
        % This insures subjects knows what they clicked on!
        friends{availableResponses(1)} = swim(friends{availableResponses(1)}, speedSwim, 'out', G.Size(1));
        friends{availableResponses(2)} = swim(friends{availableResponses(2)}, speedSwim, 'out', G.Size(1));
        
        if response.correct
            play(G, @()correctAnswer(newFriend{end}, friends{availableResponses(1)}, friends{availableResponses(2)}));
            bigFish.countTurns = 1;
            play(G, @()celebrate(bigFish));
        else
            if (response.button_clicked > 0) && (response.button_clicked < 4)
                play(G, @()wrongAnswer(friends{response.button_clicked}, friends{availableResponses(1)}, friends{availableResponses(2)}));
            else
                play(G, @()wrongAnswer(friends{availableResponses(3)}, friends{availableResponses(1)}, friends{availableResponses(2)}));

            end
        end
        
        [results, expe, terminate, nturns] = ...
            determineIfExit(results, expe, steps, differences, phase, options, response_accuracy, n_attempt, i_condition, u);
        
        
        if terminate
            gameCommands.State = 'finish';
            
            save(options.res_filename, 'options', 'expe', 'results');
            pause(5);
            close(G.FigureHandle)
            break;
        end
        
        hourglass.State = sprintf('hourglass_%d', nturns);
        
        % Save the response
        results.( phase ).conditions(i_condition).att(n_attempt).duration = response.timestamp - beginning_of_run;
        save(options.res_filename, 'options', 'expe', 'results')
        
        
    end
    
    % Save the response (should already be saved... but just to be sure...)
    save(options.res_filename, 'options', 'expe', 'results');
    
    % Report status
    %report_status(options.subject_name, phase, sum([expe.( phase ).conditions.done])+1, length([expe.( phase ).conditions.done]), options.log_file);
    
    % Display "take a break" message if necessary
    % PT this is commented in the original VTL version, but maybe we'll use
    % it later?
    if isfield(options.(phase),'block_size') && options.(phase).block_size>0
        nbreak = nbreak+1;
        if nbreak>=options.(phase).block_size && mean([expe.( phase ).conditions.done])~=1
            nbreak = 0;
            hf = struct();
            hf.screen = scrsz;
            opt = char(questdlg2(sprintf('Take a short break...\nThen would you like to continue or stop?'), hf,'Continue','Stop','Continue'));
            switch lower(opt)
                case 'stop'
                    break
            end
        end
    end
    
end % end of the 'conditions' while 


% If we're out of the loop because the phase is finished, tell the subject
if mean([expe.( phase ).conditions.done])==1
    %msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
%     questdlg2(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),h,'OK','OK');
    ready2start(phase);
end


    %===============================================================
    %% nested functions for the game
    
    %     function action(s)
    %         bkg.scroll('right', 1);
    %         s.Location = s.trajectory(s.iter,1:2);
    %         s.Scale = s.trajectory(s.iter,3);
    % %         s.Angle
    %         nIter = size(s.trajectory,1);
    %         if s.iter == nIter % stop processing
    %             G.stop();
    %             s.Angle = 0;
    %         end
    %         s.iter = s.iter + 1;
    %     end
    function friendsEnter(friends)
        
        bkg.scroll('right', 1);
        for iFriend = 1 : length(friends)
            friends{iFriend}.Location = friends{iFriend}.trajectory(friends{iFriend}.iter, 1:2);
            
            friends{iFriend}.State = ['swim' sprintf('%i',  mod(floor(friends{iFriend}.iter/10), 4) + 1)];
            friends{iFriend}.Scale = friends{iFriend}.trajectory(friends{iFriend}.iter, 3);
            friends{iFriend}.iter = friends{iFriend}.iter + 1;
        end
        
        nIter = size(friends{1}.trajectory,1);
        if friends{1}.iter > nIter % stop processing
            G.stop();
            friends{1}.Angle = 0;
        end
       
        
    end

    function wrongAnswer(s, friend1, friend2)
        bkg.scroll('right', 1);
        s.Location = s.trajectory(s.iter,1:2);
        halfIter = floor(size(s.trajectory,1) / 2);
        if s.iter > halfIter
            friend1.Location = friend1.trajectory(friend1.iter, 1:2);
            friend2.Location = friend2.trajectory(friend2.iter, 1:2);
            friend1.iter = friend1.iter + 1;
            friend2.iter = friend2.iter + 1;
        end
        nIter = size(s.trajectory,1);
        if s.iter == nIter % stop processing
            G.stop();
            s.Angle = 0;
        end
        s.State = ['swim' sprintf('%i',  mod(floor(s.iter/10), 4) + 1)];
        friend1.State = ['swim' sprintf('%i',  mod(floor(friend1.iter/10), 4) + 1)];
        friend2.State = ['swim' sprintf('%i',  mod(floor(friend2.iter/10), 4) + 1)];

        s.iter = s.iter + 1;
    end

    function correctAnswer(s, friend1, friend2)
        bkg.scroll('right', 1);
        s.Location = s.trajectory(s.iter,1:2);
        s.Scale = s.trajectory(s.iter,3);
        halfIter = floor(size(s.trajectory,1) / 2);
        
        if s.iter > halfIter
            friend1.Location = friend1.trajectory(friend1.iter, 1:2);
            friend2.Location = friend2.trajectory(friend2.iter, 1:2);
            friend1.iter = friend1.iter + 1;
            friend2.iter = friend2.iter + 1;
        end
        nIter = size(s.trajectory,1);
        if s.iter == nIter % stop processing
            G.stop();
            s.Angle = 0;
        end
        
%             if (mod(floor(iter/10), 4) == 0)
        s.State = ['swim' sprintf('%i',  mod(floor(s.iter/10), 4) + 1)];
        friend1.State = ['swim' sprintf('%i',  mod(floor(friend1.iter/10), 4) + 1)];
        friend2.State = ['swim' sprintf('%i',  mod(floor(friend2.iter/10), 4) + 1)];
        s.iter = s.iter + 1;

    end

    function celebrate(s)
        bkg.scroll('right', 1);
        if (mod(floor(s.iter/10), 4) == 0)
            s.cycleNext;
        end
        % iteration stop needs to be checked!
        if strcmp(s.State,'fish_1')
            if s.countTurns >= 1
                s.iter = 1;
                G.stop();
            end
            s.countTurns = s.countTurns + 1;
        end
    end

    function buttonupfcn(hObject, callbackdata)
    
        locClick = get(hObject,'CurrentPoint');
        if starting == 1
            
            response.timestamp = now();
            response.response_time = toc();
            response.button_clicked = 0; % default in case they click somewhere else
            for i=1:3
                if (locClick(1) >= friends{i}.clickL) && (locClick(1) <= friends{i}.clickR) && ...
                        (locClick(2) >= friends{i}.clickD) && (locClick(2) <= friends{i}.clickU)
                    response.button_clicked = i;
                end
            end
            if response.button_clicked ~= 0
                uiresume();
            else
                rotations = [-10 0 10 0];
                icounter = 1;
                play(buzzer);
                while isplaying(buzzer)
                    bigFish.Angle = rotations(mod(icounter, 4) + 1);
                    icounter = icounter + 1;
                    pause(.05);
                end
                bigFish.Angle = 0;
                
            end
        else
%             'controls' is number 8
            if (locClick(1) >= G.Children{8}.clickL) && (locClick(1) <= G.Children{8}.clickR) && ...
                    (locClick(2) >= G.Children{8}.clickD) && (locClick(2) <= G.Children{8}.clickU)
                gameCommands.State = 'empty';
                bigFish.State = 'fish_1';
                starting = 1;
                uiresume();
            end
        end
        
    end

% close(h.f);
end % End of main function

%--------------------------------------------------------------------------
function report_status(subj, phase, i, n, logFile)
    try
        fd = fopen(logFile, 'w');
        fprintf(fd, '%s : %s : %d/%d\r\n', subj, phase, i, n);
        fclose(fd);
    catch ME
        % Stay silent if it failed
    end
end