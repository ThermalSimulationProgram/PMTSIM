function offlineData = getOfflineData(slopedata, coolingdata)

[~, mtdata] = getLinearFuncHandles(coolingdata);


slopedata = getFuncHandles(slopedata);

offlineData.mtdata = mtdata;
offlineData.slopedata = slopedata;