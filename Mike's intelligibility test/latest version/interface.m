function p = interface(Options, Phase_Index)

load('backup.mat')

if exist('p', 'var')
   p = initialize_saved(p);
else
    p = initialize_parameters(Options, Phase_Index);
    p = make_file_names(p);
end
p = initialize_figures_and_get_handles(p);
waaaaaaaait=0;
pressed = 0;

while (p.Continu==1  || ~isempty(p.AnnotationsAvailable))
User_Sitch    
    if waaaaaaaait == 0
        
        set(p.InstructionHandle6, 'Visible', 'off');
        set(p.InstructionHandle7, 'Visible', 'off');
        
        switch User_Sitch

            % cases 1-4: initialization & introductions
            case 1                  
                User_Sitch = 0;
                p.current_situation = 1;
                p = set_progress_bar(p, p.f2, p.i2, 'on', p.PosBar2);
                p = initialize_GUI(p);
            case 2
                User_Sitch = 0;
                p.current_situation = 2;
                p = set_GUI_case2(p);
            case 3
                p.current_situation = 3;
                p = set_GUI_case3(p);
            case 4
                if strcmp(p.Player.Running, 'off')==1
                    p.current_situation = 4;
                    User_Sitch = 0;
                    p = set_GUI_case4(p);
                end
                
            % cases 10-12: play and repeat cycle
            case 10 
                p.current_situation = 10;
                p = set_progress_bar(p, p.f1, p.i, 'on', p.PosBar1);
                stimuli = create_stimuli(p); 
                p.Player = audioplayer(stimuli, p.fs);
                play(p.Player);
                p = set_GUI_case10(p);
            case 11        
                if strcmp(p.Player.Running, 'off') == 1
                    p.current_situation = 11;
                    User_Sitch = 0;
                    p = set_GUI_case11(p);
                end
            case 12
                User_Sitch = 0;
                p.current_situation = 12;
                p.i = p.i+1;
                p = set_GUI_case12(p);
                    
            % case 13:14 (and 12): good bye messages    
            case 13
                p.current_situation = 13;
                User_Sitch = 0;
                p = set_GUI_case13(p);
            case 14
                p.current_situation = 14;
                User_Sitch = 0;
                p = set_GUI_case14(p);
            case 15
                p.current_situation = 15;
                User_Sitch = 0;
                set(p.ImagePlay, 'Visible', 'off')
                set(p.ImageJohnHappy, 'Visible', 'off')
                set(p.Text, 'Visible', 'off')
                set(p.ImageArrow2, 'Visible', 'off')
                set(p.InstructionHandle1, 'String', 'Waiting for Nikki and/or Mike -_-', 'Visible', 'on');
                if strcmp(p.Phase , 'Test4')==1
                    set(p.InstructionHandle1, 'Visible', 'off');
                end
                p.Continu = 0;

            % saved case
            case 20
                p.current_situation = 20;
                User_Sitch = 0;
                p = set_GUI_saved(p);
             
                
            % new training repeat cycle    
            case 25 
                p.current_situation = 25;
                p = set_progress_bar(p, p.f1, p.i, 'on', p.PosBar1);
                stimuli = create_stimuli(p); 
                p.Player = audioplayer(stimuli, p.fs);
                play(p.Player);
                p = set_GUI_case25(p);
            case 26        
                if strcmp(p.Player.Running, 'off') == 1
                    p.current_situation = 26;
                    User_Sitch = 0;
                    p = set_GUI_case26(p);
                end
            case 29
                User_Sitch = 0;
                p.current_situation = 29;
                p = set_GUI_case27(p);
            case 27
                User_Sitch = 0;
                p.current_situation = 27;
                %p = set_GUI_case27(p);
                play(p.Player);
            case 28
                if strcmp(p.Player.Running, 'off') == 1
                    p.i = p.i+1;
                    p.current_situation = 25;
                    p = set_GUI_case28(p);
                end

                
        end
        
        if pressed == 1
            pressed = 0;
            [User_Sitch, p] = get_user_sitch(p, p.current_situation);
        end
    else    
        set(p.InstructionHandle6, 'String', 'Paused', 'Visible', 'on');
        set(p.InstructionHandle7, 'String', 'Paused', 'Visible', 'on');
    end
 
	switch User2_Sitch(1)
    	case 1             
            if ~isempty(p.AnnotationsAvailable)
                User2_Sitch(1) = 0; 
                p=set_buttons(p);
            end
        case 2
            User2_Sitch(1) = 0;
            p = modify_score(p, User2_Sitch);            
        case 3
            User2_Sitch(1) = 0;
            p = save_score(p);
            if p.Continu == 0 && isempty(p.AnnotationsAvailable)
                close all
            end
            save 'backup.mat'
	end
   pause(0.2);
end


%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%% %%% SCORING & GUI %%% %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% 


function p = set_buttons(p)
VU_index = sscanf(p.FileNames{p.AnnotationsAvailable(1)}, sprintf('%s%%03d', p.ManVrouw));

switch p.ManVrouw
    case 'Man'
        sentence = p.VU_Zinnen{VU_index};
    case 'Vrouw'
        sentence = p.VU_Zinnen{VU_index+507};
end

line_cell_cell=textscan(sentence,'%s',10,'delimiter',' ');
p.Words=line_cell_cell{1};
p.Spacing = (p.WidthBig/(length(p.Words))) - p.WidthBig/25;
p.SentenceScore = ones(length(p.Words), 1);

