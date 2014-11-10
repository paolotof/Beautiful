function [options, phase] = playGame(options, phase, expe, results)


    %% introduce the animation bit
    % Start a new Game
%     G = SpriteKit.Game.instance('Title','Interactive Demo','Size',[800 600]);
    G = SpriteKit.Game.instance('Title','Interactive Demo','Size',[1378 886]);
%     bkg = SpriteKit.Background('img/fishTankBackground.jpg');
    bkg = SpriteKit.Background('img/BACKGROUND.png');
%     bkg.Scale = 1;

    addBorders(G);
    % Setup the SpriteS
    s = SpriteKit.Sprite('fishOne');
    s.initState('swimLeft1','img/L_fish_a.png',true);
    s.initState('swimLeft2','img/L_fish_b.png',true);
    s.initState('swimLeft3','img/L_fish_a.png',true);
    s.initState('swimLeft4','img/L_fish_c.png',true);
    s.initState('swimRight1','img/R_fish_a.png',true);
    s.initState('swimRight2','img/R_fish_b.png',true);
    s.initState('swimRight3','img/R_fish_a.png',true);
    s.initState('swimRight4','img/R_fish_c.png',true);
    s.Scale = 1;
    s.State = 'swimRight1';
    % Add pertinent properties to the Sprite handle
    addprop(s,'accel');
    s.accel = [0 0];
%     addprop(s,'i_correct');
%     addprop(s,'begTime');
%     
    
    % 3 CHOICES FISHES
    tFish = SpriteKit.Sprite('tFish');
    tFish.initState('on','img/half_fishyTorquoise.png',true);
    clickArea = size(imread('img/half_fishyTorquoise.png'));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(tFish,'clickL');
    addprop(tFish,'clickR');
    addprop(tFish,'clickU');
    addprop(tFish,'clickD');
    tFish.Location = [100 100];
    tFish.clickL = round(tFish.Location(1) - width);
    tFish.clickR = round(tFish.Location(1) + width);
    tFish.clickD = round(tFish.Location(2) - heigth);
    tFish.clickU = round(tFish.Location(2) + heigth);
    tFish.State = 'on';
    addprop(tFish, 'key');
    tFish.key = 1;
    %
    yFish = SpriteKit.Sprite('yFish');
    yFish.initState('on','img/half_FishyEllow.png',true);
    clickArea = size(imread('img/half_FishyEllow.png'));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(yFish,'clickL');
    addprop(yFish,'clickR');
    addprop(yFish,'clickU');
    addprop(yFish,'clickD');
    yFish.Location = [300 100];
    yFish.clickL = round(yFish.Location(1) - width);
    yFish.clickR = round(yFish.Location(1) + width);
    yFish.clickD = round(yFish.Location(2) - heigth);
    yFish.clickU = round(yFish.Location(2) + heigth);
    yFish.State = 'on';
    addprop(yFish, 'key');
    yFish.key = 2;
    %
    rFish = SpriteKit.Sprite('rFish');
    rFish.initState('on','img/half_FishyRed.png',true);
    clickArea = size(imread('img/half_FishyRed.png'));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(rFish,'clickL');
    addprop(rFish,'clickR'); 
    addprop(rFish,'clickU'); 
    addprop(rFish,'clickD');
    rFish.Location = [500 100];
    rFish.clickL = round(rFish.Location(1) - width);
    rFish.clickR = round(rFish.Location(1) + width);
    rFish.clickD = round(rFish.Location(2) - heigth);
    rFish.clickU = round(rFish.Location(2) + heigth);
    rFish.State = 'on';
    addprop(rFish, 'key');
    rFish.key = 3;
    

    %% Setup KeyPressFcn and others
%     G.onKeyPress = @keypressfcn;
    G.onMouseRelease = @buttonupfcn;
    
%% set up of the experimental interface
    nbreak = 0;
    beginning_of_session = now();

    % Find first condition not done
    i_condition = find([expe.( phase ).conditions.done]==0, 1);
    fprintf('\n============================ Testing condition %d / %d ==========\n', i_condition, length(expe.( phase ).conditions))
    condition = expe.( phase ).conditions(i_condition);

    %  ---- Adaptive Procedure ----  %

    difference = [condition.starting_glide_size];
    step_size  = options.(phase).initial_step_size;
    steps = [];
    
    response_correct = [];
    decision_vector  = [];
    nturns = 0;

    beginning_of_run = now();

    
    
    
    %% ------   start the GAME
    iter = 0;
    G.play(@action);
    

