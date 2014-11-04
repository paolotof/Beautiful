function [player, isi, i_correct] = nextTrial(options, phase, expe)

    % Find first condition not done
%     i_condition = find([expe.( phase ).conditions.done]==0, 1);
%     condition = expe.( phase ).conditions(i_condition);
    % this bit should probably be done somewhere else
    if isempty(find([expe.( phase ).conditions.done]==0, 1))
       uiwait(msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),...
            '','modal'));
        return;
    end


    condition = expe.( phase ).conditions( find([expe.( phase ).conditions.done]==0, 1) );
    %  ---- Adaptive Procedure ----  %
    difference = [condition.starting_glide_size];
%     differences = [difference]; % Glide sizes
    
    % Prepare the trial
    trial = condition;
    trial.glide_size = sign(randn(1))*difference;
    
    
    % Prepare the stimulus
    [xOut, fs, i_correct] = expe_make_stim(options, trial);
    player = {};
    nOuts = length(xOut);
    for i=1 : nOuts
%         x = xOut{i}*10^(-options.attenuation_dB/20);
%         player{i} = audioplayer([zeros(1024*3, 2); x; zeros(1024*3, 2)], fs, 16);
        player{i} = audioplayer([zeros(1024*3, 2); ...
            xOut{i}*10^(-options.attenuation_dB/20); ...
            zeros(1024*3, 2)], fs, 16);
    end
    
    isi = audioplayer(zeros(floor(options.isi*fs), 2), fs);

end % end of nextTrial function
