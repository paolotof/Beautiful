function playSounds(varargin)

    play(varargin{1})
    while true
        if nargin == 2
            varargin{2}.Angle = varargin{2}.Angle + 15;
        end
        if ~isplaying(varargin{1})
            break;
        end
        pause(0.01);
    end
    
    if nargin == 2
        varargin{2}.Angle = 0;
    end
    
end
