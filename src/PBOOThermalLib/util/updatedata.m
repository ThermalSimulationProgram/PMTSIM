function data = updatedata(data, varargin)

% default arguments
   
pp              = inputParser;
defaultRho      = 0.25;
defaultb        = 50;
defaultK        = 0.5;
defaultTimp     = ImpulsePeriod2dMat(1,1);
defaultCandids  = struct('candidToffs',0, 'candidTons',0, ...
    'candidTslps', 0, 'candidTacts',0);
defaultKernel   = 1;
defaultScalor   = 0.001;

checkRho        = @(x) validateattributes(x, {'double', 'single'}, {'scalar', 'positive', '<', 1});
checkb          = @(x) validateattributes(x, {'double', 'single'}, {'scalar', 'positive'});
checkK          = @(x) validateattributes(x, {'double', 'single'}, { 'positive', '<', 1});
checkTimp       = @(x) validateattributes(x.M, {'CellImpulse'},{'size',[n,n]});
checkid         = @(x) validateattributes(x, {'double', 'single'}, ...
    {'scalar', 'positive', 'integer', '<=', 4});

addOptional(pp, 'rho', defaultRho, checkRho);
addOptional(pp, 'b', defaultb, checkb);
addOptional(pp, 'K', defaultK, checkK);
addOptional(pp, 'Timp', defaultTimp, checkTimp);
addOptional(pp, 'candids', defaultCandids, @isstruct);
addOptional(pp, 'kernel', defaultKernel, @(x)checkid(x));
addOptional(pp, 'scalor', defaultScalor, checkb);

pp.KeepUnmatched = true;
parse(pp, varargin{:});


data                = struct('rho',rho);
data.b              = b;
data.K              = K;
data.Timp           = Timp;
data.candidToffs    = candids.candidToffs;
data.candidTons     = candids.candidTons;
data.candidTslps    = candids.candidTslps;
data.candidTacts    = candids.candidTacts;
data.kernel         = kernel;
data.scalor         = pp.Results.scalor;
end