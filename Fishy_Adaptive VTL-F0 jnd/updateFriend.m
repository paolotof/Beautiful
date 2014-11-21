function friends = updateFriend(gameWidth, scrsz4, friend)
    
    friends = {};

    for i=1:3
        el = SpriteKit.Sprite(sprintf('friend%d', i));
        
        el.initState('state1', ['../img/fixed/' friend '_talk_a.png'], true);
        el.initState('state2', ['../img/fixed/' friend '_talk_b.png'], true);
        el.initState('state3', ['../img/fixed/' friend '_talk_a.png'], true);
        el.initState('state4', ['../img/fixed/' friend '_talk_c.png'], true);
        clickArea = size(imread(['../img/fixed/' friend '_talk_a.png']));
        addprop(el, 'width');
        el.width = clickArea(1)/2;
        heigth = clickArea(2)/2;
        el.Location = [round(gameWidth * (i+1)/5 - el.width)  heigth + (scrsz4 - 750)];
        addprop(el, 'clickL');
        addprop(el, 'clickR');
        addprop(el, 'clickD');
        addprop(el, 'clickU');
        el.clickL = round(el.Location(1) - el.width);
        el.clickR = round(el.Location(1) + el.width);
        el.clickD = round(el.Location(2) - heigth);
        el.clickU = round(el.Location(2) + heigth);
        el.State = 'state1';
        cycleNext(el)
        
        addprop(el, 'd0');
        addprop(el, 'trajectory');
        addprop(el, 'iter');
        
        addprop(el, 'key');
        el.key = i;
        
        friends{end+1} = el;
        
    end
    % we need to find a way to insert this in the loop as well... 
    friends{1}.d0 = [-70 70];
    friends{2}.d0 = [5 70];
    friends{3}.d0 = [70 70];
    
end