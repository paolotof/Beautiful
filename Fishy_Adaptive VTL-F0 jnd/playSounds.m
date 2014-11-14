function playSounds(varargin)

    iter = 1;
    play(varargin{1})
    while true
        if nargin == 2
%             varargin{2}.Angle = varargin{2}.Angle + randi([0, 360],1);
%             varargin{2}.State = ['state' sprintf('%i', mod(iter,4)+1)];

              varargin{2}.State = ['state' sprintf('%i', mod(floor(iter/10), 4))+1];

%             cycleNext(varargin{2}); % this goes to fast.

            iter = iter + 1;
        end
        if ~isplaying(varargin{1})
            break;
        end
        pause(0.01);
        
    end
    
    if nargin == 2
%         varargin{2}.Angle = 0;
        varargin{2}.State = 'state1';
    end
    
end
