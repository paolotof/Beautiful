load('results/streaming2013_test7.mat')

r = results.test.responses;

x = [];
y = [];
for i=1:length(r)
    d = sqrt(0*diff(log2(r(i).trial.f0))^2 + diff(log2(r(i).trial.ser))^2);
    x = [x, d];
    y = [y, r(i).correct];
end
plot(x, y+rand(size(y))*.05, 'ob')
hold on
p = polyfit(x, y, 1);
plot([0, 1], polyval(p, [0,1]), '-r')
hold off