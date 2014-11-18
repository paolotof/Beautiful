function [difference, differences, decision_vector, step_size, steps, countUpdates, swimming] = ... 
    setNextTrial(options, difference, differences, decision_vector, step_size, steps, phase, countUpdates)

    if length(decision_vector)>=options.(phase).down_up(1) && all(decision_vector(end-(options.(phase).down_up(2)-1):end)==1)
        % The last n_down responses were correct -> Reduce
        % difference by step_size, then update step_size
        fprintf('--> DOWN by %f st\n', step_size);

        difference = difference - step_size;
        steps = [steps, -step_size];
        differences = [differences, difference];

        % Reset decision vector
        decision_vector = [];

        % here you should make something like the animal swimming toward
        % the friend and add 3 new friends
        countUpdates = countUpdates + 1;
        swimming = true;
        
    elseif length(decision_vector)>=options.(phase).down_up(2) && all(decision_vector(end-(options.(phase).down_up(2)-1):end)==0)
        % The last n_up responses were incorrect -> Increase
        % difference by step_size.

        fprintf('--> UP by %f st\n', step_size);

        difference = difference + step_size;
        steps = [steps, step_size];
        differences = [differences, difference];

        % Reset decision vector
        decision_vector = [];
        
        % add 3 new friends.
        countUpdates = countUpdates + 1;
%         updateFriend(gameSize, elOne, elTwo, elThree, friendsID{mod(countUpdates, length(friendsID))});
        swimming = false;
    else
        % Not going up nor down
        fprintf('--> STABLE\n');
        steps = [steps, 0];
        differences = [differences, difference];
        swimming = false;
    end

    % Update step_size
    if difference <= options.(phase).change_step_size_condition*step_size ...
            || mod(length(differences), options.(phase).change_step_size_n_trials)==0
        fprintf('--> Step size is getting updated: was %f st', step_size);
        step_size = step_size * options.(phase).step_size_modifier;
        fprintf(', is now %f st\n', step_size);
    end
    
end

