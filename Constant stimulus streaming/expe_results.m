function [f0s, sers, m] = expe_results(subj)

options = expe_options();

if nargin==0
    lst = dir(fullfile(options.result_path, [options.result_prefix, '*.mat']));
    lst = {lst(:).name};
else
    if ~iscell(subj)
        subj = {subj};
    end
    lst = {};
    for i=1:length(subj)
        lst{i} = sprintf([options.result_prefix, '%s.mat'], subj{i});
    end
end

for i=1:length(lst)
    load(fullfile(options.result_path, lst{i}));
    
    if i==1
        f0s  = options.test.f0s;
        sers = options.test.sers;
        
        V = zeros(length(f0s), length(sers), length(lst));
    end
        
    v = zeros(length(f0s), length(sers));
    n = zeros(length(f0s), length(sers));

    for k=1:length(results.test.responses)

        r = results.test.responses(k);

        v(f0s==r.trial.f0(2), sers==r.trial.ser(2)) = v(f0s==r.trial.f0(2), sers==r.trial.ser(2)) + r.correct;
        n(f0s==r.trial.f0(2), sers==r.trial.ser(2)) = n(f0s==r.trial.f0(2), sers==r.trial.ser(2)) + 1;

    end
    
    v = v./n;
    v(n==0) = NaN;
    
    V(:,:,i) = v;
    
end

m = nanmean(V,3)';
e = nanstd(V, 0, 3);

%----
subplot(3, 3, [2, 3, 5, 6])
pcolor(f0s, sers, m)
shading interp

%---
subplot(3, 3, [1,4])
ms = nanmean(nanmean(V, 1),3);
es = nanstd(nanmean(V, 1),0,3);
plot(ms+es, sers, '-', 'Color', [.6, .6, 1])
hold on
plot(ms-es, sers, '-', 'Color', [.6, .6, 1])
plot(ms, sers, '-ob')
hold off
ylabel('1/VTL (ratio)')
xlim([-.05, 1.05])
set(gca, 'XDir', 'reverse')

%---
subplot(3, 3, [8,9])
ms = nanmean(nanmean(V, 2),3);
es = nanstd(nanmean(V, 2),0,3);
plot(f0s, ms+es, '-', 'Color', [.6, .6, 1])
hold on
plot(f0s, ms-es, '-', 'Color', [.6, .6, 1])
plot(f0s, ms, '-ob')
hold off
xlabel('F0 (Hz)')
ylim([-.05, 1.05])

