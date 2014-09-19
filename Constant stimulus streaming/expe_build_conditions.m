function [expe, options] = expe_build_conditions(options)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk>
% 2010-03-15, 2011-10-20
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%--------------------------------------------------------------------------

%{
options.instructions.training = ['You are going to hear some sentences.\n\nYour job is to listen to what ‘Baron’ has to do.\n‘Baron’ is an old-fashioned name.\n'...
    'He will be told to go to a colour and a number.\n\n'...
    'Remember, pretend your name is ‘Baron’ and listen carefully to find out what colour and number to click on.'];
%}

options.instructions.test = ['You are going to hear a sequence of syllables.\n\n'...
    'One syllable is repeated, and you''ll have to indicate which one.'];

%options.instructions.training_2 = [options.instructions.test, ' You will get some practice first, then you will have a chance to ask questions again if you want.'];

%---------- GUI options
options.n_rows = 2;
options.n_cols = 3;

%----------- Signal options
options.fs = 44100;
options.attenuation_dB = 27; % General attenuation
options.ear = 'both'; % right, left or both

%----------- Design specification
options.test.n_repeat = 4; % Number of repetition per condition
options.test.block_size = 32; % Number of trial before "have a break" message
options.training.n_repeat = 1;
options.training.block_size = options.test.block_size;

%----------- Stimuli options

%{
options.test.f0s = 210*2.^([0, -5, -10, -15]/12);
options.test.sers = 2.^(linspace(0, -5, 4)/12);

options.sound_path = '~/Sounds/Dutch_CV/equalized';
options.tmp_path   = './processed';
%}

options.test.f0s = 100*2.^([0:5:15]/12);
options.test.sers = 2.^(linspace(-.5, 4.5, 4)/12);

options.sound_path = '~/Sounds/cv_short';
options.tmp_path   = '~/Sounds/cv_short/processed';

if ~exist(options.tmp_path, 'dir')
    mkdir(options.tmp_path);
end 

dir_waves = dir([options.sound_path, '/*.wav']);
syllable_list = {dir_waves.name};
for i= 1:length(syllable_list)
    syllable_list{i} = strrep(syllable_list{i}, '.wav', '');
end

options.syllables = syllable_list;
options.n_syll = 30;
options.rep_min_index = options.n_syll-9;
options.rep_max_index = options.n_syll-2;
options.inter_syllable_silence = 30e-3;
options.syllable_duration = 180e-3;

options.lowpass = 4000;

options.force_rebuild_sylls = 0;

%==================================================== Build test block

% Modify this part to create the specific conditions you want

test = struct();

for ir = 1:options.test.n_repeat
    
    for f0 = options.test.f0s
        
        for ser = options.test.sers
    
            trial = struct();

            trial.f0 = [options.test.f0s(1), f0];
            trial.ser = [options.test.sers(1), ser];
            trial.start_with_standard = randi(2)-1;

            [trial.syllables, trial.proposed_syll] = get_syllable_sequence(options.syllables, options.n_syll, options.rep_min_index, options.rep_max_index, options.n_rows*options.n_cols);
            
            % Order of the buttons
            trial.syll_order = randperm(options.n_rows*options.n_cols);
            
            trial.visual_feedback = 1;

            % Do not remove these lines
            trial.i_repeat = ir;
            trial.done = 0;

            if ~isfield(test,'trials')
                test.trials = orderfields(trial);
            else
                test.trials(end+1) = orderfields(trial);
            end
            
        end
        
    end

end

% Randomization of the order
options.n_blocks = length(test.trials)/options.test.block_size;
test.trials = test.trials(randperm(length(test.trials)));

%================================================== Build training 1 block

%{

% Here the training block is just a copy of the test block
training_1 = struct();

for ir = 1:options.training_1.n_repeat
    
    for i_speaker = 1:4
            
        for t_speaker = 'MF'

            if t_speaker=='M'
                m_speaker = 'F';
            else
                m_speaker = 'M';
            end

            trial = struct();

            trial.target.speaker = sprintf('%s%d', t_speaker, i_speaker);
            trial.target.colour  = randpick(options.target.colours);
            trial.target.number  = randpick(options.target.numbers);
            trial.target.call_sign = randpick(options.target.call_signs);

            trial.masker.type = 'speech'; % Won't matter because Inf TMR

            trial.masker.speaker = sprintf('%s%d', m_speaker, 1);
            % We pick a colour and number for the masker that are
            % different from the ones chosen for the target
            trial.masker.colour  = randpick(options.masker.colours, trial.target.colour);
            trial.masker.number  = randpick(options.masker.numbers, trial.target.number);
            trial.masker.call_sign = randpick(options.masker.call_signs);

            trial.tmr = Inf;

            trial.visual_feedback = 1;
            trial.audio_feedback  = 0;
            trial.pause_when_wrong = 0;

            % Do not remove these lines
            trial.i_repeat = ir;
            trial.done = 0;

            if ~isfield(training_1,'trials')
                training_1.trials = orderfields(trial);
            else
                training_1.trials(end+1) = orderfields(trial);
            end

        end
    end

end

%training_1.trials = training.trials(randperm(length(training.trials)));

%================================================== Build training 2 block

training_2 = struct();

for ir = 1:options.training_2.n_repeat
    
    for t_speaker = 'MF'

        if t_speaker=='M'
            m_speaker = 'F';
        else
            m_speaker = 'M';
        end

        for i_mtype = 1:2

            trial = struct();

            trial.target.speaker = sprintf('%s%d', t_speaker, randint(4));
            trial.target.colour  = randpick(options.target.colours);
            trial.target.number  = randpick(options.target.numbers);
            trial.target.call_sign = randpick(options.target.call_signs);

            trial.masker.type = options.masker_types{i_mtype};

            trial.masker.speaker = sprintf('%s%d', m_speaker, randint(4));
            % We pick a colour and number for the masker that are
            % different from the ones chosen for the target
            trial.masker.colour  = randpick(options.masker.colours, trial.target.colour);
            trial.masker.number  = randpick(options.masker.numbers, trial.target.number);
            trial.masker.call_sign = randpick(options.masker.call_signs);

            trial.tmr = 4;

            trial.visual_feedback = 1;
            trial.audio_feedback  = 0;
            trial.pause_when_wrong = 1;

            % Do not remove these lines
            trial.i_repeat = ir;
            trial.done = 0;

            if ~isfield(training_2,'trials')
                training_2.trials = orderfields(trial);
            else
                training_2.trials(end+1) = orderfields(trial);
            end

        end

    end
        
end
%}

%====================================== Create the expe structure and save

expe.test = test;
% expe.training_1 = training_1;
% expe.training_2 = training_2;
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
else
    warning('The test file was not saved: no filename provided.');
end
