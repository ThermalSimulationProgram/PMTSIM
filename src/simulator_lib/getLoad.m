function load = getLoad(obj)
% obj : the core
% get how much load in core obj, in terms of time length
if isempty(obj.myevent)
    load = 0;
    return;
end
load = obj.myevent.remainedLoad(obj.id);
end