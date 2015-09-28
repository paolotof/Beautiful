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
h.set_sylls({'1', '2', '3'});
h.disable_buttons();
drawnow()

nbreak = 0;
starting = 1;

DEBUG = true;
SIMUL = 0;

test_machine = is_test_machine();

beginning_of_session = now();

%=============================================================== MAIN LOOP

while mean([expe.( phase ).trials.done])~=1 % Keep going while there are some conditions to do
    
    % If we start, display a message

    instr = strrep(options.instructions.(phase), '\n', sprintf('\n'));
    if ~isempty(instr) && starting
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
        msg.w = figure('Visible', 'off', 'Position', [left+(width-msgw)/2, (height-msgh)/2, msgw, msgh], 'Menubar', 'none', 'Resize', 'off', 'Color', [1 1 1]*.9, 'Name', 'Instructions');

        msg.txt = uicontrol('Style', 'text', 'Position', [mr, 50+mr*2, msgw-mr*2, msgh-(50+mr)-mr*2], 'Fontsize', 18, 'HorizontalAlignment', 'left', 'BackgroundColor', [1 1 1]*.9);
        instr = textwrap(msg.txt, {instr});
        set(msg.txt, 'String', instr);
        msg.bt = uicontrol('Style', 'pushbutton', 'Position', [msgw/2-50, mr, 100, 50], 'String', 'OK', 'Fontsize', 14, 'Callback', 'uiresume');
        set(msg.w, 'Visible', 'on');
        uicontrol(msg.bt);

        uiwait(msg.w);
        close(msg.w);
    end

    opt = char(questdlg2(sprintf('Ready to start?'),h,'Go','Cancel','Go'));
    switch lower(opt)
        case 'cancel'
            break
    end

    starting = 0;
    
    % Prepare the GUI
    h.show_instruction();
    h.show_buttons();
    h.set_instruction(sprintf('What did you hear?'));
    h.set_progress(strrep(phase, '_', ' '), sum([expe.( phase ).trials.done])+1, length([expe.( phase ).trials.done]));
    
    % Find first condition not done
    i_trial = find([expe.( phase ).trials.done]==0, 1);
    fprintf('\n============================ Testing condition %d / %d ==========\n', i_trial, length(expe.( phase ).trials))
    trial = expe.( phase ).trials(i_trial);

    if condition.vocoder==0
        fprintf('No vocoder\n\n');
    else
        fprintf('Vocoder: %s\n\n', options.vocoder(condition.vocoder).label);
    end
    
    %---------------------------------- Procedure
    
    [xOut, fs, sentence_correct] = expe_make_stim(options, trial);
    x = xOut*10^(-options.attenuation_dB/20);
    player = audioplayer([zeros(1024*3, 2); x; zeros(1024*3, 2)], fs, 16);

    response = struct()
    response.beginning_of_session = beginning_of_session;
    
    % Display message "LISTEN"
    
    pause(.5);
    playblocking(player);
    
    % Display message "REPEAT"
    tic();
    
    % Collect the response
    if SIMUL
        if difference+randn(1)>1
            i_clicked = i_correct;
        else
            i_clicked = i_correct+1;
        end
        response.response_time = toc();
        response.timestamp = now();
    else
        ok = false;
        while ~ok
            uiwait();
            response.response_time = toc();
            response.timestamp = now();
            h = get(h.f, 'UserData');
            i_clicked = h.last_clicked;
            if ~isnan(i_clicked)
                ok = true;
                fprintf('Click!\n');
            end
        end
    end

    %h.last_clicked = NaN;
    %set(h.f, 'UserData', h);

    h.disable_buttons();

    % Fill the response structure
    response.sentence_correct = sentence_correct;
    response.words_correct = i_clicked;
    response.trial = trial;

    % Visual feedback
    if condition.visual_feedback == 1
        % Display words that are correct ?
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

    % Add the response to the results structure
    
    if ~isfield(results, phase)
        results.( phase ).responses = orderfields( response );
    else
        results.( phase ).responses(end+1) = orderfields( response );
    end    
        
    % Save the response
    save(options.res_filename, 'options', 'expe', 'results')

    expe.( phase ).trials(i_trial).done = 1;
    
    % Report status
    report_status(options.subject_name, phase, sum([expe.( phase ).trials.done])+1, length([expe.( phase ).trials.done]), options.log_file);
    
    % Display "take a break" message if necessary
    %{
    if options.(phase).block_size>0
        nbreak = nbreak+1;
        if nbreak>=options.(phase).block_size && mean([expe.( phase ).conditions.done])~=1
            nbreak = 0;
            opt = char(questdlg(sprintf('Take a short break...\nThen would you like to continue or stop?'),'','Continue','Stop','Continue'));
            switch lower(opt)
                case 'stop'
                    break
            end
        end
    end
    %}
    
    h.show_instruction();
    
    % Wait a bit before to go to next condition
    pause(.5);
    
end

% If we're out of the loop because the phase is finished, tell the subject
if mean([expe.( phase ).trials.done])==1
    %msgbox(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')), '', 'warn');
    questdlg2(sprintf('The "%s" phase is finished. Thank you!', strrep(phase, '_', ' ')),h,'OK','OK');
end

close(h.f);

%--------------------------------------------------------------------------
function report_status(subj, phase, i, n, logFile)

try
    fd = fopen(logFile, 'w');
    fprintf(fd, '%s : %s : %d/%d\r\n', subj, phase, i, n);
    fclose(fd);
catch ME
    % Stay silent if it failed
end
