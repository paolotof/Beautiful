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


beginning_of_session = now();

%=============================================================== MAIN LOOP

while mean([expe.( phase ).conditions.done])~=1 % Keep going while there are some conditions to do
    

%     instr = strrep(options.instructions.(phase), '\n', sprintf('\n'));
%     if ~isempty(instr) && starting
%         startMessages(options);
%     end
    
    starting = 0;
    
    % Find first condition not done
    i_condition = find([expe.( phase ).conditions.done]==0, 1);
    fprintf('\n============================ Testing condition %d / %d ==========\n', i_condition, length(expe.( phase ).conditions))
    condition = expe.( phase ).conditions(i_condition);

    % Prepare unitary vector for this voice direction
    u_f0  = 12*log2(options.test.voices(condition.dir_voice).f0 / options.test.voices(condition.ref_voice).f0);
    u_ser = 12*log2(options.test.voices(condition.dir_voice).ser / options.test.voices(condition.ref_voice).ser);
    u = [u_f0, u_ser];
    u = u / sqrt(sum(u.^2));
    
    fprintf('----------\nUnitary vector: %s\n', num2str(u));
    
    %---------------------------------- Adaptive Procedure
    
    difference = options.(phase).starting_difference;
    step_size  = options.(phase).initial_step_size;
    
    response_correct = [];
    decision_vector  = [];
    steps = [];
    differences = [difference];
    
    beginning_of_run = now();
    
    %% Game STUFF
%     [G, bkg, bigFish, elOne, elTwo, elThree] = setUpGame('octopus');
    [G, bkg, bigFish, bubbles] = setUpGame;
    G.onMouseRelease = @buttonupfcn;
    %% continue with the experiment
    % test subjects willingness to continue
    if ~ ready2start(G);
        return;
    end
    
    friendsID = friendNames;
%     friendsID = {'blowfish', 'clownfish', 'crab', 'octopus', 'seahorse', 'starfish'};
    countTrials = 0;
%     G.play(@action);
    newFriend = {};
    while true
        countTrials = countTrials + 1;
                
        friends = updateFriend(G.Size(1), G.Size(2), friendsID{mod(countTrials, length(friendsID)) + 1});
        % define trajectory for fishes coming in
        speedSwim = 100; % this is inverted, high number = slow
        for ifriends = 1 : length(friends)
            friends{ifriends} = swim(friends{ifriends}, speedSwim, 'in', G.Size(1));
        end
        G.play(@()friendsEnter(friends));
        
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
        uiwait();
    
        response.correct = (response.button_clicked == response.button_correct);
        
        response_correct = [response_correct, response.correct]; % these are used for the plotting in DEBUG
        decision_vector  = [decision_vector,  response.correct]; % these are used for the plotting in DEBUG
        response.condition = condition;
        response.condition.u = u;
        
        fprintf('Difference    : %.1f st (%.1f st GPR, %.1f st VTL)\n', difference, difference*u(1), difference*u(2));
        fprintf('Correct button: %d\n', response.button_correct);
        fprintf('Clicked button: %d\n', response.button_clicked);
        fprintf('Response time : %d ms\n', round(response.response_time*1000));
        fprintf('Time since beginning of run    : %s\n', datestr(response.timestamp - beginning_of_run, 'HH:MM:SS.FFF'));
        fprintf('Time since beginning of session: %s\n', datestr(response.timestamp - beginning_of_session, 'HH:MM:SS.FFF'));

