function [xOut, fs, i_correct] = expe_make_stim(options, trial)

% Generate the stimuli (steady and gliding tone)

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl>
% University Medical Center Groningen, NL
% 2014-04-24
%--------------------------------------------------------------------------

xOut = {};
fs = options.fs;

%t = (0:round(options.fs*options.duration))/options.fs;

for i = 1 : options.n_intervals
    
    if i==1 % This is the one with a glide
        f = trial.glide_size*[-1, 1]/2+trial.base_freq;
    else % this is the default (flat)
        f = trial.base_freq*[1 1];
    end
    
    f = linspace(f(1), f(2), round(fs*options.duration))';
    x = .9*sin(2*pi*cumsum(f)/fs);
    
    % Ramping
    x = cosgate(x, fs, options.ramps);
    
    switch options.ear
        case 'right'
            x  = [zeros(size(x)), x];
        case 'left'
            x = [x, zeros(size(x))];
        case 'both'
            x = repmat(x, 1, 2);
        otherwise
            error(sprintf('options.ear="%s" is not implemented', options.ear));
    end
    
    xOut{i} = x;
end

%rng('shuffle');

i_order = randperm(length(xOut));
xOut = xOut(i_order);

i_correct = find(i_order==1);



