function [G, bkg, bigFish, bubbles, screen2, gameCommands, hourglass] = setUpGame(maxTurns)

    % to test
    % addpath('../lib/SpriteKit');

    % PT: check if there are games already opened and close them
    fig = get(groot,'CurrentFigure');
    if ~isempty(fig)
        close fig
    end
    clear fig
    %% introduce the animation bit
    % Start a new Game
    
%     [screen1, screen2] = getScreens();
%     screen2 = screen1;
    [~, screen2] = getScreens();
    fprintf('Experiment will displayed on: [%s]\n', sprintf('%d ',screen2));
    % We put the game on screen 2
    
    G = SpriteKit.Game.instance('Title','Fishy Game', 'Size', screen2(3:4), 'Location', screen2(1:2), 'ShowFPS', false);

    bkg = SpriteKit.Background(resizeBackgroundToScreenSize(screen2, '../img/fixed/BACKGROUND_unscaled.png'));

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
    
%     bigFish.Scale = 1;
%     bigFish.State = 'fish_1';
%     bigFish.State = 'none'; PT: this is the initial state, no need to
%     initialize another, unless we want the fish to stay there
    bigFish.Location = [screen2(3)/2, screen2(4)-450];
%     addprop(bigFish, 'width');
%     addprop(bigFish, 'heigth');
%     tmp = imread('../img/fixed/FISHY_TURN_1.png');
%     bigFish.heigth = round(size(tmp,1)/2);
%     bigFish.width = round(size(tmp,2)/2);
%     clear tmp
    addprop(bigFish, 'arcAround1');
    addprop(bigFish, 'arcAround2');
    nFriends = 40;
%     [x, y] = getArc(5*pi/6, pi/6, bigFish.Location(1), bigFish.Location(2), 300, nFriends);
%     [x, y] = getArc(-1*pi/6, 7*pi/6, bigFish.Location(1), bigFish.Location(2), 200, nFriends);
    [x, y] = getArc(0, pi, bigFish.Location(1), bigFish.Location(2), 300, nFriends);
%     [bigFish.Location(1), bigFish.Location(2)]
    %[x, y] = getArc(5*pi/6, pi/6, 10, 512, 300, nFriends);
    bigFish.arcAround1 = round([x;y]);
    addprop(bigFish, 'availableLocArc1');
    bigFish.availableLocArc1 = randperm(nFriends);
    nFriends = 60;
    [x, y] = getArc(0, pi, bigFish.Location(1), bigFish.Location(2), 400, nFriends);
    bigFish.arcAround2 = [x;y];
    addprop(bigFish, 'availableLocArc2');
    bigFish.availableLocArc2 = randperm(nFriends);
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
    
    hourglass = SpriteKit.Sprite ('hourglass');
    hourglass.Location = [screen2(3)/1.10, screen2(4)/1.5];
    ratioscreen = 0.3 * screen2(4);
    [HeightHourglass, ~] = size(imread ('../img/fixed/hourglass_min_0.png'));
    hourglass.Scale = ratioscreen/HeightHourglass;
    counter = 0;
    nHourGlasses = 18;
    nturns = floor(nHourGlasses / maxTurns);
    for k = 0:nturns:17 
        hourglassname = sprintf ('hourglass_%d', counter); 
        pngFile = sprintf('../img/fixed/hourglass_min_%d.png', k);
        hourglass.initState (hourglassname, pngFile, true);
        counter = counter + 1;
    end 
    hourglass.State = 'hourglass_0';

    gameCommands = SpriteKit.Sprite('controls');
%     initState(gameCommands, 'none', zeros(2,2,3), true);
    initState(gameCommands, 'begin','../img/fixed/start.png' , true);
    initState(gameCommands, 'finish','../img/fixed/finish.png' , true);
    initState(gameCommands, 'empty', ones(1,1,3), true); % to replace the images, 'none' will give an annoying warning
    gameCommands.State = 'begin';
    gameCommands.Location = [screen2(3)/2, screen2(4)/2 + 40];
    gameCommands.Scale = 1.5; % make it bigger to cover fishy
    % define clicking areas
    clickArea = size(imread('../img/fixed/start.png'));
    addprop(gameCommands, 'clickL');
    addprop(gameCommands, 'clickR');
    addprop(gameCommands, 'clickD');
    addprop(gameCommands, 'clickU');
    gameCommands.clickL = round(gameCommands.Location(1) - round(clickArea(1)/2));
    gameCommands.clickR = round(gameCommands.Location(1) + round(clickArea(1)/2));
    gameCommands.clickD = round(gameCommands.Location(2) - round(clickArea(2)/2));
    gameCommands.clickU = round(gameCommands.Location(2) + round(clickArea(2)/2));
    clear clickArea 
    %% ------   start the GAME
%     iter = 0;
%     G.play(@()action(argin));
%     G.play(@action);
%     pause(1);

    
end % end of the setUpGame function 