function safe = safePosition(pos)
%SAFEPOSITION Figure position that minimizes clipping on screen.
%
% Given a 4-element position vector P, SAFEPOSITION measures the screensize
% and the new figure size to shift the figure left or down to fit on
% screen. This is needed for modal figures, whose titlebar (and the close
% button) may drift out of reach.
%
% Example:
%   SAFEPOSITION([5000 500 400 600]) returns [1515 500 400 600].
%
% Safe values will differ when run on different monitor configurations.

% Copyright 2014 The MathWorks, Inc.

if length(pos) ~= 4 || ~isnumeric(pos)
    error('Input must be a 4 element numeric vector.')
end

safe = pos; % retain width and height
ss = get(0,'ScreenSize');

pad = [5 55]; % right border, top border + menubar

safe(1) = min(pos(1),ss(3)-pos(3)-pad(1));
safe(2) = min(pos(2),ss(4)-pos(4)-pad(2));
