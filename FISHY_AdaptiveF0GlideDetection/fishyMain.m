function fishyMain(options, phase)

%--------------------------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@umcg.nl> - 2013-02-24
% RuG / UMCG KNO, Groningen, NL
%--------------------------------------------------------------------------

    results = struct();
    load(options.res_filename); % options, expe, results


    DisplayInstructions(options, phase);
    setUpGame(options, phase, expe, results);
%     playGame(options, phase, expe, results);
    

end % end main function
