function [out] = ready2start(G)
    oldimage = get(0,'DefaultImageVisible');
    set(0, 'DefaultImageVisible','off')
    button = questdlg('Ready to Start?','START','Yes','No','Yes');
    set(0,'DefaultImageVisible',oldimage)
    out = true;
    if strcmp(button, 'No')
        msgbox('OK, ciaociao')
        G.stop;
        close(gcf);
        out = false;
    end
end
