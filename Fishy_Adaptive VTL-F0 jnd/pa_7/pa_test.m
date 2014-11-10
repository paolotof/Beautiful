function pa_test()
% Test for pa (playrec/portaudio)
% The first two sounds shouldn't click. The third one may.

% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> 2010-04-29

fs = pa_init();

t = (0:fs)'/fs;
x = sin(2*pi*1000*t);
x = cosgate(x, fs, 30e-3)*.5;

pa('block', pa('play', [x, x], [1, 2]));

pause(.7)

player = audioplayer(x, fs);
playblocking(player);

pa('reset')

pause(.7)

playblocking(player);

%------------------------------------------
function Out=cosgate(In,Fe,Tr)

De=Tr*Fe; 
gate=ones(size(In));
k=0:De-1;
gate(k+1)  = 1 - ( 1+cos(k*pi/(De-1)) ) / 2;
gate(end-k) = 1 - ( 1+cos(k*pi/(De-1)) ) / 2;
Out=In.*gate;