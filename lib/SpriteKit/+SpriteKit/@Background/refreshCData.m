function refreshCData(obj)
%REFRESHCDATA Take current Scale, WindowSize, and RefPt to update CData
%from Torus.

% Copyright 2014 The MathWorks, Inc.

rp = obj.RefPt;
ws = obj.WindowSize;
sc = obj.Scale;

c = obj.TileCData(...
    round( rp(2)+(1:ws(2)/sc) ),...
    round( rp(1)+(1:ws(1)/sc) ),...
    :);

set(obj.GfxHandle,'CData',c)