for i2=1:length(p.Words)
	p.Instruction = uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', ...
    [p.PosButtons(1)+p.Spacing*(i2-1)-0.25*p.PosButtons(3) p.PosButtons(2)+1.25*p.PosButtons(4) p.PosButtons(3)*1.75 p.PosButtons(4)*1.2], ...
    'FontSize', 14, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);
    set(p.Instruction, 'String', p.Words{i2})
    p.ImageWrongRightHandle(i2) = axes('Parent', p.f2, 'Units', 'pixel','Position', [p.PosButtons(1)+p.Spacing*(i2-1) p.PosButtons(2) p.PosButtons(3) ...
    p.PosButtons(4)], 'XTick', [], 'YTick', []);
    axes(p.ImageWrongRightHandle(i2));
    image_handle=image(p.ImreadRight);
    set(p.ImageWrongRightHandle(i2), 'Visible','off')
    set(image_handle,'ButtonDownFcn',@(h,e)(assignin('caller', 'User2_Sitch',  [2 i2])))
end

confirm_image_axes_handle = axes('Visible', 'off', 'Parent', p.f2, 'Units', 'pixel','Position', p.PosBottom2, 'XTick', [], 'YTick', []);
axes(confirm_image_axes_handle);
p.ImageConfirm=image(p.ImreadConfirm);
set(p.ImageConfirm, 'Visible','on') 
set(confirm_image_axes_handle, 'Visible','off')
set(p.ImageConfirm,'ButtonDownFcn',@(h,e)(assignin('caller', 'User2_Sitch',  [3 0])))



function p = modify_score(p, User2_Sitch)
axes(p.ImageWrongRightHandle(User2_Sitch(2)));

switch p.SentenceScore(User2_Sitch(2))
    case 1
        p.SentenceScore(User2_Sitch(2)) = 0;
        WrongRightHandel=image(p.ImreadWrong);
    case 0
        p.SentenceScore(User2_Sitch(2)) = 1;
        WrongRightHandel=image(p.ImreadRight);
end

set(p.ImageWrongRightHandle(User2_Sitch(2)), 'Visible','off')
set(WrongRightHandel,'ButtonDownFcn',@(h,e)(assignin('caller', 'User2_Sitch',  [2 User2_Sitch(2)])))


 
function p = save_score(p)
[conditions] = sscanf(p.FileNames_indexed{p.i2}, sprintf('%s%%03d_f0%%d_vtl%%d_snr%%d', p.ManVrouw));

p.ConditionsCounts(conditions(2), conditions(3), conditions(4)) = ...
    p.ConditionsCounts(conditions(2), conditions(3), conditions(4)) + length(p.Words);
p.ConditionsCorrect(conditions(2), conditions(3), conditions(4)) = ...
    p.ConditionsCorrect(conditions(2), conditions(3), conditions(4)) + sum(p.SentenceScore);

clf(p.f2)
assignin('caller', 'User2_Sitch', [1 0])          % set next annotations
p.i2 = p.i2+1;
p = set_progress_bar(p, p.f2, p.i2, 'on', p.PosBar2);

tmp = [];
for i=2:length(p.AnnotationsAvailable)
    tmp(i-1) = p.AnnotationsAvailable(i);
end
p.AnnotationsAvailable = tmp;

p.InstructionHandle2= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction2, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
WhereUseris = sprintf('User: %d\nYou: %d',p.i, p.i2);
WhereUseris = textwrap(p.InstructionHandle2, {WhereUseris});
set(p.InstructionHandle2, 'String', WhereUseris, 'Visible', 'on');
p.InstructionHandle6= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosPause2, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle6, 'String', 'Paused', 'Visible', 'off');


%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%% %%%%%% STIMULI %%%%%% %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% 


function stimuli = create_stimuli(p)

conditions = sscanf(p.FileNames{p.i}, sprintf('%s%%03d_f0%%d_vtl%%f_snr%%d', p.ManVrouw));
target_signal_pre = wavread(fullfile('sentences', sprintf('%s%03d.wav', p.ManVrouw, conditions(1))));

list = p.MaskerLists(1) + round(rand()*(p.MaskerLists(2) - p.MaskerLists(1)));
index1 = round((((list-1)*13)+round(rand()*13)));
index2=index1;
while index2==index1
    list = p.MaskerLists(1) + round(rand()*(p.MaskerLists(2) - p.MaskerLists(1)));
    index2 = round((((list-1)*13)+round(rand()*13)));    
end

if exist(fullfile('masker files', sprintf('%s%03d_f0%d_vtl%.2f.wav', p.ManVrouw, index1, conditions(2), conditions(3))), 'file') ~= 0
	masker1 = wavread(fullfile('masker files', sprintf('%s%03d_f0%d_vtl%.2f.wav', p.ManVrouw, index1, conditions(2), conditions(3))));
else
    masker1 = wavread(fullfile('sentences', sprintf('%s%03d.wav', p.ManVrouw, index1)));
    [p, masker1] = modify_masker(p, masker1, conditions, p.fs, p.ManVrouw, index1);          %%%%%%
end
    
if exist(fullfile('masker files', sprintf('%s%03d_f0%d_vtl%.2f.wav', p.ManVrouw, index2, conditions(2), conditions(3))), 'file') ~= 0
	masker2 = wavread(fullfile('masker files', sprintf('%s%03d_f0%d_vtl%.2f.wav', p.ManVrouw, index2, conditions(2), conditions(3))));
else
    masker2 = wavread(fullfile('sentences', sprintf('%s%03d.wav', p.ManVrouw, index2)));
    [p, masker2] = modify_masker(p, masker2, conditions, p.fs, p.ManVrouw, index2);
end
    

