function expe_main(options, phase)

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-02-24
% RuG / UMCG KNO, Groningen, NL
%--------------------------------------------------------------------------

results = struct();
load(options.res_filename); % options, expe, results

nbreak = 0;
starting = 1;

% Set Level
if ispc()
    pa_init(options.fs);
    setPA4(3, 0);
    setPA4(4, 0);
    setPA4(1, options.attenuation_dB);
    setPA4(2, options.attenuation_dB);
end

test_machine = is_test_machine();

beginning_of_session = now();

%=============================================================== MAIN LOOP

while mean([expe.( phase ).conditions.done])~=1 % Keep going while there are some conditions to do
    

    starting = 0;
    instr = strrep(options.instructions.(phase), '\n', sprintf('\n'));
    if ~isempty(instr) && starting
        startMessages(options);
    end
    
    % Prepare the GUI
%     h.set_instruction(sprintf('Which interval is different?'));
    
    % Find first condition not done
    i_condition = find([expe.( phase ).conditions.done]==0, 1);
    fprintf('\n============================ Testing condition %d / %d ==========\n', i_condition, length(expe.( phase ).conditions))
    condition = expe.( phase ).conditions(i_condition);

    if condition.vocoder==0
        fprintf('No vocoder\n\n');
    else
        fprintf('Vocoder: %s\n\n', options.vocoder(condition.vocoder).label);
    end
    
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
    
    while true
        
        fprintf('\n------------------------------------ Trial\n');
        
        % Prepare the trial
        trial = condition;
        
        % Compute test voice
        new_voice_st = difference*u;
        trial.f0 = options.test.voices(trial.ref_voice).f0 * [1, 2^(new_voice_st(1)/12)];
        trial.ser = options.test.voices(trial.ref_voice).ser * [1, 2^(new_voice_st(2)/12)];
        
        ifc = randperm(size(options.f0_contours, 1));
        trial.f0_contours = options.f0_contours(ifc(1:3), :);
        
        isyll = randperm(length(options.syllables));
        for i_int=1:3
            trial.syllables{i_int} = options.syllables(isyll(1:options.n_syll));
        end
        
        % Prepare the stimulus
        [xOut, fs, i_correct] = expe_make_stim(options, trial);
        player = {};
        for i=1:length(xOut)
            x = xOut{i}*10^(-options.attenuation_dB/20);
            player{i} = audioplayer([zeros(1024*3, 2); x; zeros(1024*3, 2)], fs, 16);
            fprintf('Interval %d max: %.2f\n', i, max(abs(x(:))));
        end
        
        isi = audioplayer(zeros(floor(.2*fs), 2), fs);
        
        pause(.5);
        
        % Play the stimuli
        for i=1:length(xOut)
            playblocking(player{i});
            if i~=length(xOut)
                playblocking(isi);
            end
        end
        
        tic();

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
        response.button_correct = i_correct;
        response.button_clicked = i_clicked;
        response.correct = (response.button_clicked == response.button_correct);
        response_correct = [response_correct, response.correct];
        decision_vector  = [decision_vector,  response.correct];
        response.condition = condition;
        response.condition.u = u;
        response.trial = trial;
        response.trial.v = difference*u;
        
        fprintf('Difference    : %.1f st (%.1f st GPR, %.1f st VTL)\n', difference, difference*u(1), difference*u(2));
        fprintf('Correct button: %d\n', i_correct);
        fprintf('Clicked button: %d\n', i_clicked);
        fprintf('Response time : %d ms\n', round(response.response_time*1000));
        fprintf('Time since beginning of run    : %s\n', datestr(response.timestamp-beginning_of_run, 'HH:MM:SS.FFF'));
        fprintf('Time since beginning of session: %s\n', datestr(response.timestamp-beginning_of_session, 'HH:MM:SS.FFF'));

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
        
        % Prepare the parameters for the next trial
        if length(decision_vector)>=options.(phase).down_up(1) && all(decision_vector(end-(options.(phase).down_up(2)-1):end)==1)
            % The last n_down responses were correct -> Reduce
            % difference by step_size, then update step_size
            
            fprintf('--> Where going down by %f st\n', step_size);
            
            difference = difference - step_size;
            steps = [steps, -step_size];
            differences = [differences, difference];
            
            % Reset decision vector
            decision_vector = [];
                
            
        elseif length(decision_vector)>=options.(phase).down_up(2) && all(decision_vector(end-(options.(phase).down_up(2)-1):end)==0)
            % The last n_up responses were incorrect -> Increase
            % difference by step_size.
            
            fprintf('--> Where going up by %f st\n', step_size);
            
            difference = difference + step_size;
            steps = [steps, step_size];
            differences = [differences, difference];
            
            % Reset decision vector
            decision_vector = [];
                
        else
            % Not going up nor down
            
            fprintf('--> Where going neither down nor up\n');
            
            steps = [steps, 0];
            differences = [differences, difference];
            
        end
        
        % Update step_size
        if difference <= options.(phase).change_step_size_condition*step_size ...
                        || mod(length(differences), options.(phase).change_step_size_n_trials)==0
            fprintf('--> Step size is getting updated: was %f st', step_size);
            step_size = step_size * options.(phase).step_size_modifier;
            fprintf(', is now %f st\n', step_size);
        end
        
        nturns = sum(diff(sign(steps(steps~=0)))~=0);
        
        % Have we reached an exit condition?
        if nturns >= options.(phase).terminate_on_nturns 
            
            fprintf('====> END OF RUN because enough turns\n');
            
            results.( phase ).conditions(i_condition).att(n_attempt).exit_reason = 'nturns';
            expe.( phase ).conditions(i_condition).done = 1;
            expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;
            
            i_nz = find(steps~=0);
            i_d  = find(diff(sign(steps(i_nz)))~=0);
            i_tp = i_nz(i_d)+1;
            i_tp = [i_tp, length(differences)];
            i_tp = i_tp(end-(options.(phase).threshold_on_last_n_trials-1):end);

            results.( phase ).conditions(i_condition).att(n_attempt).diff_i_tp = i_tp;
            thr = mean(differences(i_tp)); %exp(mean(log(differences(i_tp))));
            results.( phase ).conditions(i_condition).att(n_attempt).threshold = thr;
            sd = std(differences(i_tp));
            results.( phase ).conditions(i_condition).att(n_attempt).sd = sd;
            
            fprintf('Threshold: %f st (%f st GPR, %f st VTL) [%f st] \n', thr, thr*u(1), thr*u(2), sd);
            
            break
            
        elseif length(response_correct) >= options.(phase).terminate_on_ntrials
            
            fprintf('====> END OF RUN because too many trials\n');
            
            results.( phase ).conditions(i_condition).att(n_attempt).exit_reason = 'ntrials';
            expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;
            
            % Should we retry again?
            if expe.( phase ).conditions(i_condition).attempts >= options.(phase).retry + 1
                fprintf('      (will not try again)\n');
                expe.( phase ).conditions(i_condition).done = 1;
            end
            
            results.( phase ).conditions(i_condition).att(n_attempt).diff_i_tp = [];
            results.( phase ).conditions(i_condition).att(n_attempt).threshold = NaN;
            results.( phase ).conditions(i_condition).att(n_attempt).sd = NaN;
            
            break
        elseif length(response_correct) >= options.(phase).change_step_size_n_trials ...
                && all(response_correct(end-(options.(phase).change_step_size_n_trials-1):end)==0)
            % All last n trials are incorrect
            
            fprintf('====> END OF RUN because too many wrong answers\n');
            
            results.( phase ).conditions(i_condition).att(n_attempt).exit_reason = 'nwrong';
            expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;
            
            % Should we retry again?
            if expe.( phase ).conditions(i_condition).attempts >= options.(phase).retry + 1
                fprintf('      (will not try again)\n');
                expe.( phase ).conditions(i_condition).done = 1;
            end
            
            break
        end
        
        results.( phase ).conditions(i_condition).att(n_attempt).differences = differences;
        results.( phase ).conditions(i_condition).att(n_attempt).steps = steps;
        
        % Save the response
        save(options.res_filename, 'options', 'expe', 'results')
        
        % DEBUG
        if DEBUG
            figure(98)
            set(gcf, 'Position', [50, 350, 500, 500]);
            x = 1:length(differences)-1;
            y = differences(1:end-1);
            plot(x, y, '-b')
            hold on
            plot(length(differences)+[-1 0], differences(end-1:end), '--b')
            plot(x(response_correct==1), y(response_correct==1), 'ob')
            plot(x(response_correct==0), y(response_correct==0), 'xb')
            
            hold off
        end
        
    end
    %---------- End of adaptive loop
    
    % Find indices of turning-points
    %{
    i_nz = find(steps~=0);
    i_d  = find(diff(sign(steps(i_nz)))~=0);
    i_tp = i_nz(i_d)+1;
    %}
    
    
    
    
    
    %============================== DEBUG
    if DEBUG && strcmp(phase, 'training')==0
        figure()
        set(gcf, 'Position', [550, 350, 700, 500]);
        subplot(1, 2, 1)
        x = 1:length(differences)-1;
        y = differences(1:end-1);
        plot(x, y, '-b')
        hold on
        plot(length(differences)+[-1 0], differences(end-1:end), '--b')
        plot(x(response_correct==1), y(response_correct==1), 'ob')
        plot(x(response_correct==0), y(response_correct==0), 'xb')
        
        plot(i_tp, differences(i_tp), 'sr')
        
        plot([i_tp(1), i_tp(end)], [1 1]*thr, '--k');

        hold off
        title(sprintf('Condition %d', i_condition));
        
        subplot(1, 2, 2)
        plot([options.test.voices(condition.ref_voice).f0, options.test.voices(condition.dir_voice).f0], ...
                [options.test.voices(condition.ref_voice).ser, options.test.voices(condition.dir_voice).ser], '--b')
        hold on
        plot(options.test.voices(condition.ref_voice).f0, options.test.voices(condition.ref_voice).ser, 'ob')
        plot(options.test.voices(condition.dir_voice).f0, options.test.voices(condition.dir_voice).ser, 'sr')
        for i_resp=1:length(results.( phase ).conditions(i_condition).att(n_attempt).responses)
            if results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).correct
                plot(results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.f0(2), ...
                    results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.ser(2), 'xk')
            else
                plot(results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.f0(2), ...
                    results.( phase ).conditions(i_condition).att(n_attempt).responses(i_resp).trial.ser(2), '+', 'Color', [1 1 1]*.5)
            end
        end
        
        for i_sp=1:length(options.test.voices)
            plot(options.test.voices(i_sp).f0, options.test.voices(i_sp).ser, '+g');
        end
        
        hold off
        
    end 
        
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
    
    h.show_instruction();
    h.set_instruction(sprintf('Done!'));
    
    % Wait a bit before to go to next condition
    pause(1);
    %starting = true;
    
end

% If we're out of the loop because the phase is finished, tell the subject
if mean([expe.( phase ).conditions.done])==1
    %msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
    questdlg2(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),h,'OK','OK');
end

close(h.f);

%--------------------------------------------------------------------------
function report_status(subj, phase, i, n, logFile)

try
    fd = fopen(logFile, 'w');
    fprintf(fd, '%s : %s : %d/%d\r\n', subj, phase, i, n);
    fclose(fd);
catch ME
    % Stay silent if it failed
end
