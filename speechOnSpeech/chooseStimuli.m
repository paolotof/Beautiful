function stimuli = chooseStimuli(stimuliType)
% chooses which stimuli to load depending on of the experiment. The stimuli
% can be teh plomp, VU set or NVA words    
% stimuliType = {'VU', 'NVA', 'plomp'}

    switch stimuliType
        case 'VU'
            stimuli = getVU;
        case 'NVA'
            stimuli = getNVA;
        case 'plomp'
            stimuli = getPlomp;
        otherwise
            error(['Stimuli ' stimuliType ' are not recognized']);
    end
end

function stimuli = getVU
    % location = '~/gitStuff/nawalMike/Speech-on-Speech/interface/VU_zinnen.mat';
    % load '~/gitStuff/nawalMike/Speech-on-Speech/interface/VU_zinnen.mat';
    location = '~/ownCloud/VU_zinnen/';
    load ([location 'VU_zinnen.mat']);
    stimuli = VU_zinnen;
end

function stimuli = getNVA
%  chooseStimuli('NVA')

    location = '~/ownCloud/NVA/';
    stimuli = dir([location '*.wav']);
    
end

function stimuli = getPlomp
%  chooseStimuli('plomp')
    location = '~/ownCloud/plomp/'; 
    % stimuli = dir([location '*.wav']);
    fid = fopen([location '00 info/00 plomp list.txt'], 'rt');
    while ~feof(fid)
        tline = fgetl(fid);
        
        if strfind(tline, 'List')
            listName = regexprep(tline, '[\s\:]', '');
            iSent = 0;
            tline = fgetl(fid);
        end
        if ~isempty(tline) && exist('listName', 'var')
            iSent = iSent + 1;
            tline = regexprep(tline, '[0-9]', '');
            stimuli.(listName).sentence{iSent} = strtrim(tline);
        end
            
        
    end

    fclose(fid);
end