target_signal_pre = 0.98 * target_signal_pre / max(abs(target_signal_pre));
start = find(abs(target_signal_pre)>.02, 1, 'first');
target_signal = target_signal_pre(start:end);
target_signal = [zeros(1, round(p.fs*0.5)) target_signal'];

% masker 1 start
start = round(rand()*(length(masker1)-p.fs));
masker1 = masker1(start:end);

start = round(rand()*(length(masker2)-p.fs));
masker2 = masker2(start:end);

masker1 = cosgate(masker1, p.fs, 2e-3);
masker2 = cosgate(masker2, p.fs, 2e-3);

masker = [masker1' masker2'];

len_diff = length(masker) - length(target_signal);

while len_diff < 0
	additional_masker = get_additional_masker(p, conditions);
    masker = [masker additional_masker'];
    len_diff = length(masker) - length(target_signal);
    warning('extending masker')
end

if len_diff > round(0.5*p.fs)
	target_signal = [target_signal zeros(1, round(0.5*p.fs))];
    masker = masker(1:length(target_signal));
else
	target_signal = [target_signal zeros(1, len_diff)];
end

% attenuation
attenuate = p.Target_rms / rms(target_signal);
target_signal = target_signal*attenuate;

masker_rms = p.Target_rms/(10^(conditions(4)/20));

attenuate = masker_rms / rms(masker);
masker = masker * attenuate;

stimuli = target_signal+masker;

max_stim = max(abs(stimuli));
if max_stim > 1
   stimuli = 0.98*stimuli / max(abs(stimuli)); 
   max_stim2 = max(abs(stimuli));
   warning(sprintf('Stimuli attenuated by %.2f%%', 100*(max_stim-max_stim2) / max_stim))
end




function [p, masker_new] = modify_masker(p, masker, conditions, fs, ManVrouw, index)    

p.InstructionHandle4= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction4, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle4, 'String', 'Extracting data... Please be patient', 'Visible', 'on');

p.InstructionHandle5= uicontrol('Parent', p.f1, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction5, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle5, 'String', 'Extracting data... Please be patient', 'Visible', 'on');

pause(0.05)

if exist(fullfile('analysis mat files', sprintf('%s%03d.mat',ManVrouw, index)), 'file') ~= 0
    load (fullfile('analysis mat files', sprintf('%s%03d.mat',ManVrouw, index)));
else
    display('extracting f0')
    [f0raw1,vuv]=MulticueF0v14(masker,fs);    
    ap=exstraightAPind(masker,fs,f0raw1);
    n3sgram=exstraightspec(masker,f0raw1.*vuv,fs);
    f0raw1(f0raw1<65)=0;
    save(fullfile('analysis mat files', sprintf('%s%03d.mat',ManVrouw, index)), 'f0raw1', 'vuv', 'ap', 'n3sgram')
end

switch ManVrouw
	case 'Man'
    	f0shift = f0raw1*2.^(conditions(2)/12);
        p2.frequencyAxisMappingTable = 2.^(conditions(3)/12);               
	case 'Vrouw'
    	f0shift = f0raw1*2.^(-conditions(2)/12);
        p2.frequencyAxisMappingTable = 2.^(-conditions(3)/12);              
end

display('synthesizing')
masker = exstraightsynth(f0shift.*vuv,n3sgram,ap,fs, p2);

masker = 0.98*masker / abs(max(masker));
start = find(abs(masker)>.02, 1, 'first');
endx = find(abs(masker)>.02, 1, 'last');

masker_new = masker(start:endx);

wavwrite(masker_new, fs, fullfile('masker files', sprintf('%s%03d_f0%d_vtl%.2f.wav', ManVrouw, index, conditions(2), conditions(3))));
set(p.InstructionHandle5, 'Visible', 'off');
set(p.InstructionHandle4, 'Visible', 'off');




%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%% %%%%%%%% GUI %%%%%%%% %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% 

function p = initialize_GUI(p)

switch p.Phase
	case 'Training1'
        instr_0 = 'Hello, and welcome to the experiment. \n\nYou are currently seated in a soundproof, anechoic chamber, which means that no matter how hard you scream, nobody will hear you.\n\nLets begin the experiment.';
    case 'Test1'
        instr_0 = 'We will now begin with Trial #1. It is equivalent to your training, so im sure you will do fine!\n\nBy the way, don''t worry if you don''t understand the whole sentence, just repeat the parts that you do understand. \n\nGood luck!\n\n';
	case 'Training2'
    	instr_0 = 'Welcome to your second training session. \n\nHere we will become familiar with a new voice. We''ll follow the same procedure as your first training session, so sit back and relax.';
	case 'Test2'
        instr_0 = 'Welcome to Trial #2.  You know what to do by now. \n\nGood luck!';
    case 'Test3'
        instr_0 = 'Hello again, and welcome to Trial #3! Here we will be listening to the male voice again. Good luck!';
	case 'Test4'
        instr_0 = 'Hi! Welcome to your final Trial! We will be listening to the female''s voice again this time. Good luck!';
end

instr = strrep(instr_0, '\n', sprintf('\n'));
instr = textwrap(p.Text, {instr});
set(p.Text, 'String', instr, 'Visible', 'on');
set(p.ImageJohnIntro, 'Visible','on')
set(p.ImageArrow2, 'Visible','on')

set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});



function p = set_GUI_case2(p)
instr_0 = 'My name is John by the way, and i will guide you through four trials. \n\nBut first, we will begin with some training. \n\nHere we will introduce you to the voice of a man. You will have to try and recognize this voice in future trials, but for now just sit back and relax.';
instr = strrep(instr_0, '\n', sprintf('\n'));
instr = textwrap(p.Text, {instr});
set(p.Text, 'String', instr);
set(p.ImageJohnIntro, 'Visible','off')
set(p.ImageJohnHappy, 'Visible','on')

