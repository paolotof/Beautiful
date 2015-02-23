function [expe, options] = repeatOrStop(phase, options)
% EG: Note that these are displayed on the experimenter's screen

    oldimage = get(0,'DefaultImageVisible');
    set(0, 'DefaultImageVisible','off')
    button = questdlg(sprintf('The "%s" phase is finished.\n would you like to repeat it?', strrep(phase, '_', ' ')),'','Yes','No', 'Yes');
    
    set(0,'DefaultImageVisible',oldimage)
%     set(0, 'DefaultImageVisible','on')
    
    if strcmp(button, 'No')
        msgbox('OK, ciaociao')
        close(gcf);
        expe = [];
        options = [];
        
    else
        uiwait(msgbox('New stimuli are generating ## New structures will be saved'))
%         res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
        % check how many files are there and add number of attempt accordingly
        filesList = dir(fullfile(options.result_path, sprintf('*%s*.mat', options.subject_name)));
        options.subject_name = sprintf('%s_%d', options.subject_name, length(filesList)+1); 
        res_filename = fullfile(options.result_path, sprintf('%s%s.mat', options.result_prefix, options.subject_name));
        options.res_filename = res_filename;
        [expe, options] = expe_build_conditions(options); 
    end
end
