function trajectory = swimwOut(locx, locy, sizeFriend, speedSwim)
% Use linspace to create a line the friends will follow to swim out of the
% Game

% -(sizeFriend + 5): this is to make sure that they really swim out of the
% fishtank

%     trajectory = [linspace(locx, -50, speedSwim); repmat(locy, 1, speedSwim)];
    trajectory = linspace(locx, -(sizeFriend + 5), speedSwim);
    trajectory = [trajectory; repmat(locy, 1, length(trajectory))]';
%     trajectory = [repmat(locy, 1, length(trajectory)); trajectory];

end