set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});

                
                

function p = set_GUI_case3(p)
set(p.Text, 'Visible', 'off');
set(p.ImageJohnHappy, 'Visible','off')
set(p.ImageJohnIntro, 'Visible','off')
set(p.ImageArrow2, 'Visible','off')
set(p.InstructionHandle1, 'String', 'Playing...')
set(p.ImageSpeaker, 'Visible','on')
switch p.Phase
    case 'Training1'
        [signal, fs] = wavread('man_training1.wav');
    case 'Training2'
        [signal, fs] = wavread('female_training2.wav');
end

% attenuation (training)
attenuate = p.Target_rms/rms(signal);
signal = signal*attenuate;

p.Player = audioplayer(signal, fs);            
play(p.Player)

assignin('caller', 'User_Sitch', 4)



function p = set_GUI_case4(p)
set(p.ImageJohnHappy, 'Visible','off')
set(p.ImageSpeaker, 'Visible','off')
set(p.InstructionHandle1, 'Visible', 'off')
set(p.ImageArrow2, 'Visible','on')
set(p.ImageJohnNeutral, 'Visible','on')

switch p.Phase
    case 'Training1'
        instr_0 = 'Great. You will now hear the two voices. Try to ignore the voice that starts first, and the second voice. It will start 0.5 seconds after the first voice. \n\nBeware, they may be very similar!';
    case 'Training2'
        instr_0 = 'Great. We will now introduce a second voice again.';
end

instr = strrep(instr_0, '\n', sprintf('\n'));
instr = textwrap(p.Text, {instr});
set(p.Text, 'String', instr, 'Visible', 'on');

set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});
                


function p = set_GUI_case10(p)
set(p.ImageArrow2, 'Visible','off')
set(p.ImageArrow, 'Visible','off')
set(p.ImageVoice, 'Visible','off')    
set(p.ImageJohnNeutral, 'Visible','off')
set(p.ImageJohnIntro, 'Visible','off')
set(p.Text, 'Visible', 'off');
set(p.ImageSpeaker, 'Visible','on')
set(p.InstructionHandle1, 'String', 'Playing..', 'Visible', 'on')

p.InstructionHandle3= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction3, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle3, 'String', 'Play', 'Visible', 'on');

assignin('caller', 'User_Sitch', 11)




function p = set_GUI_case11(p)
pause(0.1)
set(p.ImageSpeaker, 'Visible','off');         
set(p.InstructionHandle1, 'String', 'Please repeat')
set(p.ImageVoice, 'Visible','on')      
set(p.ImageArrow, 'Visible','on')      

set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});

p.InstructionHandle3= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction3, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle3, 'String', 'Repeat', 'Visible', 'on');



function p = set_GUI_case12(p)
if p.i <= p.TotalSampleLength
    p.AnnotationsAvailable(end+1) = p.i;
    assignin('caller', 'User_Sitch', 10)
else
    p = set_progress_bar(p, p.f1, p.i, 'off', p.PosBar1);
    set(p.ImageVoice, 'Visible','off')      
    set(p.ImageArrow, 'Visible','off') 
    set(p.InstructionHandle1, 'Visible', 'off')
    switch p.Phase
        case 'Test1'
            instr_0 = '\nZZZZzzzzz ...... ZZZZzzzzzz ..... ZZZzzzzz';
            set(p.ImageJohnSleeping, 'Visible','on')
        case 'Test2'
            instr_0 = 'That concludes trial #2. Well done! Would you like a break?';
            set(p.ImageJohnHappy, 'Visible','on')
        case 'Test3'
            instr_0 = 'That concludes trial #3. We have free coffee, thee and hot choclate by the way :)';
            set(p.ImageJohnHappy, 'Visible','on')
        case 'Test4'
            instr_0 = 'Congradulations, you have succesfully completed all four trials!\n\nI would like to thank you for your participation. Perhaps your data will contribute towards enriching auditory perception for the hearing-impaired all over the world!\n\nPerhaps one day we will meet again, thank you and good bye!';
            set(p.ImageJohnHappy, 'Visible','on')
    end
    instr = strrep(instr_0, '\n', sprintf('\n'));
    instr = textwrap(p.Text, {instr});
    set(p.Text, 'String', instr, 'Visible', 'on');
    set(p.ImageArrow2, 'Visible','on')
    
    set(p.f2, 'KeyPressFcn', {@spacebar_callback});
    set(p.f1, 'KeyPressFcn', {@spacebar_callback});

end
p.InstructionHandle2= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction2, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
WhereUseris = sprintf('User: %d\nYou: %d',p.i, p.i2);
WhereUseris = textwrap(p.InstructionHandle2, {WhereUseris});
set(p.InstructionHandle2, 'String', WhereUseris, 'Visible', 'on');



function p = set_GUI_case13(p)
set(p.ImageJohnSleeping, 'Visible','off')
set(p.ImageArrow, 'Visible','off')
instr_0 = '... hmm? ... ah ... i must have fallen asleep.\n\nHow are you holding up? Would you like a coffee?';
instr = strrep(instr_0, '\n', sprintf('\n'));
instr = textwrap(p.Text, {instr});
set(p.Text, 'String', instr);
set(p.ImageJohnYawning, 'Visible','on')
set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});



