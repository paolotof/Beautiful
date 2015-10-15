
% ----- Fill in subject information ----- %

subjectID = 'Jacky';  
% Agegroup = 'Adult'; % 'child' or 'adult'
Language = 'Dutch'; % 'Dutch' or 'English' 

options.subID = subjectID;
% options.subAge = AgeGroup;
options.subLanguage = Language; 
% options.experimentName = 
% options.experimentFolder = 

experiment(1).name = {'Emotion'};
experiment(1).file = {'Expe_Emotion.m'};
experiment(1).folder = {'C:\Users\Jacqueline Libert\Documents\GitHub\Emotion\Matlab'};

experiment(2).name = {'Fishy'};
experiment(2).file = 'expe_run.m';
experiment(2).folder = {'C:\Users\Jacqueline Libert\Documents\GitHub\BeautifulFishy\Fishy_Adaptive VTL-F0 jnd'};

experiment(3).name = {'Gender'};
experiment(3).file = {'expe_run.m'};
experiment(3).folder = {'C:\Users\Jacqueline Libert\Documents\GitHub\Gender\Matlab'};

experiment(4).name = {'NVA'}; 
experiment(4).file = {'NVA_task.m'};
experiment(4).folder = {'C:\Users\Jacqueline Libert\Documents\GitHub\BeautifulFishy\NVA_task'};

% randomOrder = randperm(4);
for randomOrder = randperm (4)
    cd = experiment(randomOrder).folder;
    run(experiment(randomOrder).file{:});
end

experiments = {'Emotion', 'Fishy', 'Gender', 'NVA'};
options.total_experiments = length(experiments);
options.experiment = experiments(randperm(options.total_experiments)); 


       

for iExperiment = 1:options.experiment 

Emotion
Expe_Emotion ('options.subID', 'test', 'intact')

cd 'C:\Users\Jacqueline Libert\Documents\GitHub\Gender\Matlab'
expe_run ('options.subID', 'options.subLanguage') 


