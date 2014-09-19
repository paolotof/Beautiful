% 1 = pause
% 2 = unpause
% space = next

% in case of crash: comment line 10 "save backup.mat" 
% and manually adjust line 23: for Phase_index = X : 4 --> X = where you
% crashed (1, 2, 3, 4), corresponding to (training1, test1, training2,
% test2)

close all
clear all 
clc
save backup.mat

if ~exist('analysis mat files', 'dir')
    mkdir('analysis mat files');
end
if ~exist('masker files', 'dir')
    mkdir('masker files');
end
if ~exist('sentences', 'dir')
    error('no data available')
end

for Phase_Index=3:6
    PathToStraight = fullfile('..', 'straight', 'STRAIGHT');
    addpath(genpath(PathToStraight));
    
    Options = struct();
    Options.Subject = '1';
    Options.f0 = [0, 4, 8];
    Options.vtl = [0, 0.75, 1.5]; 
    Options.snr = [-6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   Order: [training1 test1 training2 test2] %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Options.fs = 44100;
    Options.Target_rms = 0.05;
    %Options.SamplesPerCondition=[1, 13, 1, 13, 13, 13];
    Options.SamplesPerCondition=[1, 13, 1, 13, 13, 13];
    Options.ManVrouw = {'Man','Man','Vrouw','Vrouw', 'Man', 'Vrouw'};                         
    Options.Phase = {'Training1','Test1','Training2','Test2', 'Test3', 'Test4'};
    Options.IndexStartingPoint = [1 27 1 27, 144, 144];
    Options.MaskerLists = [27, 31];                                 
        
    p = interface(Options, Phase_Index);
    save(fullfile(sprintf('subject%s', Options.Subject), sprintf('%s', p.Phase)), 'p');
    
    clear all
    close all
    save backup.mat
end
  



% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % LISTS % % % LISTS % % % LISTS % % % LISTS % % % LISTS % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % %                                                               % % %
% % %  training 1        lists 1:2       indexes 1:26        MALE   % % % 
% % %  test1             lists 3:26      indexes 27:338      MALE   % % % 
% % %  male maskers      lists 27:31     indexes 339:403     MALE   % % %
% % %  training2         lists 40:41     indexes 507:533     FEMALE % % %
% % %  test2             lists 42:65     indexes 534:845     FEMALE % % %
% % %  female maskers    lists 66:70     indexes 846:910     FEMALE % % %
% % %                                                               % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % LISTS % % % LISTS % % % LISTS % % % LISTS % % % LISTS % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 