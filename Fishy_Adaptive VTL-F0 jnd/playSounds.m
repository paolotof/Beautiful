function playSounds(varargin)
%               cycleNext(varargin{2}); % this goes too fast.

    iter = 1;
    if nargin == 2
        [nBubbles, posBubbles] = makeBubbles(varargin{2});
    end
    previousCounter = 0;
    play(varargin{1})
    bubble = {};
    while true
        if nargin == 2
            statusCounter = mod(floor(iter/10), 4)+1;
            varargin{2}.State = ['state' sprintf('%i', statusCounter)];
            if previousCounter ~= statusCounter
                for iBubbles = 1 : nBubbles(statusCounter)
                    bubble{end + 1} = rectangle('Curvature', [1 1], 'Position', [posBubbles(statusCounter).b{iBubbles}], 'FaceColor', [0 115 255]./255, ...
                        'EdgeColor', [198 241 255]./255, 'LineWidth', 2);
                end
            end
                
            previousCounter = statusCounter;
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
        % clear bubbles
        for iBubbles = 1 : length(bubble)
            set(bubble{iBubbles}, 'Visible', 'off')
        end

    end
    
end
