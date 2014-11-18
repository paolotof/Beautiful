function [G, bkg, bigFish, friends] = setUpGame(friend)


    %% introduce the animation bit
    % Start a new Game
    G = SpriteKit.Game.instance('Title','Fishy Game','Size',[1280 709]);
    bkg = SpriteKit.Background('../img/BACKGROUND.png');
    bkg.Scale = 1;

    addBorders(G);
    % Setup the SpriteS
    bigFish = SpriteKit.Sprite('fishOne');
%     bigFish.initState('swimLeft1','../img/fixed/L_fish_a.png',true);
%     bigFish.initState('swimLeft2','../img/fixed/L_fish_b.png',true);
%     bigFish.initState('swimLeft3','../img/fixed/L_fish_a.png',true);
%     bigFish.initState('swimLeft4','../img/fixed/L_fish_c.png',true);
%     bigFish.initState('swimRight1','../img/fixed/FISHY_colour.png',true);
    initState(bigFish,'fishOne','../img/FISHY_colour.png',true);
    %     bigFish.initState('swimRight2','../img/fixed/R_fish_b.png',true);
%     bigFish.initState('swimRight3','../img/fixed/R_fish_a.png',true);
%     bigFish.initState('swimRight4','../img/fixed/R_fish_c.png',true);
    bigFish.Scale = 1;
    bigFish.State = 'fishOne';


    % 3 CHOICES FISHES
    friends = updateFriend(G.Size(1), friend);
    


    
    %% Setup KeyPressFcn and others
%     G.onKeyPress = @keypressfcn;
%     G.onMouseRelease = @buttonupfcn;
        
    %% ------   start the GAME
%     iter = 0;
%     G.play(@()action(argin));
%     G.play(@action);
%     pause(1);

    
end % end of the setUpGame function 