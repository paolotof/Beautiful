function expe_main(options, phase)

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-02-24
% RuG / UMCG KNO, Groningen, NL
%--------------------------------------------------------------------------

results = struct();
load(options.res_filename); % options, expe, results

h = expe_gui(options);
h.hide_instruction();
h.set_progress(strrep(phase, '_', ' '), 0, 0);
drawnow()

nbreak = 0;
starting = 1;

% Set Level
if ispc()
    pa_init(options.fs);
    setPA4(3, 0);
    setPA4(4, 0);
    setPA4(1, options.attenuation_dB);
    setPA4(2, options.attenuation_dB);
end

%=============================================================== MAIN LOOP

while mean([expe.( phase ).trials.done])~=1 % Keep going while there are some trials to do
    
    
    % Prepare the GUI
    h.hide_buttons();
    h.set_instruction(sprintf('Listen...\nWhich syllable is repeated?'));
    
    % If we start, display a message
    if starting
        
        instr = strrep(options.instructions.(phase), '\n', sprintf('\n'));
        if ~isempty(instr)
            scrsz = get(0,'ScreenSize');
            if ~test_machine
                left=scrsz(1); bottom=scrsz(2); width=scrsz(3); height=scrsz(4);
            else
                left = -1024; bottom=0; width=1024; height=768;
            end
            scrsz = [left, bottom, width, height];
            
            msg = struct();
            msgw = 900;
            msgh = 650;
            mr = 60;
            msg.w = figure('Visible', 'off', 'Position', [(width-msgw)/2, (height-msgh)/2, msgw, msgh], 'Menubar', 'none', 'Resize', 'off', 'Color', [1 1 1]*.9, 'Name', 'Instructions');

            msg.txt = uicontrol('Style', 'text', 'Position', [mr, 50+mr*2, msgw-mr*2, msgh-(50+mr)-mr*2], 'Fontsize', 18, 'HorizontalAlignment', 'left', 'BackgroundColor', [1 1 1]*.9);
            instr = textwrap(msg.txt, {instr});
            set(msg.txt, 'String', instr);
            msg.bt = uicontrol('Style', 'pushbutton', 'Position', [msgw/2-50, mr, 100, 50], 'String', 'OK', 'Fontsize', 14, 'Callback', 'uiresume');
            set(msg.w, 'Visible', 'on');
            uicontrol(msg.bt);

            uiwait(msg.w);
            close(msg.w);
        end
        
        opt = char(questdlg(sprintf('Ready to start the %s?', strrep(phase, '_', ' ')),'','Go','Cancel','Go'));
        switch lower(opt)
            case 'cancel'
                break
        end
        
        starting = 0;
    end
    
    h.show_instruction();
    
    % Find first trial not done
    i = find([expe.( phase ).trials.done]==0, 1);
    trial = expe.( phase ).trials(i);
    
    % Prepare the stimulus
    [xOut, fs] = expe_make_stim(options, trial);
    player = audioplayer(xOut, fs, 16);
    
    pause(.5);
    
    % Play the stimulus
    playblocking(player);
    
    % Prepare the GUI
    h.set_progress(strrep(phase, '_', ' '), sum([expe.( phase ).trials.done])+1, length([expe.( phase ).trials.done]));
    h.set_sylls(trial.proposed_syll(trial.syll_order));
    h.hide_instruction();
    h.show_buttons();
    drawnow();
    
    tic();
    
    % Collect the response
    ok = false;
    uiwait();
    response.response_time = toc();
    response.timestamp = now();

    h = get(h.f, 'UserData');
    i_clicked = h.last_clicked;
    
    % Fill the response structure
    response.button_correct = find(trial.syll_order==1);
    response.button_clicked = i_clicked;
    response.syll_clicked   = trial.proposed_syll{trial.syll_order(i_clicked)};
    response.correct = (response.button_clicked == response.button_correct);
    response.trial = trial;
    
    % Visual feedback
    if trial.visual_feedback == 1
        if response.correct
            feedback_color = h.button_right_color;
        else
            feedback_color = h.button_wrong_color;
        end
        for k=1:3
            pause(.1);
            set(h.patch(response.button_correct), 'FaceColor', feedback_color);
            drawnow();
            pause(.1);
            set(h.patch(response.button_correct), 'FaceColor', h.button_face_color);
            drawnow();
        end
    end
    
    %{
    if trial.pause_when_wrong == 1
        if response.correct~=1
            
            tmp_txt = get(h.waitbar_legend, 'String');
            set(h.waitbar_legend, 'String', 'Paused');
            
            ok = false;
            while ~ok
                k = waitforbuttonpress();
                if k~=0
                    k = get(gcf, 'CurrentCharacter');
                    if double(k)==32 || double(k)==13
                        ok = true;
                    end
                end
            end
            
            set(h.waitbar_legend, 'String', tmp_txt);
        end
    end
   
    
    % Reset GUI if visual feedback was given
    if trial.visual_feedback == 1
        set(t(infoTarget.color_index, infoTarget.number), 'Color', [0 0 0], 'FontSize', fntsz)
        drawnow();
    end
    %}
    
    % Add the response to the results structure
    if ~isfield(results, phase)
        results.( phase ).responses = orderfields( response );
    else
        results.( phase ).responses(end+1) = orderfields( response );
    end
    
    % Mark the trial as done
    expe.( phase ).trials(i).done = 1;
    
    % Save the response
    save(options.res_filename, 'options', 'expe', 'results')
    
    % Report status
    report_status(options.subject_name, phase, sum([expe.( phase ).trials.done])+1, length([expe.( phase ).trials.done]), options.log_file);
    
    % Display "take a break" message if necessary
    if options.(phase).block_size>0
        nbreak = nbreak+1;
        if nbreak>=options.(phase).block_size && mean([expe.( phase ).trials.done])~=1
            nbreak = 0;
            opt = char(questdlg(sprintf('Take a short break...\nThen would you like to continue or stop?'),'','Continue','Stop','Continue'));
            switch lower(opt)
                case 'stop'
                    break
            end
        end
    end
    
    % Wait a bit before to go to next trial
    h.hide_buttons();
    pause(1);
    
end

% If we're out of the loop because the phase is finished, tell the subject
if mean([expe.( phase ).trials.done])==1
    msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
end

close all

%--------------------------------------------------------------------------
function report_status(subj, phase, i, n, logFile)

try
    fd = fopen(logFile, 'w');
    fprintf(fd, '%s : %s : %d/%d\r\n', subj, phase, i, n);
    fclose(fd);
catch ME
    % Stay silent if it failed
end