%         % Visual feedback
%         if condition.visual_feedback == 1
%             if response.correct
%                 feedback_color = h.button_right_color;
%             else
%                 feedback_color = h.button_wrong_color;
%             end
%             for k=1:3
%                 pause(.1);
%                 set(h.patch(response.button_correct), 'FaceColor', feedback_color);
%                 drawnow();
%                 pause(.1);
%                 set(h.patch(response.button_correct), 'FaceColor', h.button_face_color);
%                 drawnow();
%             end
%         end

        % Add the response to the results structure
        n_attempt = expe.( phase ).conditions(i_condition).attempts + 1;
        if ~isfield(results, phase) || i_condition==length(results.( phase ).conditions)+1
            results.( phase ).conditions(i_condition) = struct('att', struct('responses', struct(), 'differences', [], 'steps', [], 'diff_i_tp', [], 'threshold', NaN, 'sd', []));
        end
        if isempty(fieldnames(results.( phase ).conditions(i_condition).att(n_attempt).responses)) ...
                || isempty(results.( phase ).conditions(i_condition).att(n_attempt).responses)
            results.( phase ).conditions(i_condition).att(n_attempt).responses = orderfields( response );
        else
            results.( phase ).conditions(i_condition).att(n_attempt).responses(end+1) = orderfields( response );
        end
        
        [difference, differences, decision_vector, step_size, steps] = ...
            setNextTrial(options, difference, differences, decision_vector, step_size, steps, phase);
        
        availableResponses = 1:3;
        availableResponses(response.button_clicked) = [];
        if response.correct
            newFriend{end + 1} = friends{response.button_clicked};
            newFriend{end} = getTrajectory(newFriend{end}, [bigFish.arcAround(:,bigFish.availableLoc(countTrials))'], [0,0], 4, .5, 90);
            speedSwim = ceil(size(newFriend{end}.trajectory,1) / 2);
        else
            speedSwim = 100; % this is 10 pixels at the time
            friends{response.button_clicked} = swim(friends{response.button_clicked}, speedSwim, 'out', G.Size(1));
            speedSwim = ceil(size(friends{response.button_clicked}.trajectory,1) / 2);
        end
        % these guys start a bit later (i.e., half animation of the clicked friends)
        % This insures subjects knows what they clicked on!
        friends{availableResponses(1)} = swim(friends{availableResponses(1)}, speedSwim, 'out', G.Size(1));
        friends{availableResponses(2)} = swim(friends{availableResponses(2)}, speedSwim, 'out', G.Size(1));
        
        if response.correct
            play(G, @()correctAnswer(newFriend{end}, friends{availableResponses(1)}, friends{availableResponses(2)}));
            bigFish.countTurns = 1;
            play(G, @()celebrate(bigFish));
        else
            play(G, @()wrongAnswer(friends{response.button_clicked}, friends{availableResponses(1)}, friends{availableResponses(2)}));
        end
        
        

        [results, expe, terminate] = ...
            determineIfExit(results, expe, steps, differences, phase, options, response_correct, n_attempt, i_condition);
        if terminate
            break;
        end

        results.( phase ).conditions(i_condition).att(n_attempt).differences = differences;
        results.( phase ).conditions(i_condition).att(n_attempt).steps = steps;
        
        % Save the response
        save(options.res_filename, 'options', 'expe', 'results')
        
%         % DEBUG
%         if DEBUG
%             figure(98)
%             set(gcf, 'Position', [50, 350, 500, 500]);
%             x = 1:length(differences)-1;
%             y = differences(1:end-1);
%             plot(x, y, '-b')
%             hold on
%             plot(length(differences)+[-1 0], differences(end-1:end), '--b')
%             plot(x(response_correct==1), y(response_correct==1), 'ob')
%             plot(x(response_correct==0), y(response_correct==0), 'xb')
%             
%             hold off
%         end
        
    end
    %---------- End of adaptive loop
    
    % Find indices of turning-points
    %{
    i_nz = find(steps~=0);
    i_d  = find(diff(sign(steps(i_nz)))~=0);
    i_tp = i_nz(i_d)+1;
    %}
    
    
    
    
    
    %============================== DEBUG
%     if DEBUG && strcmp(phase, 'training')==0
%         figure()
%         set(gcf, 'Position', [550, 350, 700, 500]);
%         subplot(1, 2, 1)
%         x = 1:length(differences)-1;
%         y = differences(1:end-1);
%         plot(x, y, '-b')
%         hold on
%         plot(length(differences)+[-1 0], differences(end-1:end), '--b')
%         plot(x(response_correct==1), y(response_correct==1), 'ob')
%         plot(x(response_correct==0), y(response_correct==0), 'xb')
%         
%         plot(i_tp, differences(i_tp), 'sr')
%         
%         plot([i_tp(1), i_tp(end)], [1 1]*thr, '--k');
% 
%         hold off
%         title(sprintf('Condition %d', i_condition));
%         
%         subplot(1, 2, 2)
%         plot([options.test.voices(condition.ref_voice).f0, options.test.voices(condition.dir_voice).f0], ...
%                 [options.test.voices(condition.ref_voice).ser, options.test.voices(condition.dir_voice).ser], '--b')
%         hold on
%         plot(options.test.voices(condition.ref_voice).f0, options.test.voices(condition.ref_voice).ser, 'ob')
%         plot(options.test.voices(condition.dir_voice).f0, options.test.voices(condition.dir_voice).ser, 'sr')
%         for i_resp=1:length(results.( phase ).conditions(i_condition).att(n_attempt).responses)
%             if results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).correct
%                 plot(results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.f0(2), ...
%                     results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.ser(2), 'xk')
%             else
%                 plot(results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.f0(2), ...
%                     results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.ser(2), '+', 'Color', [1 1 1]*.5)
%             end
%         end
%         
%         for i_sp=1:length(options.test.voices)
%             plot(options.test.voices(i_sp).f0, options.test.voices(i_sp).ser, '+g');
%         end
%         
%         hold off
%         
%     end 
%         
    % Save the response
    save(options.res_filename, 'options', 'expe', 'results');
    
    % Report status
    report_status(options.subject_name, phase, sum([expe.( phase ).conditions.done])+1, length([expe.( phase ).conditions.done]), options.log_file);
    
    % Display "take a break" message if necessary
    %{
    if options.(phase).block_size>0
        nbreak = nbreak+1;
        if nbreak>=options.(phase).block_size && mean([expe.( phase ).conditions.done])~=1
            nbreak = 0;
            opt = char(questdlg(sprintf('Take a short break...\nThen would you like to continue or stop?'),'','Continue','Stop','Continue'));
            switch lower(opt)
                case 'stop'
                    break
            end
        end
    end
    %}
    
%     h.show_instruction();
%     h.set_instruction(sprintf('Done!'));
%     
%     % Wait a bit before going to the next condition
%     pause(1);
%     %starting = true;
    
end % end of the 'conditions' while 
    
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
        if friends{1}.iter == nIter % stop processing
            G.stop();
            friends{1}.Angle = 0;
        end
       
        
    end

    function wrongAnswer(s, friend1, friend2)
        bkg.scroll('right', 1);
        s.Location = s.trajectory(s.iter,1:2);
        halfIter = size(s.trajectory,1) / 2;
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
        halfIter = size(s.trajectory,1) / 2;
        if s.iter >= halfIter
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
%% nested functions for the game
    function buttonupfcn(hObject, callbackdata)
    
        locClick = get(hObject,'CurrentPoint');
        response.timestamp = now();
        response.response_time = toc();
        response.button_clicked = 0; % default in case they click somewhere else
        for i=1:3
            if (locClick(1) >= friends{i}.clickL) && (locClick(1) <= friends{i}.clickR) && ...
                    (locClick(2) >= friends{i}.clickD) && (locClick(2) <= friends{i}.clickU)
                response.button_clicked = i;
            end
        end
        uiresume();
    end

% If we're out of the loop because the phase is finished, tell the subject
if mean([expe.( phase ).conditions.done])==1
    %msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
%     questdlg2(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),h,'OK','OK');
    ready2start(phase);
end


% close(h.f);
end

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