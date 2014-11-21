function testAnimations

addpath('../lib/SpriteKit');
close(gcf)

G = SpriteKit.Game.instance('Title','Flying Membrane Demo', 'ShowFPS', false);

%% Setup the Sprite
s = SpriteKit.Sprite('fishone');
for k=1:10
    spritename = sprintf('FISHY_TURN_%d',k);
    pngFile = ['../img/fixed/' spritename '.png'];
    s.initState(spritename, pngFile, true);
end

iter = 1;

%% Run it!
G.play(@action);

%% Function to be called on each tic/toc of gameplay
    function action
        
        % increase the scaling
        %     s.Scale = s.Scale+0.01;
        
        s.cycleNext
        % cycle next layer
%         if (mod(floor(iter/10), 4) == 0)
%             s.cycleNext;
%         end
%         s.State
        s.State = sprintf('FISHY_TURN_%d',mod(floor(iter/2), 10) + 1);
        % update position and angle
        %     s.Location = P(iter,:);  % use dot assignment...
        %     set(s,'Angle',iter)      % or "set"
        %
        if iter==20 % stop processing
            G.stop();
            
        end
        
        iter = iter+1;
        
    end


rmpath('../lib/SpriteKit');

end