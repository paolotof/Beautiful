function [startTime, i_correct] = playSounds(options, condition, difference)

    % every trial settings
    fprintf('\n------------------------------------ Trial\n');
    
    % Prepare the trial
    trial = condition;
    trial.glide_size = sign(randn(1))*difference;
    
    
    % Prepare the stimulus
    [xOut, fs, i_correct] = expe_make_stim(options, trial);
    player = {};
    for i=1:length(xOut)
        x = xOut{i}*10^(-options.attenuation_dB/20);
        player{i} = audioplayer([zeros(1024*3, 2); x; zeros(1024*3, 2)], fs, 16);
    end
    
    isi = audioplayer(zeros(floor(options.isi*fs), 2), fs);
    
    % pause(.5); if you use this it will stop all the animation
    
    % Play the stimuli
    for i=1:length(xOut)
        playblocking(player{i});
        if i~=length(xOut)
            playblocking(isi);
        end
    end
    
    startTime = now();
%     startTime = tic();% Collect the response
    
end