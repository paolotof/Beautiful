function fs = pa_init(fs)

% fs = pa_init(fs)
%   Initialise PA. The fs argument is optionnal. If missing, the default is 44100 Hz.

if nargin<1 || isempty(fs)
    fs = 44100;
end

if pa_device()==-1
    warning('PA: No output device selected.')
end

if ~pa('isInitialised')
    pa('init', fs, pa_device(), -1);
end