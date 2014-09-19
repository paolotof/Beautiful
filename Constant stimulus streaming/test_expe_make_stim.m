

[expe, options] = expe_build_conditions();

trial = expe.test.trials(1);
trial.f0 = [100, 240];
trial.ser = [1, 1.2];


[x, fs] = expe_make_stim(options, trial);

sound(x, fs);