function [expe, options] = expe_build_conditions(options)

%[expe, options] = expe_build_conditions(options)
%   Defines options and conditions for the adaptive procedure.
%   Following description of Globerson et al., 2013, APnP.

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl>
% University Medical Center Groningen, NL
% 2014-04-24
%--------------------------------------------------------------------------

options.instructions.training = [...
    'You are going to hear two tones.\n' ...
    'One tone has a constant pitch, while the other tone has an increasing or decreasing pitch.\n'...
    'Your task is to click on the button that corresponds to the tone with increasing or decreasing pitch.\n\n'...
    '-------------------------------------------------\n\n'...
    ''];

options.instructions.test = options.instructions.training;
options.instructions.task = 'Select the tone which has a changing pitch';

%----------- Signal options
options.fs = 44100;
options.attenuation_dB = 6; % General attenuation (keep small)
options.ear = 'both'; % right, left or both
options.duration = 300e-3; % Tone duration (s)
options.ramps = 25e-3; % Ramp duration (s)
options.isi = 500e-3; % Interstimulus interval

%----------- Design specification
options.button_labels = {'1', '2'};
options.n_intervals = length(options.button_labels); % Intervals in the AFC

options.test.n_repeat = 2; % Number of repetition per condition
options.test.step_size_modifier = 1/2;
options.test.change_step_size_condition = 2; % On each reversal, step size is decreased
options.test.initial_step_size = 40; % Hz
options.test.minimum_step_size = 1; % Hz
options.test.down_up = [2, 1]; % 2-down, 1-up => 70.7%
options.test.terminate_on_nturns = 10; % At final step-size
options.test.terminate_on_ntrials = 150;
options.test.retry = 1; % Number of retry if measure failed
options.test.threshold_on_last_n_reversals = 8; % Threshold will be calculated on these reversals
options.test.visual_feedback = 1;

options.training = options.test;
options.training.n_repeat = 1;
options.training.terminate_on_ntrials = 6;
options.training.retry = 0; % Number of retry if measure failed

%----------- Stimuli options
options.test.base_freqs  = [1000]; % Hz
options.test.starting_glide_sizes = [200]; % Hz

options.training.base_freqs = options.test.base_freqs;
options.training.starting_glide_sizes = options.test.starting_glide_sizes;


%==================================================== Build test block

test = struct();

for ir = 1:options.test.n_repeat
    for i_bf = 1:length(options.test.base_freqs)
        
        condition = struct();

        condition.base_freq = options.test.base_freqs(i_bf);
        condition.starting_glide_size = options.test.starting_glide_sizes(i_bf);

        condition.visual_feedback = options.test.visual_feedback;

        % Do not remove these lines
        condition.i_repeat = ir;
        condition.done = 0;
        condition.attempts = 0;

        if ~isfield(test,'conditions')
            test.conditions = orderfields(condition);
        else
            test.conditions(end+1) = orderfields(condition);
        end

    end
end

% Randomization of the order
%options.n_blocks = length(test.conditions)/options.test.block_size;
test.conditions = test.conditions(randperm(length(test.conditions)));

%================================================== Build training block

training = struct();

for ir = 1:options.training.n_repeat
    for i_bf = 1:length(options.training.base_freqs)
        
        condition = struct();

        condition.base_freq = options.training.base_freqs(i_bf);
        condition.starting_glide_size = options.training.starting_glide_sizes(i_bf);

        condition.visual_feedback = options.training.visual_feedback;

        % Do not remove these lines
        condition.i_repeat = ir;
        condition.done = 0;
        condition.attempts = 0;

        if ~isfield(training,'conditions')
            training.conditions = orderfields(condition);
        else
            training.conditions(end+1) = orderfields(condition);
        end

    end
end

% Randomization of the order
%options.n_blocks = length(training.conditions)/options.training.block_size;
training.conditions = training.conditions(randperm(length(training.conditions)));

%====================================== Create the expe structure and save

expe.test = test;
expe.training = training;

%--
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
else
    warning('The test file was not saved: no filename provided.');
end



