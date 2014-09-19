function pa_setup()

disp(sprintf('Which device should be used?\n'))

d = pa('getDevices');
s = -1;
for i=1:length(d)
    disp(sprintf('[%d] %s (%s)', d(i).deviceID, d(i).name, d(i).hostAPI));
    if strcmp(d(i).hostAPI, 'ASIO')
        s = d(i).deviceID;
    end
end

if s==-1
    s = input(sprintf('\nRecommended [none]:   '), 's');
else
    s = input(sprintf('\nRecommended [%d]:   ', s), 's');
end

install_path = fileparts(mfilename('fullpath'));

fid = fopen(fullfile(install_path, 'pa_device.m'), 'w');
fprintf(fid, 'function d = pa_device()\nd = %s;\n', s);
fclose(fid);
