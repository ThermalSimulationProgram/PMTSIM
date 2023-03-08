function [obj, kdata] = resetPipeline(obj)


obj = Pipeline(obj.TM, obj.nstage, obj.tswons, obj.tswoffs, obj.deltaT, ...
    obj.coreArray(1).displayInterval, obj.activeCoreIdx);
switch obj.kernel
    case obj.GE
        kernel = 'GE';
    case obj.PTM
        kernel = 'PTM';
    case obj.BWS
        kernel = 'BWS';
    case obj.APTM
        kernel = 'APTM';
end

kdata.kernel = kernel;
kdata.adaptPeriod = obj.adaptPeriod;
kdata.offlineData = obj.offlineData;
kdata.bcoef = obj.bceof;
kdata.tons  = obj.tons;
kdata.toffs = obj.toffs;


end
