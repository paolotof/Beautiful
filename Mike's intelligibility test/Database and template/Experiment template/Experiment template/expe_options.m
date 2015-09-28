function options = expe_options(options)

options.result_path   = './results';
options.result_prefix = 'musVocCS_'; % Musician Vocoded Concurrent Speech

% The current status of the experiment, number of trial and phase, is
% written in the log file. Ideally this file should be on the network so
% that it can be checked remotely. If the file cannot be reached, the
% program will just continue silently.
options.log_file = fullfile('results', 'status.txt');

