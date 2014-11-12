function [out] = ready2start(input)
    oldimage = get(0,'DefaultImageVisible');
    set(0, 'DefaultImageVisible','off')
    if isa(input, 'char')
        button = questdlg(sprintf('The "%s" phase is finished. Thank you!', strrep(input, '_', ' ')),'','OK','OK');
    else
        button = questdlg('Ready to Start?','START','Yes','No','Yes');
    end
    set(0,'DefaultImageVisible',oldimage)
%     set(0, 'DefaultImageVisible','on')
    
    out = true;
    if strcmp(button, 'No')
        msgbox('OK, ciaociao')
%         G.stop;
        close(gcf);
        out = false;
    end
end
