function r = simplifyResult(ret)
if isempty(ret)
    r = [];
    return;
end
r.config = getUsefulConfig(ret.config);
r.aptm   = simplifyPipeline(ret.aptm);
r.bws    = simplifyPipeline(ret.bws);
r.pboo    = simplifyPipeline(ret.pboo);

end


function sp = simplifyPipeline(result)
if isempty(result)
    sp = [];
    return;
end
pin    = result.pipeline;
sp.peakT = result.peakT;

p.activeCoreIdx     = pin.activeCoreIdx;
p.adaptPeriod       = pin.adaptPeriod;
p.deltaT            = pin.deltaT;
p.tswons            = pin.tswons;
p.tswoffs           = pin.tswoffs;
p.TemTrace          = pin.TemTrace(1:pin.nTtrace, :);
%p.nTtrace           = pin.nTtrace;
p.TimeTrace         = pin.TimeTrace(1:pin.nTtrace, :);

p.elapsetime        = pin.elapsetime(1:pin.adaptcounter);
p.adaptcounter      = pin.adaptcounter;
p.kernel            = pin.kernel;
p.bcoef             = pin.bcoef;
p.caseA_num         = pin.caseA_num;
p.caseB_num         = pin.caseB_num;
%p.accuTrace         = pin.accuTrace;

sp.pipeline         = p;
end
