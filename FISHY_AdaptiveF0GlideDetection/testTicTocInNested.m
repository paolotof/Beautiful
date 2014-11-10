function testTicTocInNested
%     startTime = tic;
    tic;
%     disp('hello');
%     dosomething(startTime);
%     function dosomething(startTime)
%         fprintf('%f\n', startTime - toc());
% %         toc() - startTime
% %         endtime = toc();
%     end
    dosomething;
    
    function dosomething
        fprintf('%f\n', toc());
    end
%     toc
% toc
end