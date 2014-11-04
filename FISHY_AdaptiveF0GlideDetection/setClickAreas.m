function loc = setClickAreas(tFish, yFish, rFish, terminate, proceed, clickAreaFlow, clickAreaFishes)
    width = clickAreaFishes(1)/2;
    heigth = clickAreaFishes(2)/2;

    loc.yL = yFish.Location(1) - width;
    loc.yR = yFish.Location(1) + width;
    loc.yD = yFish.Location(2) - heigth;
    loc.yU = yFish.Location(2) + heigth;

    loc.tL = tFish.Location(1) - width;
    loc.tR = tFish.Location(1) + width;
    loc.tD = tFish.Location(2) - heigth;
    loc.tU = tFish.Location(2) + heigth;

    loc.rL = rFish.Location(1) - width;
    loc.rR = rFish.Location(1) + width;
    loc.rD = rFish.Location(2) - heigth;
    loc.rU = rFish.Location(2) + heigth;

    width = clickAreaFlow(1)/2;
    heigth = clickAreaFlow(2)/2;

    loc.pL = proceed.Location(1) - width;
    loc.pR = proceed.Location(1) + width;
    loc.pD = proceed.Location(2) - heigth;
    loc.pU = proceed.Location(2) + heigth;

    loc.sL = terminate.Location(1) - width;
    loc.sR = terminate.Location(1) + width;
    loc.sD = terminate.Location(2) - heigth;
    loc.sU = terminate.Location(2) + heigth;
end