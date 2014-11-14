function [elOne, elTwo, elThree] = updateFriend(gameWidth, elOne, elTwo, elThree, friend)

    elOne.initState('state1', ['../img/fixed/' friend '_a.png'], true);
    elOne.initState('state2', ['../img/fixed/' friend '_b.png'], true);
    elOne.initState('state3', ['../img/fixed/' friend '_a.png'], true);
    elOne.initState('state4', ['../img/fixed/' friend '_c.png'], true);
    clickArea = size(imread(['../img/fixed/' friend '_a.png']));
    width = clickArea(1)/2;
    heigth = clickArea(2)/2;
    elOne.Location = [round(gameWidth * 2/5 - width) 100];
    elOne.clickL = round(elOne.Location(1) - width);
    elOne.clickR = round(elOne.Location(1) + width);
    elOne.clickD = round(elOne.Location(2) - heigth);
    elOne.clickU = round(elOne.Location(2) + heigth);
    elOne.State = 'state1';
    cycleNext(elOne)

    elTwo.initState('state1', ['../img/fixed/' friend '_a.png'], true);
    elTwo.initState('state2', ['../img/fixed/' friend '_b.png'], true);
    elTwo.initState('state3', ['../img/fixed/' friend '_a.png'], true);
    elTwo.initState('state4', ['../img/fixed/' friend '_c.png'], true);
    % No need to update image size here since images have all same size
    elTwo.Location = [round(gameWidth * 3/5 - width) 100];
    elTwo.clickL = round(elTwo.Location(1) - width);
    elTwo.clickR = round(elTwo.Location(1) + width);
    elTwo.clickD = round(elTwo.Location(2) - heigth);
    elTwo.clickU = round(elTwo.Location(2) + heigth);
    elTwo.State = 'state1';
    cycleNext(elTwo)

    elThree.initState('state1', ['../img/fixed/' friend '_a.png'], true);
    elThree.initState('state2', ['../img/fixed/' friend '_b.png'], true);
    elThree.initState('state3', ['../img/fixed/' friend '_a.png'], true);
    elThree.initState('state4', ['../img/fixed/' friend '_c.png'], true);
    elThree.Location = [round(gameWidth * 4/5 - width) 100];
    elThree.clickL = round(elThree.Location(1) - width);
    elThree.clickR = round(elThree.Location(1) + width);
    elThree.clickD = round(elThree.Location(2) - heigth);
    elThree.clickU = round(elThree.Location(2) + heigth);
    elThree.State = 'state1';
    cycleNext(elThree)

end