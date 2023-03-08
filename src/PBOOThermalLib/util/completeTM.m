function [TM] = completeTM(TM, config)

p = TM.p;
t = 0 : p : p*( TM.sizet - 1);
n = TM.n;

TM.isComplete = false(n,n);

if nargin > 1
    acn = config.activeNum;
    actId = config.isAct;
    activeIdx = config.actcoreIdx;
else
    acn = n;
    actId = true(1, n);
    activeIdx = 1 : n;
end
if exist('TM.fftH','var')
    delete(TM.fftH);
end
TM.fftH = fftH(TM.fftLength, acn, n);
fftHinit(TM.fftH, activeIdx);

for i = 1 : n
    if ~actId(i)
        continue;
    end
    for j = 1 : n
        if ~actId(j)
            continue;
        end
        NH = max( TM.fitResults{i,j}.fitresult(t), 0);
        flag2 = fftHwrite(TM.fftH, i, j, fft(NH, TM.fftLength));
        if ~flag2
            error('invalid target or heatsource!');
        end
        TM.isComplete(i,j) = true;
    end
end

