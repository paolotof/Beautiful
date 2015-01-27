function [screen1, screen2] = getScreens()
% Return SCREEN1 and SCREEN2 as [LEFT, BOTTOM, WIDTH, HEIGHT]
% SCREEN1 is supposed to be the experimenter's screen and SCREEN2 the
% participants' screen.



s = get(0, 'MonitorPositions');

screen1 = s(1,:);

if size(s,1)==1
    screen2 = screen1;
else
    screen2 = s(2,:);
end

