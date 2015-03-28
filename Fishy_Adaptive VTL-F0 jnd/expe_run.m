function expe_run(varargin)

% expe_run('subject', 'training', 'English')
% expe_run(subject, phase)
%   phase can be: 'training', 'test'
%   language should be 'Dutch', 'English'

    if nargin == 0
        subject = 'subject';
        phase = 'training';
        language = 'English';
    else
        subject = varargin{1};
        phase = varargin{2};
        language = varargin{3};
    end


options = struct();
options.language = language;
options = expe_options(options);

options.subject_name  = subject;

%-------------------------------------------------

% current_dir = fileparts(mfilename('fullpath'));
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

res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
options.res_filename = res_filename;

if ~exist(res_filename, 'file')
    opt = char(questdlg(sprintf('The subject "%s" doesn''t exist. Create it?', subject),'JVO','OK','Cancel','OK'));
    switch lower(opt)
        case 'ok',
            [expe, options] = expe_build_conditions(options);
        case 'cancel'
            return
        otherwise
            error('Unknown option: %s',opt)
    end
else
    opt = questdlg(sprintf('Found "%s". Use this file?', res_filename),'JVO','OK','Cancel','No','OK');
    switch opt 
        case 'OK'
            tmp = load(options.res_filename); % options, expe, results
            results = tmp.results;
            options = tmp.options;
            expe = tmp.expe;
        case 'Cancel'
            return
        case 'No'
            opt = questdlg(sprintf('The result file %s will deleted!\n Are you sure?', res_filename),'Warning','Yes','No','No');
            switch opt 
                case 'Yes'
                    delete(res_filename)
                    [expe, options] = expe_build_conditions(options);
                case 'No'
                    return
            end

    end
   
end

expe_main(expe, options, phase);

results2txt

%------------------------------------------
% Clean up the path

for i=1:length(added_path)
    rmpath(added_path{i});
end