function p = set_GUI_case14(p)
set(p.ImageJohnHappy, 'Visible','off')
set(p.ImageJohnYawning, 'Visible','off')
set(p.ImageArrow, 'Visible','off')
set(p.ImageArrow2, 'Visible','off')
set(p.Text, 'Visible', 'off');
set_progress_bar(p, p.f1, p.i, 'off', p.PosBar1)

set(p.InstructionHandle1, 'String', 'Spacebar to proceed to next trial', 'Visible', 'on');        

set(p.ImagePlay, 'Visible', 'on')
set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});




function p = set_GUI_case25(p)
set(p.ImageArrow2, 'Visible','off')
set(p.ImageArrow, 'Visible','off')
set(p.ImageVoice, 'Visible','off')    
set(p.ImageJohnNeutral, 'Visible','off')
set(p.ImageJohnIntro, 'Visible','off')
set(p.Text, 'Visible', 'off');
set(p.ImageSpeaker, 'Visible','on')
set(p.InstructionHandle1, 'String', 'Playing..', 'Visible', 'on')

p.InstructionHandle3= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction3, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle3, 'String', 'Play', 'Visible', 'on');

assignin('caller', 'User_Sitch', 26)



function p = set_GUI_case26(p)
pause(0.1)
set(p.ImageSpeaker, 'Visible','off');         
set(p.InstructionHandle1, 'String', 'Please repeat')
set(p.ImageVoice, 'Visible','on')      
set(p.ImageAnswer, 'Visible','on')      

set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});

p.InstructionHandle3= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction3, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle3, 'String', 'Repeat', 'Visible', 'on');



function p = set_GUI_case27(p)
set(p.ImageVoice, 'Visible','off') 
set(p.ImageAnswer, 'Visible','off') 
set(p.InstructionHandle1,'Visible','off') 
set(p.ImageReplay, 'Visible','on') 
p.InstructionHandle3= uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction3, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
set(p.InstructionHandle3, 'String', 'Feedback', 'Visible', 'on');

% buttons
VU_index = sscanf(p.FileNames{p.i}, sprintf('%s%%03d', p.ManVrouw));

switch p.ManVrouw
    case 'Man'
        sentence = p.VU_Zinnen{VU_index};
    case 'Vrouw'
        sentence = p.VU_Zinnen{VU_index+507};
end

line_cell_cell=textscan(sentence,'%s',10,'delimiter',' ');
p.Words=line_cell_cell{1};
p.Spacing = (p.WidthSmall/(length(p.Words))) - p.WidthSmall/25;
p.SentenceScore = ones(length(p.Words), 1);

p.LengthWords = length(p.Words);
for i2=1:length(p.Words)
	p.Instruction_user(i2) = uicontrol('Parent', p.f1, 'Style', 'text', 'Units', 'pixel', 'Position', ...
    [p.PosButtons_Small(1)+p.Spacing*(i2-1)-0.25*p.PosButtons_Small(3) p.PosButtons_Small(2)+1.25*p.PosButtons_Small(4) p.PosButtons_Small(3)*1.75 p.PosButtons_Small(4)*1.2], ...
    'FontSize', 14, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);
    set(p.Instruction_user(i2), 'String', p.Words{i2})
end

set(p.f1, 'KeyPressFcn', {@spacebar_callback});
set(p.f2, 'KeyPressFcn', {@spacebar_callback});



function p = set_GUI_case28(p)

for ii=1:p.LengthWords
	set(p.Instruction_user(ii), 'Visible', 'off')
end
set(p.ImageReplay, 'Visible','off')

if p.i <= p.TotalSampleLength    
    assignin('caller', 'User_Sitch', 25)
    set(p.ImageArrow, 'Visible', 'off')
    p.AnnotationsAvailable(end+1) = p.i;

else
    p = set_progress_bar(p, p.f1, p.i, 'off', p.PosBar1);
    set(p.ImageVoice, 'Visible','off')      
    set(p.ImageArrow, 'Visible','off')  
    set(p.InstructionHandle1, 'Visible', 'off')
    switch p.Phase
        case 'Training1'
            instr_0 = 'Congradulations!\n\nYou can now proceed to Trial #1.';
            set(p.ImageJohnHappy, 'Visible','on')
        case 'Training2'
            instr_0 = 'Well done! \n\nYou are now ready to proceeed to Trial #2.';
            set(p.ImageJohnHappy, 'Visible','on')
    end
    instr = strrep(instr_0, '\n', sprintf('\n'));
    instr = textwrap(p.Text, {instr});
    set(p.Text, 'String', instr, 'Visible', 'on');
    set(p.ImageArrow2, 'Visible','on')
    
    set(p.f2, 'KeyPressFcn', {@spacebar_callback});
    set(p.f1, 'KeyPressFcn', {@spacebar_callback});
    
    assignin('caller', 'User_Sitch', 0) 
    p.Continu = 0;
    p.current_situation=28;
    
end




function p = set_GUI_saved(p)
set(p.ImagePlay, 'Visible','on')
set(p.InstructionHandle1, 'Visible','on', 'String', 'Press spacebar to resume experiment')
set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});



function spacebar_callback(~, event)
if strcmp(event.Character, ' ')==1
    assignin('caller', 'pressed', 1) 
end
if strcmp(event.Character, '1')==1
    assignin('caller', 'waaaaaaaait', 1) 
end
if strcmp(event.Character, '2')==1
    assignin('caller', 'waaaaaaaait', 0) 
end



function p = set_progress_bar(p, handle, index, onoff, PosBar)

p.Waitbar1 = axes('Parent', handle, 'Units', 'pixel','Position', PosBar, 'XTick', [], 'YTick', []);
axes(p.Waitbar1)
    
