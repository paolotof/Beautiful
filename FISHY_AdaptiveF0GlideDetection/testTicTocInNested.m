function testTicTocInNested
    startTime = tic;
    tic;
%     disp('hello');
%     dosomething(startTime);
%     function dosomething(startTime)
%         fprintf('%f\n', startTime - toc());
% %         toc() - startTime
% %         endtime = toc();
%     end
    dosomething;
%     dosomethingElse(startTime);
    function dosomething
        dosomethingElse(startTime);
        fprintf('%f\n', toc());
    end

    function dosomethingElse(startTime)
        fprintf('%f\n', toc(startTime));
    end
%     toc
% toc
end