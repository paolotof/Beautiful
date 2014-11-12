function [G, bkg, bigFish, elOne, elTwo, elThree] = setUpGame(friend)


    %% introduce the animation bit
    % Start a new Game
    G = SpriteKit.Game.instance('Title','Fishy Game','Size',[800 600]);
    bkg = SpriteKit.Background('../img/BACKGROUND.png');
%     bkg.Scale = 1;

    addBorders(G);
    % Setup the SpriteS
    bigFish = SpriteKit.Sprite('fishOne');
%     bigFish.initState('swimLeft1','../img/L_fish_a.png',true);
%     bigFish.initState('swimLeft2','../img/L_fish_b.png',true);
%     bigFish.initState('swimLeft3','../img/L_fish_a.png',true);
%     bigFish.initState('swimLeft4','../img/L_fish_c.png',true);
    bigFish.initState('swimRight1','../img/R_fish_a.png',true);
%     bigFish.initState('swimRight2','../img/R_fish_b.png',true);
%     bigFish.initState('swimRight3','../img/R_fish_a.png',true);
%     bigFish.initState('swimRight4','../img/R_fish_c.png',true);
    bigFish.Scale = 1;
    bigFish.State = 'swimRight1';
    % Add pertinent properties to the Sprite handle
    addprop(bigFish,'accel');
    bigFish.accel = [0 0];
%     addprop(s,'i_correct');
%     addprop(s,'begTime');
%     
%     for k=1:24
%         spritename = sprintf('membrane%d',k);
%         pngFile = ['/home/paolot/Downloads/SpriteKit/demo/img/' spritename '.png'];
%         s.initState(spritename,pngFile,true);
%     end

    % 3 CHOICES FISHES
    elOne = SpriteKit.Sprite('elOne');
    elOne.initState('state1', ['../img/' friend ' a.png'], true);
    elOne.initState('state2', ['../img/' friend ' b.png'], true);
    elOne.initState('state3', ['../img/' friend ' a.png'], true);
    elOne.initState('state4', ['../img/' friend ' c.png'], true);
    
    clickArea = size(imread(['../img/' friend ' a.png']));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(elOne,'clickL');
    addprop(elOne,'clickR');
    addprop(elOne,'clickU');
    addprop(elOne,'clickD');
    elOne.Location = [100 100];
    elOne.clickL = round(elOne.Location(1) - width);
    elOne.clickR = round(elOne.Location(1) + width);
    elOne.clickD = round(elOne.Location(2) - heigth);
    elOne.clickU = round(elOne.Location(2) + heigth);
    elOne.State = 'state1';
    addprop(elOne, 'key');
    elOne.key = 1;
    %
    elTwo = SpriteKit.Sprite('elTwo');
    elTwo.initState('state1', ['../img/' friend ' a.png'], true);
    elTwo.initState('state2', ['../img/' friend ' b.png'], true);
    elTwo.initState('state3', ['../img/' friend ' a.png'], true);
    elTwo.initState('state4', ['../img/' friend ' c.png'], true);

    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(elTwo,'clickL');
    addprop(elTwo,'clickR');
    addprop(elTwo,'clickU');
    addprop(elTwo,'clickD');
    elTwo.Location = [300 100];
    elTwo.clickL = round(elTwo.Location(1) - width);
    elTwo.clickR = round(elTwo.Location(1) + width);
    elTwo.clickD = round(elTwo.Location(2) - heigth);
    elTwo.clickU = round(elTwo.Location(2) + heigth);
    elTwo.State = 'state1';
    addprop(elTwo, 'key');
    elTwo.key = 2;
    %
    elThree = SpriteKit.Sprite('elThree');
    elThree.initState('state1', ['../img/' friend ' a.png'], true);
    elThree.initState('state2', ['../img/' friend ' b.png'], true);
    elThree.initState('state3', ['../img/' friend ' a.png'], true);
    elThree.initState('state4', ['../img/' friend ' c.png'], true);

    clickArea = size(imread('../img/half_FishyRed.png'));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(elThree,'clickL');
    addprop(elThree,'clickR'); 
    addprop(elThree,'clickU'); 
    addprop(elThree,'clickD');
    elThree.Location = [500 100];
    elThree.clickL = round(elThree.Location(1) - width);
    elThree.clickR = round(elThree.Location(1) + width);
    elThree.clickD = round(elThree.Location(2) - heigth);
    elThree.clickU = round(elThree.Location(2) + heigth);
    elThree.State = 'state1';
    addprop(elThree, 'key');
    elThree.key = 3;
    


    
    %% Setup KeyPressFcn and others
%     G.onKeyPress = @keypressfcn;
%     G.onMouseRelease = @buttonupfcn;
        
    %% ------   start the GAME
%     iter = 0;
%     G.play(@()action(argin));
%     G.play(@action);
%     pause(1);

    
end % end of the setUpGame function 