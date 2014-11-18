function [G, bkg, bigFish, elOne, elTwo, elThree] = setUpGame(friend)


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
    % Add pertinent properties to the Sprite handle
    addprop(bigFish,'accel');
    bigFish.accel = [0 0];
    [tmp, tmp2, alpha] = imread('../img/FISHY_colour.png');
%     set(bigFish.AlphaData, alpha);
    addprop(bigFish,'AlphaData')
    bigFish.AlphaData = alpha;
%     addprop(s,'i_correct');
%     addprop(s,'begTime');
%     
%     for k=1:24
%         spritename = sprintf('membrane%d',k);
%         pngFile = ['/home/paolot/Downloads/SpriteKit/demo/img/fixed/' spritename '.png'];
%         s.initState(spritename,pngFile,true);
%     end

    % 3 CHOICES FISHES
    elOne = SpriteKit.Sprite('elOne');
    elOne.initState('state1', ['../img/fixed/' friend '_talk_a.png'], true);
    elOne.initState('state2', ['../img/fixed/' friend '_talk_b.png'], true);
    elOne.initState('state3', ['../img/fixed/' friend '_talk_a.png'], true);
    elOne.initState('state4', ['../img/fixed/' friend '_talk_c.png'], true);
    
    clickArea = size(imread(['../img/fixed/' friend '_talk_a.png']));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    addprop(elOne,'clickL');
    addprop(elOne,'clickR');
    addprop(elOne,'clickU');
    addprop(elOne,'clickD');
    elOne.Location = [round(G.Size(1) * 2/5 - width) heigth + 50];
    elOne.clickL = round(elOne.Location(1) - width);
    elOne.clickR = round(elOne.Location(1) + width);
    elOne.clickD = round(elOne.Location(2) - heigth);
    elOne.clickU = round(elOne.Location(2) + heigth);
    elOne.State = 'state1';
    addprop(elOne, 'key');
    
    elOne.key = 1;
    %
    elTwo = SpriteKit.Sprite('elTwo');
    elTwo.initState('state1', ['../img/fixed/' friend '_talk_a.png'], true);
    elTwo.initState('state2', ['../img/fixed/' friend '_talk_b.png'], true);
    elTwo.initState('state3', ['../img/fixed/' friend '_talk_a.png'], true);
    elTwo.initState('state4', ['../img/fixed/' friend '_talk_c.png'], true);

    addprop(elTwo,'clickL');
    addprop(elTwo,'clickR');
    addprop(elTwo,'clickU');
    addprop(elTwo,'clickD');
    elTwo.Location = [round(G.Size(1) * 3/5 - width)  heigth + 50];
    elTwo.clickL = round(elTwo.Location(1) - width);
    elTwo.clickR = round(elTwo.Location(1) + width);
    elTwo.clickD = round(elTwo.Location(2) - heigth);
    elTwo.clickU = round(elTwo.Location(2) + heigth);
    elTwo.State = 'state1';
    addprop(elTwo, 'key');
    elTwo.key = 2;
    %
    elThree = SpriteKit.Sprite('elThree');
    elThree.initState('state1', ['../img/fixed/' friend '_talk_a.png'], true);
    elThree.initState('state2', ['../img/fixed/' friend '_talk_b.png'], true);
    elThree.initState('state3', ['../img/fixed/' friend '_talk_a.png'], true);
    elThree.initState('state4', ['../img/fixed/' friend '_talk_c.png'], true);

    addprop(elThree,'clickL');
    addprop(elThree,'clickR'); 
    addprop(elThree,'clickU'); 
    addprop(elThree,'clickD');
    elThree.Location = [round(G.Size(1) * 4/5 - width)  heigth + 50];
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