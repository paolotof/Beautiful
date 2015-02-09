%cd results

files = dir('jvo_*.mat');

nfiles = length(files);
conditions = [1,3];
for ifile = 1:nfiles
   load(files(ifile).name)
   files(ifile).name
   subplot(nfiles, 1, ifile)
   interval = [15:length(results.test.conditions(conditions(ifile)).att.differences)];
   plot(results.test.conditions(conditions(ifile)).att.differences(interval))
   line(1:length(results.test.conditions(conditions(ifile)).att.differences),...
       repmat(results.test.conditions(conditions(ifile)).att.threshold, 1, ...
       length(results.test.conditions(conditions(ifile)).att.differences)),...
       'Color', 'r')
   
end

