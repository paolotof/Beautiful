function [expe, options] = expe_build_conditions(options)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk>
% 2010-03-15, 2011-10-20
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%--------------------------------------------------------------------------


options.instructions.training = ['You are going to hear three triplets of different syllables.\nOne of the triplets is said with a different voice.\n'...
    'Your task is to click on the button that corresponds to the different voice.\n\n'...
    '-------------------------------------------------\n\n'...
    ''];

options.instructions.test = options.instructions.training;

test_machine = is_test_machine();

%----------- Signal options
options.fs = 44100;
if test_machine
    options.attenuation_dB = 3; % General attenuation
else
    options.attenuation_dB = 27; % General attenuation
end
options.ear = 'both'; % right, left or both

%----------- Design specification
options.test.n_repeat = 10; % Number of repetition per condition
options.training.n_repeat = 1;

%----------- Stimuli options
options.test.f0_target = [0]; % Delta F0 relative to recorded voice in semitones
options.test.vtl_target = [0]; % Same for VTL
options.test.f0_masker = [0, 6, 12]; % Delta F0 relative to target in semitones
options.test.vtl_masker = [0, -1.8, -3.6]; % Same for VTL

options.training.f0_target = [0];
options.training.vtl_target = [0];
options.training.f0_masker = [options.test.f0_masker(1), options.test.f0_masker(end)];
options.training.vtl_masker = [options.test.vtl_masker(1), options.test.vtl_masker(end)];

if test_machine
    options.sound_path = '../Sounds/stimuli/sentences NL VU/Spraak';
    options.tmp_path   = './processed';
else
    disp('-------------------------');
    disp('--- On coding machine ---');
    disp('-------------------------');
    options.sound_path = '~/Sounds/stimuli/sentences NL VU/Spraak';
    options.tmp_path   = './processed';
end

if ~exist(options.tmp_path, 'dir')
    mkdir(options.tmp_path);
end 

options.n_sentences = 507;

%--- Vocoder options

addpath('./vocoder_2013');

% Base parameters
p = struct();
p.envelope = struct();
p.envelope.method = 'low-pass';
p.envelope.rectify = 'half-wave';
p.envelope.order = 2;

p.synth = struct();
p.synth.carrier = 'noise';
p.synth.filter_before = false;
p.synth.filter_after  = true;
p.synth.f0 = 1;

p.envelope.fc = 300;

%p.random_seed = 1;

nc = 8;
p.analysis_filters  = filter_bands([150, 7000], nc, options.fs, 'greenwood', vo, 0);
p.synthesis_filters = filter_bands([150, 7000], nc, options.fs, 'greenwood', vo, shift);

options.vocoder(1).label = 'noise';
options.vocoder(1).description = 'Noise-band vocoder';
options.vocoder(1).parameters = p;


%==================================================== Build test block

test = struct();

for ir = 1:options.test.n_repeat
    for i_voc = 1:length(options.test.vocoder)
        for i_f0T = 1:length(options.test.f0_target)
            for i_vtlT = 1:length(options.test.vtl_target)
                for i_f0M = 1:length(options.test.f0_masker)
                    for i_vtlM = 1:length(options.test.vtl_masker)
                        
                        trial = struct();
                        
                        trial.f0_target  = options.test.f0_target(i_f0T);
                        trial.vtl_target = options.test.vtl_target(i_vtlT);
                        trial.f0_masker  = options.test.f0_masker(i_f0M);
                        trial.vtl_masker = options.test.vtl_masker(i_vtlM);

                        trial.vocoder = i_voc;

                        trial.visual_feedback = 1;

                        % Do not remove these lines
                        trial.done = 0;

                        if ~isfield(test,'trials')
                            test.trials = orderfields(trial);
                        else
                            test.trials(end+1) = orderfields(trial);
                        end
                        
                    end
                end
            end
        end
    end
end

% Randomization of the order
%options.n_blocks = length(test.conditions)/options.test.block_size;
test.trials = test.trials(randperm(length(test.trials)));

%================================================== Build training block

training = struct();

% DO THE SAME FOR TRAINING...

%====================================== Create the expe structure and save

expe.test = test;
expe.training = training;

%--
                
if isfield(options, 'res_filename')
    save(options.res_filename, 'options', 'expe');
else
    warning('The test file was not saved: no filename provided.');
end



