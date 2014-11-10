function setPA4(id, att, level)

%setPA4(id, att, level)
%   This is a dummy file for machines that are not connected to TDT
%   attenuators. The attenuation is achieved through the sound card.
%
%   id doesn't matter here
%   att is in dB
%   level is percent

if nargin<3
    level = 1;
else
    level = level/100;
end

level = 10^(-att/20)*level;

warning('setPA4:digital', 'Digital attenuation is used. Only the last attenuation will be retained (%d dB).', att);

SoundVolume('max');
SoundVolume('volume', level);
