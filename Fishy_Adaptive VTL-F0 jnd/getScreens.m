function [screen1, screen2] = get_screens(machine)
% Return SCREEN1 and SCREEN2 as [LEFT, BOTTOM, WIDTH, HEIGHT]
% SCREEN1 is supposed to be the experimenter's screen and SCREEN2 the
% participants' screen.



if nargin<1
    
    % We detect the machine automatically
    [c, s] = system('hostname');
    s = strtrim(s);
    
    switch s
        case 'hoogglans'
            machine = 'coding';
            
        case 'lt159107.med.rug.nl'
            machine = 'silent';
        
        otherwise
            machine = 'silent';
end

switch lower(machine)

    case {'silent', 'chilly'}
        % Multiple screen setup for Silent Room
        screen1 = get(0, 'Screensize');
        %screen2 = [-1024, 0, 1024, 768];
        screen2 = [1920, 1, 1280, 1024];
        
    otherwise
        % Mono screen setup
        screen1 = get(0,'ScreenSize');
        screen2 = screen1;
end

