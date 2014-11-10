

options = expe_options();
[expe, options] = expe_build_conditions(options);

options.inter_syllable_silence = 50e-3;

trial = expe.test.conditions(1);
ifc = randperm(size(options.f0_contours, 1));
trial.f0_contours = options.f0_contours(ifc(1:3), :);

isyll = [3, 14, 23]; %randperm(length(options.syllables));
for i_int=1:3
    %trial.syllables{i_int} = options.syllables(isyll(((i_int-1)*options.n_syll+(1:options.n_syll))));
    trial.syllables{i_int} = options.syllables(isyll(1:options.n_syll));
end

trial.syllables{1}

for i=1:1 %length(options.test.voice_pairs)

    trial.f0 = [options.test.voices(options.test.voice_pairs(i,1)).f0, options.test.voices(options.test.voice_pairs(i,2)).f0];
    trial.ser = [options.test.voices(options.test.voice_pairs(i,1)).ser, options.test.voices(options.test.voice_pairs(i,2)).ser];

    for j=1:length(options.vocoder)
        trial.vocoder = j;
        
        [x, fs, i_correct] = expe_make_stim(options, trial);

        s = zeros(floor(.250*fs),2);
        %wavwrite(mean([x{2}; s; x{1}; s; x{3}],2), fs, sprintf('Demo_jvo_%d_%s.wav', i, voc_suff));
        wavwrite(mean(x{i_correct},2), fs, sprintf('Demo_jvo_%s_voc%d.wav', options.test.voices(options.test.voice_pairs(i,2)).label, j));
        figure(j)
        n = 1024*2;
        [S, F, T, P] = spectrogram(mean(x{i_correct},2), hann(n), floor(n*.75), n, fs);
        plot(F, 10*log10(mean(P(:,:), 2)));
        xlim([50, 8000]);
        title(options.vocoder(j).label)
        %k = 1:length(x);
        %k = k(k~=i_correct);
        %wavwrite(mean(x{k(1)},2), fs, sprintf('Demo_jvo_%s_voc%d.wav', options.test.voices(options.test.voice_pairs(i,1)).label, j));
    end
    
end
