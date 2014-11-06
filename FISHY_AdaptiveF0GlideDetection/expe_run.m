function expe_run(subject, phase)
% expe_run('subject', 'training')
% expe_run(subject, phase)
%   phase can be: 'training', 'test'

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl>
% University Medical Center Groningen, NL
% 2014-04-24
%--------------------------------------------------------------------------

options = struct();
options = expe_options(options);

options.subject_name  = subject;

%-------------------------------------------------
% Set appropriate path

current_dir = fileparts(mfilename('fullpath'));
added_path  = {};

added_path{end+1} = '../lib/SpriteKit';

for i=1:length(added_path)
    addpath(added_path{i});
end

%-------------------------------------------------

% Create result dir if necessary
if ~exist(options.result_path, 'dir')
    mkdir(options.result_path);
end

res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, subject));
options.res_filename = res_filename;

if ~exist(res_filename, 'file')
    opt = char(questdlg(sprintf('The subject "%s" doesn''t exist. Create it?', subject),'TGD','OK','Cancel','OK'));
    switch lower(opt)
        case 'ok',
            expe_build_conditions(options);
        case 'cancel'
            return
        otherwise
            error('Unknown option: %s',opt)
    end
else
    opt = char(questdlg(sprintf('Found "%s". Use this file?', res_filename),'TGD','OK','Cancel','OK'));
    if strcmpi(opt, 'Cancel')
        return
    end
end

% expe_main(options, phase);
fishyMain(options, phase);


%------------------------------------------
% Clean up the path

for i=1:length(added_path)
    rmpath(added_path{i});
end
