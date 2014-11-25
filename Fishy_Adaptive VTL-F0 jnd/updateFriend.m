function friends = updateFriend(gameWidth, scrsz4, friend)
    

    friends = {};

    for i=1:3
        el = SpriteKit.Sprite(sprintf('friend%d', i));
        
        el.initState('talk1', ['../img/fixed/' friend '_talk_a.png'], true);
        el.initState('talk2', ['../img/fixed/' friend '_talk_b.png'], true);
        el.initState('talk3', ['../img/fixed/' friend '_talk_a.png'], true);
        el.initState('talk4', ['../img/fixed/' friend '_talk_c.png'], true);
        el.initState('swim1', ['../img/fixed/' friend '_swim_a.png'], true);
        el.initState('swim2', ['../img/fixed/' friend '_swim_b.png'], true);
        el.initState('swim3', ['../img/fixed/' friend '_swim_a.png'], true);
        el.initState('swim4', ['../img/fixed/' friend '_swim_c.png'], true);
        % define clicking areas
        clickArea = size(imread(['../img/fixed/' friend '_talk_a.png']));
        addprop(el, 'width');
        el.width = round(clickArea(1)/2);
        addprop(el, 'heigth');
        el.heigth = round(clickArea(2)/2);
        el.Location = [round(gameWidth * (i+1)/5 - el.width)  el.heigth + (scrsz4 - 750)];
        addprop(el, 'clickL');
        addprop(el, 'clickR');
        addprop(el, 'clickD');
        addprop(el, 'clickU');
        el.clickL = round(el.Location(1) - el.width);
        el.clickR = round(el.Location(1) + el.width);
        el.clickD = round(el.Location(2) - el.heigth);
        el.clickU = round(el.Location(2) + el.heigth);
        % set up locations for bubbles
        addprop(el, 'bubblesX');
        el.bubblesX = round(el.Location(1) - el.width);
        addprop(el, 'bubblesY');
        el.bubblesY = round(el.Location(2) + el.heigth);

        
        el.State = 'talk1';
        cycleNext(el) % update object state (I think this is necessary to get animation started)
        
        addprop(el, 'd0');
        addprop(el, 'trajectory');
        addprop(el, 'iter');
        el.iter = 1;
        addprop(el, 'key');
        el.key = i;
        
        friends{end+1} = el;
        
    end
    % we need to find a way to insert this in the loop as well... 
    friends{1}.d0 = [-70 70];
    friends{2}.d0 = [5 70];
    friends{3}.d0 = [70 70];
    
end