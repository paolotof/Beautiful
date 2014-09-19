function [x, fs] = expe_make_stim(options, trial)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk>
% 2010-03-16, 2011-10-20
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%--------------------------------------------------------------------------

warning('off', 'MATLAB:interp1:NaNinY');

x = [];

vsq = {'', ''};

for i=1:length(trial.syllables)
    
    k = mod(i+trial.start_with_standard,2)+1;
    
    [y, fs] = straight_process(trial.syllables{i}, trial.f0(k), trial.ser(k), ...
        options.syllable_duration, options);
    
    vsq{k} = sprintf('%s%4s    ', vsq{k}, trial.syllables{i});
    
    if fs~=options.fs
        y = resample(y, options.fs, fs);
        fs = options.fs;
    end
    
    dl = round(options.syllable_duration*fs) - length(y);
    if dl>0
        npad_L = floor(dl/20);
        npad_R = dl-npad_L;
        nr = floor(1e-3*fs);
        y(1:nr) = y(1:nr) .* linspace(0, 1, nr)';
        y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr)';
        y = [zeros(npad_L,1); y; zeros(npad_R,1)];
    elseif dl<0
        y = y(1:end+dl);
        nr = floor(1e-3*fs); % 1 ms linear ramp at the end
        y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr)';
    else
        nr = floor(1e-3*fs);
        y(1:nr) = y(1:nr) .* linspace(0, 1, nr)';
        y(end-nr+1:end) = y(end-nr+1:end) .* linspace(1, 0, nr)';
    end 
    
    x = [x; y];
    
    if i~=length(trial.syllables)
        x = [x; zeros(floor(fs*options.inter_syllable_silence), 1)];
    end
end

k = mod(1+trial.start_with_standard,2)+1;
fprintf('F0: %5.1f Hz, SER: %4.2f -- %s\n', trial.f0(k), trial.ser(k), vsq{k});
k = mod(2+trial.start_with_standard,2)+1;
fprintf('F0: %5.1f Hz, SER: %4.2f --     %s\n\n', trial.f0(k), trial.ser(k), vsq{k});

if ~isnan(options.lowpass)
    [b, a] = butter(4, options.lowpass*2/fs, 'low');
    x = filtfilt(b, a, x);
end

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

warning('on', 'MATLAB:interp1:NaNinY');

%--------------------------------------------------------------------------
function fname = make_fname(wav, f0, ser, d, destPath)

[~, name, ext] = fileparts(wav);

fname = sprintf('%s_GPR%d_SER%.2f_D%d', name, floor(f0), ser, floor(d*1e3));
fname = fullfile(destPath, [fname, ext]);

%--------------------------------------------------------------------------
function [y, fs] = straight_process(syll, t_f0, ser, d, options)

wavIn = fullfile(options.sound_path, [syll, '.wav']);
wavOut = make_fname(wavIn, t_f0, ser, options.syllable_duration, options.tmp_path);

if ~exist(wavOut, 'file') || options.force_rebuild_sylls
    
    global LIBRARY_PATH
    straight_path = fullfile(LIBRARY_PATH, 'STRAIGHTV40_006b');
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

    %f0(f0~=0) = f0(f0~=0) / mf0 * t_f0;
    f0(f0~=0) = .5*t_f0 + .5*(f0(f0~=0) / mf0 * t_f0); % Reduced dynamic

    p.timeAxisMappingTable = (d*1e3)/length(f0);
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

