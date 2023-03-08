
load('ARM3coresTM.mat');
TM = completeTM(TM);

wcets = [10, 10, 10];
K = 0.3;
minTslp = wcets / K - wcets;
minTheta = sum(minTslp);
sumBound = 20;
%% method 0

tslp0 = ones(1, numel(wcets)) * sumBound / numel(wcets);

[Tpeak0, ~, ~] = CalculatePeakTemperatureV2(0, TM, tslp0, wcets, []);
%% method 1
tslp1 = sumBound * minTslp / minTheta;
%tslp1 = ones(1, 3) * sumBound / 3;
[Tpeak1, ~, ~] = CalculatePeakTemperatureV2(0, TM, tslp1, wcets, []);

%% method 2
% offline learning
data = offlineLearningMiniTact(TM, wcets, sumBound * 4);

[func, tables] = getLinearFuncHandles(data);
[breakToffs, slopes, numValidData] = trans2matForMTtable(tables);

tau0 = ones(1, 3);

[tslp2] = assigToffs(sumBound - sum(tau0), 1:3, tau0, breakToffs, slopes, numValidData);
[Tpeak2, ~, ~] = CalculatePeakTemperatureV2(0, TM, tslp2, wcets, []);

%% cooling curve
tinv = data{1}(2, :);
T1 = data{1}(1, :);
T2 = data{2}(1, :);
T3 = data{3}(1, :);

%save('cooling-curve', 'wcets', 'K', 'sumBound', 'data', 'tinv', 'T1',...
%    'T2', 'T3');


