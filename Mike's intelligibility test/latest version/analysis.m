% f0 vtl snr
clear all
close all
for mv=1:2
    
    switch mv
        case 1
            load subject1/Test1.mat
            manvrouw = 'man';
        case 2
            load subject1/Test2.mat
            manvrouw = 'vrouw';
    end
    
    colors = {'b','r','g', 'y', 'c', 'g','g'};
    f0_r = [0 4 8];
    s = size(p.ConditionsCorrect);

    s(3)=1;
    
    for snr=1:s(3)
        for vtl=1:s(2)
            for f0=1:s(1)
                f0_array(f0) = p.ConditionsCorrect(f0, vtl)/p.ConditionsCounts(f0, vtl);
            end
            vtl_array{vtl} = f0_array;
        end
        snr_array{snr} = vtl_array;
    end


    for i=1:length(snr_array)
        vtl_array = snr_array{i};
        figure
        axis([-0.01 8.01 0 1])
        hold on
        ylabel('% correct')
        xlabel('f0 shift in semitones')


        switch manvrouw
            case 'man'
                switch i
                    case 1
                        title('Male & snr: -6')
                    case 2
                        title('Male & snr: 0')
                end
            case 'vrouw'
                switch i
                    case 1
                        title('Female & snr: -6')
                    case 2
                        title('Female & snr: 0')
                end
        end


        for i2=1:length(vtl_array)
            plot(f0_r, vtl_array{i2}, sprintf('%s', colors{i2}))
        end
        legend({'vtl: 0','vtl: 0.75','vtl: 1.5','vtl: 3'})
    end

end



% f0 vtl snr
for mv=1:2
    
    switch mv
        case 1
            load subject1/Test3.mat
            manvrouw = 'man';
        case 2
            load subject1/Test4.mat
            manvrouw = 'vrouw';
    end
    
    colors = {'b','r','g', 'y', 'c', 'g','g'};
    f0_r = [0 4 8];
    s = size(p.ConditionsCorrect);

    s(3)=1;
    
    for snr=1:s(3)
        for vtl=1:s(2)
            for f0=1:s(1)
                f0_array(f0) = p.ConditionsCorrect(f0, vtl)/p.ConditionsCounts(f0, vtl);
            end
            vtl_array{vtl} = f0_array;
        end
        snr_array{snr} = vtl_array;
    end


    for i=1:length(snr_array)
        vtl_array = snr_array{i};
        figure
        axis([-0.01 8.01 0 1])
        hold on
        ylabel('% correct')
        xlabel('f0 shift in semitones')


        switch manvrouw
            case 'man'
                switch i
                    case 1
                        title('Male & snr: -6')
                    case 2
                        title('Male & snr: 0')
                end
            case 'vrouw'
                switch i
                    case 1
                        title('Female & snr: -6')
                    case 2
                        title('Female & snr: 0')
                end
        end


        for i2=1:length(vtl_array)
            plot(f0_r, vtl_array{i2}, sprintf('%s', colors{i2}))
        end
        legend({'vtl: 0','vtl: 0.75','vtl: 1.5','vtl: 3'})
    end

end