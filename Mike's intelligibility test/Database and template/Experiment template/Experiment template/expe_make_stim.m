function [xOut, fs, sentence_correct] = expe_make_stim(options, trial)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk>
% 2010-03-16, 2011-10-20
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%--------------------------------------------------------------------------

...

%--------------------------------------------------------------------------
function fname = make_fname(wav, f0, ser, d, destPath)

[~, name, ext] = fileparts(wav);

if isnan(d)
    fname = sprintf('%s_GPR%d_SER%.2f', name, floor(f0), ser);
else
    fname = sprintf('%s_GPR%d_SER%.2f_D%d', name, floor(f0), ser, floor(d*1e3));
end
fname = fullfile(destPath, [fname, ext]);
    

%--------------------------------------------------------------------------
function [y, fs] = straight_process(syll, t_f0, ser, options)

wavIn = fullfile(options.sound_path, [syll, '.wav']);
wavOut = make_fname(wavIn, t_f0, ser, options.syllable_duration, options.tmp_path);

if ~exist(wavOut, 'file') || options.force_rebuild_sylls
    
    if is_test_machine()
        straight_path = '../lib/STRAIGHTV40_006b';
    else
        straight_path = '~/Library/Matlab/STRAIGHTV40_006b';
    end
    addpath(straight_path);
    
    mat = strrep(wavIn, '.wav', '.straight.mat');
    
    if exist(mat, 'file')
        load(mat);
    else
        [x, fs] = wavread(wavIn);
        [f0, ap] = exstraightsource(x, fs);
        %old_f0 = f0;
        %f0(f0<80) = 0;

        sp = exstraightspec(x, f0, fs);
        x_rms = rms(x);

        save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
    end
    
    mf0 = exp(mean(log(f0(f0~=0))));

    f0(f0~=0) = f0(f0~=0) / mf0 * t_f0;

    %p.timeAxisMappingTable = (d*1e3)/length(f0);
    p.frequencyAxisMappingTable = ser;
    y = exstraightsynth(f0, sp, ap, fs, p);

    y = y/rms(y)*x_rms;
    if max(abs(y))>1
        warning('Output was renormalized for "%s".', wavOut);
        y = 0.98*y/max(abs(y));
    end
    
    wavwrite(y, fs, wavOut);
    
    rmpath(straight_path);
else
    [y, fs] = wavread(wavOut);
end