switch p.Phase
	case {'Training1', 'Training2'}
        fill([0 1 1 0] * index/(p.TotalSampleLength), [0 0 1 1], 'g', 'EdgeColor','g');
    case 'Test1'
    	fill([0 1 1 0] * index/(p.TotalSampleLength*4), [0 0 1 1], 'g', 'EdgeColor','g');
	case 'Test2'
    	fill([0 1 1 0] * (index+p.TotalSampleLength)/(p.TotalSampleLength*4), [0 0 1 1], 'g', 'EdgeColor','g');
	case 'Test3'
    	fill([0 1 1 0] * (index+p.TotalSampleLength*2)/(p.TotalSampleLength*4), [0 0 1 1], 'g', 'EdgeColor','g');
    case 'Test4'
    	fill([0 1 1 0] * (index+p.TotalSampleLength*3)/(p.TotalSampleLength*4), [0 0 1 1], 'g', 'EdgeColor','g');
end
    
set(p.Waitbar1, 'XColor', 'w', 'YColor', 'w', 'XTick', [], 'YTick', [], 'Xlim', [0 1], 'YLim', [0 1]);
p.WaitbarLegend1 = uicontrol('Parent', handle, 'Style', 'text', 'Units', 'pixel', 'Position', [PosBar(1) PosBar(2)-PosBar(4) PosBar(3) PosBar(4)], ...
	'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);
set(p.WaitbarLegend1, 'String', p.Phase(1:end-1), 'Visible', onoff)
set(p.Waitbar1, 'Visible', onoff)


%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%% %%% Preprocessing %%% %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%% 

function [p] = initialize_parameters(Options, Phase_Index)
p=struct();

load VU_zinnen
p.VU_Zinnen = VU_zinnen;
p.PhaseIndex = Phase_Index;

assignin('caller', 'User2_Sitch', [1 0])
assignin('caller', 'User_Sitch', 1)
p.Init=1;
p.Continu=1;
p.Player = struct();
p.Player.Running='off';
p.i=1;
p.i2=1;
p.AnnotationsAvailable=p.i;

p.BackgroundColor = [.4 .4 .4];
p.MainTextColor = [1 1 1]*.9;
p.ProgressbarColor= [.5 .8 .5];  

p.SamplesPerCondition = Options.SamplesPerCondition(Phase_Index);

%p.ScrszSmall = get(0,'ScreenSize');
%p.ScrszBig = get(0,'ScreenSize'); 
 p.ScrszSmall  = [-1024, 0, 1024, 768];
 p.ScrszBig = [0, 0, 1920, 1080];

p.WidthSmall = p.ScrszSmall(3);
p.WidthBig = p.ScrszBig(3);
p.HeightSmall =  p.ScrszSmall(4);
p.HeightBig = p.ScrszBig(4);

p.ManVrouw = Options.ManVrouw{Phase_Index};
p.Subject = Options.Subject;
p.Phase = Options.Phase{Phase_Index};

for f0=1:length(Options.f0)
    for vtl=1:length(Options.vtl)
        for snr=1:length(Options.snr)
            p.ConditionsNames{f0, vtl, snr} = sprintf('f0%d_vtl%.2f_snr%d', Options.f0(f0), Options.vtl(vtl), Options.snr(snr));
            p.ConditionsCounts(f0, vtl, snr) = 0;
            p.ConditionsCorrect(f0, vtl, snr) = 0;
        end
    end
end

p.Conditions.f0 = Options.f0;
p.Conditions.vtl = Options.vtl;
p.Conditions.snr = Options.snr;
p.MaskerLists = Options.MaskerLists;
p.IndexStartingPoint = Options.IndexStartingPoint(Phase_Index);
p.fs = Options.fs;
p.Target_rms = Options.Target_rms;

if ~exist(sprintf('subject%s', p.Subject), 'dir')
    mkdir(sprintf('subject%s', p.Subject));
end
    


function p = make_file_names(p)
p.FileNames = cell(0);
p.FileNames_indexed = cell(0);
[f0_len, vtl_len, snr_len] = size(p.ConditionsNames);

f0_values = randperm(f0_len);
vtl_values = randperm(vtl_len);

for f0 = 1:f0_len
    for vtl=1:vtl_len
        for snr=1:snr_len
            for n=1:p.SamplesPerCondition
                p.FileNames{end+1} = sprintf('%s%03d%s%d%s%.2f%s%d', p.ManVrouw, n+ p.IndexStartingPoint-1 + (snr-1)*p.SamplesPerCondition + ...
                	(vtl-1)*snr_len*p.SamplesPerCondition + (f0-1)*vtl_len*snr_len*p.SamplesPerCondition, ...
                    '_f0', p.Conditions.f0(f0_values(f0)), '_vtl', p.Conditions.vtl(vtl_values(vtl)), '_snr', p.Conditions.snr(snr));
                p.FileNames_indexed{end+1} = sprintf('%s%03d%s%d%s%d%s%d', p.ManVrouw, n +p.IndexStartingPoint-1+ (snr-1)*p.SamplesPerCondition + ...
                	(vtl-1)*snr_len*p.SamplesPerCondition + (f0-1)*vtl_len*snr_len*p.SamplesPerCondition, ...
                    '_f0', f0_values(f0), '_vtl', vtl_values(vtl), '_snr', snr);                        
            end
        end
    end
end

random_list = randperm(length(p.FileNames));
p.FileNames=p.FileNames(random_list);
p.FileNames_indexed = p.FileNames_indexed(random_list);
p.TotalSampleLength = length(p.FileNames);



function p = initialize_figures_and_get_handles(p)
p.f1=figure('Position', p.ScrszSmall, 'Menubar', 'none', 'Resize', 'off', 'Color', p.BackgroundColor);        
p.f2=figure('Position', p.ScrszBig, 'Menubar', 'none', 'Resize', 'off', 'Color', p.BackgroundColor);        

p.PosCenter = [p.WidthSmall/2.25, p.HeightSmall/2, p.WidthSmall/12, p.HeightSmall/10];
p.PosBottom = [p.WidthSmall/2.2, p.HeightSmall/6, p.WidthSmall/16, p.HeightSmall/16];


p.PosRight = [p.WidthSmall/4+p.WidthSmall/2.5+p.WidthSmall/10, p.HeightSmall/2.5, p.WidthSmall/16, p.HeightSmall/16];
p.PosJohn = [p.WidthSmall/4-p.WidthSmall/10 p.HeightSmall/6, p.WidthSmall/10, p.HeightSmall/2];
p.PosText = [p.WidthSmall/4, p.HeightSmall/6, p.WidthSmall/2.5 p.HeightSmall/2];
p.PosInstruction1 = [p.WidthSmall/2.5, p.HeightSmall/15+p.HeightSmall/8+p.HeightSmall/2, p.WidthSmall/12+p.WidthSmall/10, p.HeightSmall/15];
p.PosBar1 = [p.WidthSmall/2 - (p.WidthSmall/3)/2,  p.HeightSmall-p.HeightSmall/16, p.WidthSmall/3, p.HeightSmall/16];
p.PosInstruction5 = [p.WidthSmall/16, p.HeightSmall/1.5+p.HeightSmall/16, p.WidthSmall/8, p.HeightSmall/4];


p.PosBar2 = [p.WidthBig/2-(p.WidthBig/3)/2,  p.HeightBig-p.HeightBig/16, p.WidthBig/3, p.HeightBig/16];
p.PosButtons = [p.WidthBig/16 p.HeightBig/2.5 p.WidthBig/25 p.WidthBig/25];
p.PosButtons_Small = [p.WidthSmall/16 p.HeightSmall/2.5 p.WidthSmall/25 p.WidthSmall/25];
p.PosBottom2 = [p.WidthBig/2-(p.WidthBig/16)/2, p.HeightBig/7.5, p.WidthBig/16, p.HeightBig/16];
p.PosInstruction2 = [p.WidthBig/4+p.WidthBig/2.5+p.WidthBig/10, p.HeightBig/1.5, p.WidthBig/16, p.HeightBig/16];
p.PosInstruction3 = [p.WidthBig/4+p.WidthBig/2.5+p.WidthBig/10, p.HeightBig/1.5+p.HeightBig/16, p.WidthBig/16, p.HeightBig/16];
p.PosInstruction4 = [p.WidthBig/16, p.HeightBig/1.5+p.HeightBig/16, p.WidthBig/12, p.HeightBig/8];

p.PosPause1 = [p.WidthSmall/2-p.WidthSmall/12, p.HeightSmall/1.5+p.HeightSmall/16, p.WidthSmall/8, p.HeightSmall/16];
p.PosPause2 = [p.WidthBig/2-p.WidthBig/12, p.HeightBig/1.5+p.HeightBig/16, p.WidthBig/12, p.HeightBig/16];


% user figures
im_play=imread('play.jpg');
play_axes_handel = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosCenter, 'XTick', [], 'YTick', []);
axes(play_axes_handel)
p.ImagePlay=image(im_play);
set(p.ImagePlay, 'Visible','off')
set(play_axes_handel, 'Visible','off')

