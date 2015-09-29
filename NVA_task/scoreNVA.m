function phonemescore = scoreNVA
% The list are designed to score based on the number of correctly 
% identified phonemes (phonemescore). The first word of each list is 
% excluded. Because each list contains 33 phonemes, every phoneme counts 
% for ~3%. The correct score in % is obtained by multiplying the nr of 
% correctly identified phonemes with 3, and increase this number with 1% 
% when it is higher than 50%. In formula: 

% Score = 3 * Ncorrect            for  0 <= Ncorrect <= 16 (11 * 3 / 2)
% Score = 3 * Ncorrect + 1      for 17 <= Ncorrect <=33 (11 * 3)
   
    pathsToAdd = {'../lib/MatlabCommonTools/'};
    for iPath = 1 : length(pathsToAdd)
        addpath(pathsToAdd{iPath})
    end
    
    options.home = getHome;
    options.responsesFolder = [options.home '/results/NVA/'];
    files = dir([options.responsesFolder '*.mat']);
    phonemescore = zeros(1, length(files));
    for ifile = 1 : length(files)
        load([options.responsesFolder files(ifile).name])
        lists = fieldnames(responses);
        for iList = 1 : length(lists)
            % exclude first word
            responses.(lists{iList}).scores(1) = [];
            responses.(lists{iList}).word(1) = [];
            % 
            scores = [responses.(lists{iList}).scores(:)];
            words  = [responses.(lists{iList}).word{:}];
            
            phonemescore(iList) = getScore(scores);
            
        end
    end

    
end


function phonemescore = getScore(scores)
    phonemescore = 0;
    for iscore = 1 : length(scores)
        switch scores{iscore}
            % case 'zero' % add nothing
            case 'one'
                phonemescore = phonemescore + 1 * 3;
            case 'two'
                phonemescore = phonemescore + 2 * 3;
            case 'three'
                phonemescore = phonemescore + 3 * 3;
        end
    end
    if phonemescore > 50
        phonemescore = phonemescore + 1;
    end
end
