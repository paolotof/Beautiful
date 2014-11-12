function [elOne, elTwo, elThree] = updateFriend(elOne, elTwo, elThree, friend)

    elOne.initState('state1', ['../img/' friend ' a.png'], true);
    elOne.initState('state2', ['../img/' friend ' b.png'], true);
    elOne.initState('state3', ['../img/' friend ' a.png'], true);
    elOne.initState('state4', ['../img/' friend ' c.png'], true);

    elTwo.initState('state1', ['../img/' friend ' a.png'], true);
    elTwo.initState('state2', ['../img/' friend ' b.png'], true);
    elTwo.initState('state3', ['../img/' friend ' a.png'], true);
    elTwo.initState('state4', ['../img/' friend ' c.png'], true);

    elThree.clickL = round(elThree.Location(1) - width);
    elThree.clickR = round(elThree.Location(1) + width);
    elThree.clickD = round(elThree.Location(2) - heigth);
    elThree.clickU = round(elThree.Location(2) + heigth);


end