im_speaker=imread('speaker.jpg');
speaker_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosCenter, 'XTick', [], 'YTick', []);
axes(speaker_image_axes_handle)
p.ImageSpeaker=image(im_speaker);
set(p.ImageSpeaker, 'Visible','off') 
set(speaker_image_axes_handle, 'Visible','off')

im_voice=imread('voice.jpg');
voice_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosCenter, 'XTick', [], 'YTick', []);
axes(voice_image_axes_handle)
p.ImageVoice=image(im_voice);
set(p.ImageVoice, 'Visible','off') 
set(voice_image_axes_handle, 'Visible','off')

im_arrow=imread('continue_arrow.jpg');
arrow_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosBottom, 'XTick', [], 'YTick', []);
axes(arrow_image_axes_handle)
p.ImageArrow=image(im_arrow);
set(p.ImageArrow, 'Visible','off') 
set(arrow_image_axes_handle, 'Visible','off')
    
p.Text = uicontrol('Parent', p.f1, 'Style', 'text', 'Position', p.PosText, 'Fontsize', 16, 'HorizontalAlignment', 'left', 'BackgroundColor', [1 1 1], 'Visible', 'off');

im_arrow2=imread('continue_arrow.jpg');
arrow_image_axes_handle2 = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosRight, 'XTick', [], 'YTick', []);
axes(arrow_image_axes_handle2)
p.ImageArrow2=image(im_arrow2);
set(p.ImageArrow2, 'Visible','off') 
set(arrow_image_axes_handle2, 'Visible','off')

john_intro=imread('john_intro.jpg');
john_intro_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosJohn, 'XTick', [], 'YTick', []);
axes(john_intro_image_axes_handle)
p.ImageJohnIntro=image(john_intro);
set(p.ImageJohnIntro, 'Visible','off') 
set(john_intro_image_axes_handle, 'Visible','off')

john_sleeping=imread('john_sleeping.jpg');
john_sleeping_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosJohn, 'XTick', [], 'YTick', []);
axes(john_sleeping_image_axes_handle)
p.ImageJohnSleeping=image(john_sleeping);
set(p.ImageJohnSleeping, 'Visible','off') 
set(john_sleeping_image_axes_handle, 'Visible','off')
    
