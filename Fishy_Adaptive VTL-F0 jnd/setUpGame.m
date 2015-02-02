function [G, bkg, bigFish, bubbles, screen2] = setUpGame


    %% introduce the animation bit
    % Start a new Game
    
%     [screen1, screen2] = getScreens();
    [~, screen2] = getScreens();
    fprintf('Experiment will displayed on: [%s]\n', sprintf('%d ',screen2));
    % We put the game on screen 2
    
    % PT removed 
%     % adapt screen size to Jop image size
%     if screen2(3) > 1600
%         screen2(3) = 1600;
%     end
%     if screen2(4) > 1200
%         screen2(4) = 1200;
%     end
    
%     G = SpriteKit.Game.instance('Title','Fishy Game', 'Size', screen2(3:4), 'Location', screen2(1:2), 'ShowFPS', false, 'fitScreen', true);

    G = SpriteKit.Game.instance('Title','Fishy Game', 'Size', screen2(3:4), 'Location', screen2(1:2), 'ShowFPS', false);

%     bkg = SpriteKit.Background('../img/fixed/BACKGROUND_unscaled.png');
%     bkgName = resizeBackgroundToScreenSize(screen2, '../img/fixed/BACKGROUND_unscaled.png');
%     bkg = SpriteKit.Background(bkgName);
    bkg = SpriteKit.Background(resizeBackgroundToScreenSize(screen2, '../img/fixed/BACKGROUND_unscaled.png'));

%     bkg.Scale = screen2(4)/1200; % EG: Let's try to change the scale here...

    addBorders(G);
    % Setup the SpriteS
    bigFish = SpriteKit.Sprite('fish_1');
    initState(bigFish,'fish_1','../img/fixed/FISHY_TURN_1.png',true);
    for k=2:10
        spritename = sprintf('FISHY_TURN_%d',k);
        pngFile = ['../img/fixed/' spritename '.png'];
%         s.initState(spritename, pngFile, true);
        initState(bigFish, ['fish_' int2str(k)] , pngFile, true);
    end
    
    bigFish.Scale = 1;
%     bigFish.State = 'fishOne';
    bigFish.State = 'fish_1';
    bigFish.Location = [screen2(3)/2, screen2(4)-450];
    addprop(bigFish, 'arcAround');
    nFriends = 40;
    [x, y] = getArc(5*pi/6,pi/6, bigFish.Location(1)-100, bigFish.Location(2)-100, 400, nFriends);
    bigFish.arcAround = [x;y];
    addprop(bigFish, 'availableLoc');
    bigFish.availableLoc = randperm(nFriends);
    addprop(bigFish, 'iter')
    bigFish.iter = 1;
    addprop(bigFish, 'countTurns');
    bigFish.countTurns = 0;
    
    bubbles = SpriteKit.Sprite('noBubbles');
    bubbles.initState('noBubbles', ['../img/fixed/' 'bubbles_none' '.png'], true);
    for k=1:4
        spritename = sprintf('bubbles_%d',k);
        pngFile = ['../img/fixed/' spritename '.png'];
        bubbles.initState(spritename, pngFile, true);
    end
    bubbles.State = 'noBubbles';
    %% Setup KeyPressFcn and others
%     G.onKeyPress = @keypressfcn;
%     G.onMouseRelease = @buttonupfcn;
        
    %% ------   start the GAME
%     iter = 0;
%     G.play(@()action(argin));
%     G.play(@action);
%     pause(1);

    
end % end of the setUpGame function 