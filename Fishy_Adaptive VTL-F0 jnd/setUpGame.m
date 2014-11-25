function [G, bkg, bigFish, bubbles] = setUpGame


    %% introduce the animation bit
    % Start a new Game
    scrsz = get(0,'ScreenSize');
%     left=scrsz(1); bottom=scrsz(2); width=scrsz(3); height=scrsz(4);
%     scrsz = [left, bottom, width, height];
    % adapt screen size to Jop image size
    if scrsz(3) > 1600
        scrsz(3) = 1600;
    end
    if scrsz(4) > 1200
        scrsz(4) = 1200;
    end
    G = SpriteKit.Game.instance('Title','Fishy Game','Size',[scrsz(3) scrsz(4)]);
%     G = SpriteKit.Game.instance('Title','Fishy Game','Size',[1600 1200]);
    bkg = SpriteKit.Background('../img/fixed/BACKGROUND.png');
    bkg.Scale = 1;

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
    bigFish.Location = [scrsz(3)/2, scrsz(4)-450];
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