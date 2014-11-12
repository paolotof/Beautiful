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
    

    starting = 0;
    instr = strrep(options.instructions.(phase), '\n', sprintf('\n'));
    if ~isempty(instr) && starting
        startMessages(options);
    end
    
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
%     G = SpriteKit.Game.instance('Title','Interactive Demo','Size',[800 600]);
%     bkg = SpriteKit.Background('../img/BACKGROUND.png');
%     addBorders(G);
    [G, bigFish, tFish, yFish, rFish] = setUpGame;
    
    G.onMouseRelease = @buttonupfcn;
    
    %% continue with experiment
    oldimage = get(0,'DefaultImageVisible');
    set(0, 'DefaultImageVisible','off')
    button = questdlg('Ready to Start?','START','Yes','No','Yes');
    set(0,'DefaultImageVisible',oldimage) 
   
    if strcmp(button, 'No')
        msgbox('OK, ciaociao')
        return;
    end
    
    while true
        
        fprintf('\n------------------------------------ Trial\n');
        
        % Prepare the stimulus
        [response.button_correct, player, isi, response.trial] = expe_make_stim(options, difference, u, condition);
                       
        % pause(.5);
        
        % Play the stimuli
%         nStim = length(player);
%         for i = 1 : nStim
%             tFish.Scale = 2;
%             playblocking(player{i});
%             tFish.Scale = 1;
% 
%             if i ~= nStim
%                 playblocking(isi);
%             end
%         end
        %% tFish
        playSounds(player{1}, tFish)
        playSounds(isi)
        playSounds(player{2}, yFish)
        playSounds(isi)
        playSounds(player{3}, rFish)
        
%         %% yFish
%         play(player{2})
%         while isplaying(player{2})
%             yFish.Angle = yFish.Angle-1;
%         end
%         
%         play(isi)
%         while isplaying(isi)
%         end
%         
%         play(player{3})
%         while isplaying(player{3})
%             rFish.Angle = rFish.Angle-1;
%         end

        tic();
        uiwait();
        % Collect the response
%         ok = false;
%         while ~ok
%             uiwait();
%             response.response_time = toc();
%             response.timestamp = now();
%             h = get(h.f, 'UserData');
%             i_clicked = h.last_clicked;
%             if ~isnan(i_clicked)
%                 ok = true;
%                 fprintf('Click!\n');
%             end
%         end
    
%     set(h.f, 'UserData', h);

        
        % Fill the response structure
%         response.button_correct = i_correct;
%         response.button_clicked = i_clicked;
        
        response.correct = (response.button_clicked == response.button_correct);
        response_correct = [response_correct, response.correct]; % these are used for the plotting in DEBUG
        decision_vector  = [decision_vector,  response.correct]; % these are used for the plotting in DEBUG
        response.condition = condition;
        response.condition.u = u;
%         response.trial.v = difference*u;
        
        fprintf('Difference    : %.1f st (%.1f st GPR, %.1f st VTL)\n', difference, difference*u(1), difference*u(2));
%         fprintf('Correct button: %d\n', i_correct);
        fprintf('Correct button: %d\n', response.button_correct);
%         fprintf('Clicked button: %d\n', i_clicked);
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
    
end

    function buttonupfcn(hObject,callbackdata)
        
        locClick = get(hObject,'CurrentPoint');
        response.timestamp = now();
        response.response_time = toc();
        response.button_clicked = 0; % default in case they click somewhere else
        if (locClick(1) >= tFish.clickL) && (locClick(1) <= tFish.clickR) && ...
                (locClick(2) >= tFish.clickD) && (locClick(2) <= tFish.clickU)
            response.button_clicked = 1;
%             fprintf('click blue\n')
        end
        if (locClick(1) >= yFish.clickL) && (locClick(1) <= yFish.clickR) && ...
                (locClick(2) >= yFish.clickD) && (locClick(2) <= yFish.clickU)
            response.button_clicked = 2;
%             fprintf('click yellow\n')
        end
        if (locClick(1) >= rFish.clickL) && (locClick(1) <= rFish.clickR) && ...
                (locClick(2) >= rFish.clickD) && (locClick(2) <= rFish.clickU)
            response.button_clicked = 3;
%             fprintf('click red\n')
        end
        uiresume();
    end



% If we're out of the loop because the phase is finished, tell the subject
if mean([expe.( phase ).conditions.done])==1
    %msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
    questdlg2(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),h,'OK','OK');
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