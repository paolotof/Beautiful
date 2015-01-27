clear 

[X,map,alpha] = imread('BACKGROUND.png');
% 1600 	× 	1200
[heigthPic, widthPic, ~] = size(X);

% Resampled signal, returned as a vector or matrix. If x is a signal of 
% length N and you specify p,q, then y is of length ⌈N × p/q⌉.
screenHeigth = 1024;
% y = resample(X(:, :, 1), repmat(heigthPic, 1, heigthPic), ...
%     repmat(screenHeigth, 1, heigthPic));
% 
% 1280 960
% y = resample(squeeze(X(:, :, 1)), 1, heigthPic/screenHeigth);


Y = resample(double(squeeze(X(:, :, 1))), screenHeigth, heigthPic);

heigthPic/screenHeigth % Expected Q to be integer-valued.
