function [G, bkg, bigFish, friends] = setUpGame(friend)


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
    bigFish = SpriteKit.Sprite('fishOne');
    initState(bigFish,'fishOne','../img/fixed/FISHY_TURN_1.png',true);
    for k=1:10
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
    % 3 CHOICES FISHES
    friends = updateFriend(G.Size(1), scrsz(4), friend);
    
    % outher corner
%     h = 
%     rectangle('Curvature', [1 1], 'Position', [102 102 18 18], 'EdgeColor', [115 230 255]./255, 'LineWidth', 10);
%     rectangle('Curvature', [1 1], 'Position', [100 100 20 20], 'EdgeColor', [0 115 255]./255, 'LineWidth', 3);
% %     rectangle('Curvature', [1 1], 'Position', [100 100 20 20], 'FaceColor', [115 230 255]./255, 'EdgeColor', 'none');
%     rectangle('Curvature', [1 1], 'Position', [105 110 5 5], 'FaceColor', [255 255 255]./255, 'EdgeColor', 'none');
%     rectangle('Curvature', [1 1], 'Position', [105 110 5 5], 'EdgeColor', [198 241 255]./255, 'LineWidth', 10);
    
  
%     bubble = rectangle('Curvature', [1 1], 'Position', [100 100 10 10], 'FaceColor', [198 241 255]./255, ...
%         'EdgeColor', [0 115 255]./255, 'LineWidth', 2);
% 
%     bubble2= rectangle('Curvature', [1 1], 'Position', [100 100 10 10], 'FaceColor', [0 115 255]./255, ...
%         'EdgeColor', [198 241 255]./255, 'LineWidth', 2);
%   
%     set(bubble, 'Visible', 'off')  
%     set(bubble2, 'Visible', 'off')  
%   
% %     rectangle('Curvature', [1 1], 'Position', [105 110 5 5], 'FaceColor', [255 255 255]./255, ...
% %         'EdgeColor', [115 230 255]./255, 'LineWidth', 20);
%     
%     rectangle('Curvature', [1 1], 'Position', [101 101 18 18], 'FaceColor', 'none', ...
%         'EdgeColor', [198 241 255]./255, 'LineWidth', 30);
%     rectangle('Curvature', [1 1], 'Position', [100 100 20 20], 'FaceColor', 'none', ...
%         'EdgeColor', [0 115 255]./255, 'LineWidth', 10);
%     rectangle('Curvature', [1 1], 'Position', [105 105 10 10], 'FaceColor', 'none', ...
%         'EdgeColor', [115 230 255]./255, 'LineWidth', 20);
%     rectangle('Curvature', [1 1], 'Position', [105 110 5 5], 'FaceColor', [0 255 255]./255, ...
%         'EdgeColor', 'none');
%     
%     set(h, 'Visible', 'off')
%     set(h, 'Visible', 'on')
    

    %% Setup KeyPressFcn and others
%     G.onKeyPress = @keypressfcn;
%     G.onMouseRelease = @buttonupfcn;
        
    %% ------   start the GAME
%     iter = 0;
%     G.play(@()action(argin));
%     G.play(@action);
%     pause(1);

    
end % end of the setUpGame function 