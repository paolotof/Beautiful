function [startTime, i_correct] = nextTrial(options, phase, expe)

    % Find first condition not done
    i_condition = find([expe.( phase ).conditions.done]==0, 1);
    condition = expe.( phase ).conditions(i_condition);
    %  ---- Adaptive Procedure ----  %
    difference = condition.starting_glide_size;
%     differences = [difference]; % Glide sizes
    [startTime, i_correct] = playSounds(options, condition, difference);

     
end % end of nextTrial function
