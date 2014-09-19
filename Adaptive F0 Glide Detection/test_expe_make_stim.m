

options = expe_options();
[expe, options] = expe_build_conditions(options);

trial = expe.test.conditions(1);
trial.glide_size = 40;

[x, fs, i_correct] = expe_make_stim(options, trial);

for i=1:length(x)
    
    % Waveform
    subplot(2,2,2*(i-1)+1)
    t = (0:size(x{i},1)-1)/fs;
    plot(t*1e3, x{i}, '-k')
    xlabel('Time (ms)')
    
    % Spectrogram
    subplot(2,2,2*(i-1)+2)
    n = 1024*2;
    [S, F, T, P] = spectrogram([zeros(1024,1); mean(x{i},2); zeros(1024*2,1)], hann(n), floor(n*.5), [900:1100], fs);
    hold on
    pcolor((T-1024/fs)*1e3, F, 10*log10(P));
    shading interp;
    
    plot([0, size(x{i},1)+1024-1]/fs*1e3, trial.base_freq*[1 1], ':k');
    plot([0, size(x{i},1)+1024-1]/fs*1e3, trial.base_freq+trial.glide_size*(i==i_correct)*[-1 1]/2, '--k', 'LineWidth', 2);
    hold off

    ylim(1000+[-1 1]*100)
    xlim([0, size(x{i},1)/fs*1e3])

    ylabel('Frequency (Hz)')
    xlabel('Time (ms)')
    
    
end

set(gcf, 'PaperPosition', [0 0 8 4]*2)
print(gcf, '-dpng', '-r200', sprintf('Stimuli.png'));

%sound(x{1}/2, fs);
%sound(x{2}/2, fs);