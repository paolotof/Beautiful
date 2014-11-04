function [options, phase] = setUpGame(options, phase, expe, results)


    %% introduce the animation bit
    % Start a new Game
    G = SpriteKit.Game.instance('Title','Interactive Demo','Size',[800 600]);
%     bkg = SpriteKit.Background('/home/paolot/Downloads/SpriteKit/tryFish/img/fishTankBackground.jpg');
%     bkg.Scale = 1;
    addBorders(G);
    % Setup the SpriteS
    s = SpriteKit.Sprite('fishOne');
    s.initState('swimLeft1','/home/paolot/Downloads/SpriteKit/tryFish/img/L_fish_a.png',true);
    s.initState('swimLeft2','/home/paolot/Downloads/SpriteKit/tryFish/img/L_fish_b.png',true);
    s.initState('swimLeft3','/home/paolot/Downloads/SpriteKit/tryFish/img/L_fish_a.png',true);
    s.initState('swimLeft4','/home/paolot/Downloads/SpriteKit/tryFish/img/L_fish_c.png',true);
    s.initState('swimRight1','/home/paolot/Downloads/SpriteKit/tryFish/img/R_fish_a.png',true);
    s.initState('swimRight2','/home/paolot/Downloads/SpriteKit/tryFish/img/R_fish_b.png',true);
    s.initState('swimRight3','/home/paolot/Downloads/SpriteKit/tryFish/img/R_fish_a.png',true);
    s.initState('swimRight4','/home/paolot/Downloads/SpriteKit/tryFish/img/R_fish_c.png',true);
    s.Scale = 1;
    s.State = 'swimRight1';
    % Add pertinent properties to the Sprite handle
    addprop(s,'accel');
    s.accel = [0 0];
    % 3 CHOICES FISHES
    tFish = SpriteKit.Sprite('tFish');
    tFish.initState('on','/home/paolot/Downloads/SpriteKit/tryFish/img/half_fishyTorquoise.png',true);
    tFish.State = 'on';
    tFish.Location = [100 100];
    %
    yFish = SpriteKit.Sprite('yFish');
    yFish.initState('on','/home/paolot/Downloads/SpriteKit/tryFish/img/half_FishyEllow.png',true);
    yFish.State = 'on';
    yFish.Location = [300 100];
    %
    rFish = SpriteKit.Sprite('rFish');
    rFish.initState('on','/home/paolot/Downloads/SpriteKit/tryFish/img/half_FishyRed.png',true);
    rFish.State = 'on';
    rFish.Location = [500 100];
    
    proceed =  SpriteKit.Sprite('proceed');
    proceed.initState('on','/home/paolot/Downloads/SpriteKit/tryFish/img/continue.png',true);
    proceed.State = 'on';
    proceed.Location = [500 500];
    proceed.Scale = .3;
    terminate =  SpriteKit.Sprite('terminate');
    terminate.initState('on','/home/paolot/Downloads/SpriteKit/tryFish/img/break.png',true);
    terminate.State = 'on';
    terminate.Location = [600 500];
    terminate.Scale = .3;

    %% Setup KeyPressFcn and others
    G.onKeyPress = @keypressfcn;
    G.onMouseRelease = @buttonupfcn;
    
    nbreak = 0;
    starting = 1;
    DEBUG = true;
    SIMUL = 0;
    beginning_of_session = now();

    
    
    %% ------   start the GAME
    iter = 0;
    G.play(@action);
    

%% GAME functions, to be called on each tic/toc of gameplay
    function action
        
        iter = iter+1;
        
        % decay to [0 0] accel
        s.accel = s.accel*0.97; % lose %3 of its acceleration
        L = s.Location;
        L = L + s.accel;
        s.Location = L;
        
        %         mole.Angle = mole.Angle-1;
        %         bkg.scroll('right',0.1);
        
        [collide,target] = SpriteKit.Physics.hasCollision(s);
        if collide
            switch target.ID
                case 'topborder'
                    s.accel(2) = -abs(s.accel(2));
                case 'bottomborder'
                    s.accel(2) = abs(s.accel(2));
                case 'leftborder'
                    s.State = 'swimRight1';
                    s.accel(1) = abs(s.accel(1));
                case 'rightborder'
                    s.State = 'swimLeft1';
                    s.accel(1) = -abs(s.accel(1));
                case 'rFish'
                    newLoc(1) = randi([50 G.Size(1)-50]);
                    newLoc(2) = randi([50 G.Size(2)-50]);
                    rFish.Location = newLoc;
            end
        end
        
    end % end of action function

%% Functions for user interactions
    function buttonupfcn(src,a)
        
        locClick = get(gcf,'CurrentPoint');
        clickArea = 20;
        if (locClick(1) >= (yFish.Location(1) - clickArea)) && ...
                (locClick(1) <= (yFish.Location(1) + clickArea)) && ...
                (locClick(2) >= (yFish.Location(2) - clickArea)) && ...
                (locClick(2) <= (yFish.Location(2) + clickArea))
            newLoc(1) = randi([25 G.Size(1)-25]);
            newLoc(2) = randi([25 G.Size(2)-25]);
            yFish.Location = newLoc;
        end

        if (locClick(1) >= (proceed.Location(1) - clickArea)) && ...
                (locClick(1) <= (proceed.Location(1) + clickArea)) && ...
                (locClick(2) >= (proceed.Location(2) - clickArea)) && ...
                (locClick(2) <= (proceed.Location(2) + clickArea))
            
            nextTrial(options, phase, expe, results);
        end
               
        if (locClick(1) >= (terminate.Location(1) - clickArea)) && ...
                (locClick(1) <= (terminate.Location(1) + clickArea)) && ...
                (locClick(2) >= (terminate.Location(2) - clickArea)) && ...
                (locClick(2) <= (terminate.Location(2) + clickArea))

            fprintf('We shall stop, OK! ciaociao\n');
            stop(G);
            close gcf;
        end
       
    end % end of buttonupfcn function 

    
end % end of the setUpGame function 