john_happy=imread('john_happy.jpg');
john_happy_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosJohn, 'XTick', [], 'YTick', []);
axes(john_happy_image_axes_handle)
p.ImageJohnHappy=image(john_happy);
set(p.ImageJohnHappy, 'Visible','off') 
set(john_happy_image_axes_handle, 'Visible','off')

john_neutral=imread('john_neutral.jpg');
john_neutral_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosJohn, 'XTick', [], 'YTick', []);
axes(john_neutral_image_axes_handle)
p.ImageJohnNeutral=image(john_neutral);
set(p.ImageJohnNeutral, 'Visible','off') 
set(john_neutral_image_axes_handle, 'Visible','off')
    
john_yawning=imread('john_yawning.jpg');
john_yawning_image_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosJohn, 'XTick', [], 'YTick', []);
axes(john_yawning_image_axes_handle)
p.ImageJohnYawning=image(john_yawning);
set(p.ImageJohnYawning, 'Visible','off') 
set(john_yawning_image_axes_handle, 'Visible','off')

answer=imread('answer.jpg');
answer_axes_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosBottom, 'XTick', [], 'YTick', []);
axes(answer_axes_handle)
p.ImageAnswer=image(answer);
set(p.ImageAnswer, 'Visible','off') 
set(answer_axes_handle, 'Visible','off')

replay=imread('replay.jpg');
replay_aces_handle = axes('Visible', 'off', 'Parent', p.f1, 'Units', 'pixel','Position', p.PosBottom, 'XTick', [], 'YTick', []);
axes(replay_aces_handle)
p.ImageReplay=image(replay);
set(p.ImageReplay, 'Visible','off') 
set(replay_aces_handle, 'Visible','off')

p.InstructionHandle1= uicontrol('Parent', p.f1, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosInstruction1, ...
'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  

% user 2 figure preperation
p.ImreadConfirm = imread('confirm.jpg');
p.ImreadWrong = imread('wrong.jpg');
p.ImreadRight = imread('right.jpg');

% pause instruction
p.InstructionHandle6 = uicontrol('Parent', p.f2, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosPause2, ...
        'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  
p.InstructionHandle7= uicontrol('Parent', p.f1, 'Style', 'text', 'Units', 'pixel', 'Position', p.PosPause1, ...
        'FontSize', 20, 'ForegroundColor', p.MainTextColor, 'BackgroundColor', p.BackgroundColor);  

% initialize spacebar callback
set(p.f2, 'KeyPressFcn', {@spacebar_callback});
set(p.f1, 'KeyPressFcn', {@spacebar_callback});


function p = initialize_saved(p)
p.i = p.i2;
p.AnnotationsAvailable = p.i;
assignin('caller', 'User_Sitch',  20)
assignin('caller', 'User2_Sitch',  [1 0])
if p.i2 == 1
    clear all
    close all
    save('backup.mat')
    error('Restart experiment')
end


function [case_out, p] = get_user_sitch(p, current_sitch)

switch current_sitch
    case 1
        switch p.Phase
            case 'Training1'
                case_out = 2;
            case 'Training2'
                case_out = 3;
            case {'Test1', 'Test2', 'Test3', 'Test4'}
                case_out = 10;
        end
    case 2
        case_out = 3;
    case 3
        case_out = 4;
    case 4
        if strcmp(p.Player.Running, 'off')==1
            case_out = 25;
        else
            case_out = 0;
        end
    case 10
        case_out = 11;
    case 11
        case_out = 12;
    case 12
        if p.i <= p.TotalSampleLength
            case_out = 10;
        else
            switch p.Phase
                case 'Test1'
                    case_out = 13;
                case {'Training1', 'Training2'}
                    case_out = 14;
                case {'Test2', 'Test3', 'Test4'}
                    case_out = 15;
            end
        end
    case 13
        case_out = 14;
    case 14
        case_out = 15;
    case 15
        set(p.ImageJohnHappy, 'Visible', 'off')
        case_out = 0;
    case 20
        case_out = 10;
    case 25
        case_out = 26;     
    case 26
        case_out = 29;
    case 27
        if strcmp(p.Player.Running, 'off')==1
            case_out = 28;
        else
            case_out = 0;
        end
      case 28
         case_out = 0;
         set(p.ImageJohnHappy, 'Visible', 'off')
         set(p.Text, 'Visible', 'off');
         set(p.ImageArrow2, 'Visible', 'off')
    case 29
        case_out = 27;

end
p.current_sitch = case_out;


function additional_masker = get_additional_masker(p, conditions)

list = p.MaskerLists(1) + round(rand()*(p.MaskerLists(2) - p.MaskerLists(1)));
index3 = round((((list-1)*13)+round(rand()*13)));
    
if exist(fullfile('masker files', sprintf('%s%03d_f0%d_vtl%d.wav', p.ManVrouw, index3, conditions(2), conditions(3))), 'file') ~= 0
	masker3 = wavread(fullfile('masker files', sprintf('%s%03d_f0%d_vtl%d.wav', p.ManVrouw, index3, conditions(2), conditions(3))));
else
    masker3 = wavread(fullfile('sentences', sprintf('%s%03d.wav', p.ManVrouw, index3)));
    [p, masker3] = modify_masker(p, masker3, conditions, p.fs, p.ManVrouw, index3);
end
    
start = round(rand()*(length(masker3)-p.fs));

additional_masker = masker3(start+1:end);
additional_masker = cosgate(additional_masker, p.fs, 2e-3);

