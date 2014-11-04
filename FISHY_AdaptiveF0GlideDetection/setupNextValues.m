function [options, phase, expe, results, difference, decision_vector, nturns, step_size, steps] = ...
    setupNextValues(options, phase, expe, results, response, difference, response_correct, decision_vector, nturns, step_size, steps)

    i_condition = find([expe.( phase ).conditions.done]==0, 1);
    
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
    differences = [difference]; % Glide sizes % paol8 added this from nextTrial.m line 17
 
    if (length(decision_vector) >= options.(phase).down_up(1)) && (all(decision_vector(end-(options.(phase).down_up(2)-1):end) == 1))
        % The last n_down responses were correct -> Reduce
        % difference by step_size.
        difference = max(options.(phase).minimum_step_size, difference - step_size);
        step_size = differences(end) - difference;
        steps = [steps, -step_size];
        differences = [differences, difference];
        decision_vector = [];% Reset decision vector
    elseif length(decision_vector)>=options.(phase).down_up(2) && all(decision_vector(end-(options.(phase).down_up(2)-1):end)==0)
        % The last n_up responses were incorrect -> Increase
        % difference by step_size.
        difference = difference + step_size;
        steps = [steps, step_size];
        differences = [differences, difference];
        decision_vector = []; % Reset decision vector
    else
        % stable
        steps = [steps, 0];
        differences = [differences, difference];
    end

    new_nturns = sum(diff(sign(steps(steps~=0)))~=0);


    % Update step_size
    %if difference <= options.(phase).change_step_size_condition*step_size ...
    %                || mod(length(differences), options.(phase).change_step_size_n_trials)==0
    if new_nturns > nturns
        fprintf('--> Step size is getting updated: was %.2f Hz', step_size);
        step_size = step_size * options.(phase).step_size_modifier;
        step_size = max(step_size, options.(phase).minimum_step_size);
        fprintf(', is now %.2f Hz\n', step_size);
    end

    nturns = new_nturns;

    nturns_at_min_stepsize = sum(diff(sign(steps(abs(steps)==options.(phase).minimum_step_size)))~=0);

    % Have we reached an exit condition?
    if nturns_at_min_stepsize >= options.(phase).terminate_on_nturns

        fprintf('====> END OF RUN, enough turns\n');

        results.( phase ).conditions(i_condition).att(n_attempt).exit_reason = 'nturns';
        expe.( phase ).conditions(i_condition).done = 1;
        expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;

        % We find the reversals to calculate the threshold
        i_nz = find(abs(steps) == options.(phase).minimum_step_size);
        i_d  = find(diff(sign(steps(i_nz))) ~= 0);
        i_tp = i_nz(i_d) + 1;
        i_tp = [i_tp, length(differences)];
        i_tp = i_tp((end - (options.(phase).threshold_on_last_n_reversals - 1)) : end);

        results.( phase ).conditions(i_condition).att(n_attempt).diff_i_tp = i_tp;
        results.( phase ).conditions(i_condition).att(n_attempt).threshold = mean(differences(i_tp));
        results.( phase ).conditions(i_condition).att(n_attempt).sd = std(differences(i_tp));

    elseif length(response_correct) >= options.(phase).terminate_on_ntrials

        fprintf('====> END OF RUN, too many trials\n');

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

    elseif length(steps)>6 && all(steps(end-5:end)==0)

        fprintf('====> END OF RUN, too easy, floor condition\n');

        results.( phase ).conditions(i_condition).att(n_attempt).exit_reason = 'floor';
        expe.( phase ).conditions(i_condition).attempts = expe.( phase ).conditions(i_condition).attempts + 1;

        % Should we retry again?
        if expe.( phase ).conditions(i_condition).attempts >= options.(phase).retry + 1
            fprintf('      (will not try again)\n');
            expe.( phase ).conditions(i_condition).done = 1;
        end

        results.( phase ).conditions(i_condition).att(n_attempt).diff_i_tp = [];
        results.( phase ).conditions(i_condition).att(n_attempt).threshold = NaN;
        results.( phase ).conditions(i_condition).att(n_attempt).sd = NaN;

    end

    results.( phase ).conditions(i_condition).att(n_attempt).differences = differences;
    results.( phase ).conditions(i_condition).att(n_attempt).steps = steps;

    % Save the response
    save(options.res_filename, 'options', 'expe', 'results')

%---------- End of adaptive loop
    
    % Find indices of turning-points
    %{
    i_nz = find(steps~=0);
    i_d  = find(diff(sign(steps(i_nz)))~=0);
    i_tp = i_nz(i_d)+1;
    %}
   
    
     % Wait a bit before to go to next condition
%     pause(1); % paol8 removed because useless
    %starting = true;
    
    % If we're out of the loop because the phase is finished, tell the subject
    if mean([expe.( phase ).conditions.done])==1
        %msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
%         questdlg2(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),h,'OK','OK');
%         return
        uiwait(msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),...
            '','modal'));
    end
    
end