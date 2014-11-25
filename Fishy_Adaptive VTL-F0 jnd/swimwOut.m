function [spriteObject] = swimwOut(spriteObject, speedSwim)
% Use linspace to create a line the friends will follow to swim out of the
% Game

% -(sizeFriend + 5): this is to make sure that they really swim out of the
% fishtank

%     trajectory = [linspace(locx, -50, speedSwim); repmat(locy, 1, speedSwim)];
    trajectory = linspace(spriteObject.Location(1), -(spriteObject.width + 5), speedSwim);
    trajectory = [trajectory; repmat(spriteObject.Location(2), 1, length(trajectory))]';
%     trajectory = [repmat(locy, 1, length(trajectory)); trajectory];
    spriteObject.trajectory = trajectory;
    spriteObject.iter = 1;
    
end