%% GAME functions, to be called on each tic/toc of gameplay
 
%% Functions for user interactions
    function action
        
        iter = iter+1;
        
        % decay to [0 0] accel
        s.accel = s.accel*0.97; % lose %3 of its acceleration
        L = s.Location;
        L = L + s.accel;
        s.Location = L;
        
%         mole.Angle = mole.Angle-1;
        tFish.Angle = tFish.Angle-1;
        
%         bkg.scroll('right',0.1);
    end % end of action function


    function buttonupfcn(hObject,callbackdata)

        locClick = get(hObject,'CurrentPoint');
        
        if (locClick(1) >= tFish.clickL) && (locClick(1) <= tFish.clickR) && ...
                (locClick(2) >= tFish.clickD) && (locClick(2) <= tFish.clickU)
            % disp('blue clicked') - THIS IS 1
            % add a click option on each fish
            
            response.response_time = now - proceed.onsetTime;
            response.timestamp = now();
            % Fill the response structure
            response.button_correct = proceed.i_correct;
            response.button_clicked = tFish.key;
            response.correct = (proceed.i_correct == tFish.key);
            response_correct = [response_correct, response.correct];
            decision_vector  = [decision_vector,  response.correct];
            response.condition = condition;
            
            [options, phase, expe, results, difference, decision_vector, nturns, step_size, steps] = setupNextValues(options, phase, expe, results, response, difference, ...
                response_correct, decision_vector, nturns, step_size, steps);

            [player, isi, proceed.i_correct] = nextTrial(options, phase, expe);
            playSound(player, isi);

            tFish.Scale = 1.5;
%         playblocking(player{1});
%         tFish.Scale = 1;
            
            
            
        end

        if (locClick(1) >= rFish.clickL) && (locClick(1) <= rFish.clickR) && ...
                (locClick(2) >= rFish.clickD) && (locClick(2) <= rFish.clickU)
            
            response.response_time = now - proceed.onsetTime;
            response.timestamp = now();
            % Fill the response structure
            response.button_correct = proceed.i_correct;
            response.button_clicked = rFish.key;
            response.correct = (proceed.i_correct == rFish.key);
            response_correct = [response_correct, response.correct];
            decision_vector  = [decision_vector,  response.correct];
            response.condition = condition;
            
            [options, phase, expe, results, difference, decision_vector, nturns, step_size, steps] = setupNextValues(options, phase, expe, results, response, difference, ...
                response_correct, decision_vector, nturns, step_size, steps);
            [player, isi, proceed.i_correct] = nextTrial(options, phase, expe);
            playSound(player, isi);
        end
        
        if (locClick(1) >= yFish.clickL) && (locClick(1) <= yFish.clickR) && ...
                (locClick(2) >= yFish.clickD) && (locClick(2) <= yFish.clickU)
            
            response.response_time = now - proceed.onsetTime;
            response.timestamp = now();
            % Fill the response structure
            response.button_correct = proceed.i_correct;
            response.button_clicked = yFish.key;
            response.correct = (proceed.i_correct == yFish.key);
            response_correct = [response_correct, response.correct];
            decision_vector  = [decision_vector,  response.correct];
            response.condition = condition;
            
            [options, phase, expe, results, difference, decision_vector, nturns, step_size, steps] = setupNextValues(options, phase, expe, results, response, difference, ...
                response_correct, decision_vector, nturns, step_size, steps);
            [player, isi, proceed.i_correct] = nextTrial(options, phase, expe);
            playSound(player, isi);
        end
        
        % if all trials have been performed close up everything and greet
%         if (locClick(1) >= terminate.clickL) && (locClick(1) <= terminate.clickR) && ...
%                 (locClick(2) >= terminate.clickD) && (locClick(2) <= terminate.clickU)
%             fprintf('We shall stop, OK! ciaociao\n');
%             stop(G);
%             close gcf;
%         end
       
    end % end of buttonupfcn function 

%     function playSound(player, isi)
%         % Play the stimuli
%         tFish.Scale = 1.5;
%         playblocking(player{1});
%         tFish.Scale = 1;
%         playblocking(isi);
%         yFish.Scale = 1.5;
%         playblocking(player{2});
%         yFish.Scale = 1;
%         playblocking(isi);
%         rFish.Scale = 1.5;
%         playblocking(player{3});
%         rFish.Scale = 1;
% %         playblocking(isi);
%         proceed.onsetTime = now();
%     end
%     startTime = now();
%     startTime = tic();% Collect the response
        

    
end % end of the setUpGame function 