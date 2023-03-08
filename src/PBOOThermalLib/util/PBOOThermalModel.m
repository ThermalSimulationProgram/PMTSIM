function [TM] = PBOOThermalModel(data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% data = struct('INVC',INVC, 'SplusG',SplusG, 'g_amb',g_amb, 'StimesT0',StimesT0, ...
%    'alpha_a',alpha_a, 'alpha_i',alpha_i, 'beta_a',beta_a, 'beta_i',beta_i, 't',t...
%    , 'name','ARM8cores');
%
%
%
TM = struct('lc_a',{},'lc_i',{},'ua',{},'ui',{},'initT',{},...
    'T_inf_a',{},'coreIdx',{},'p',{},'tend',{},'isCore',{},...
    'N',{},'n',{},'sizet',{},'name',{},'fftLength',...
    {}, 'TimpCores2Cores',{},'TimpSumNonCore2Cores',{},...
    'TimpSumAllCores2NonCores',{},'Nodes',{},'fitResults',{},...
    'A',{},'B',{}, 'tendA',{});

INVC        = data.INVC;
SplusG      = data.SplusG;
g_amb       = data.g_amb;
StimesT0    = data.StimesT0;
alpha_a     = data.alpha_a;
alpha_i     = data.alpha_i;
beta_a      = data.beta_a;
beta_i      = data.beta_i;
t           = data.t;
name        = data.name;
p           = data.p;

TM(1).coreIdx = [];
TM.name = name;
TM.isCore=[];
for i =1:size(alpha_a,2)
    if alpha_a(i,i)~=0
        TM.coreIdx = [TM.coreIdx,i];
        TM.isCore(i) =1;
    else
        TM.isCore(i) =0;
    end
end

TM.N = size(alpha_a,2);
TM.n = round( sum(TM.isCore) );


TM.lc_a = (SplusG - alpha_a);       % linear coefficient of DE in active mode
TM.lc_i  = (SplusG - alpha_i);      % linear coefficient of DE in idle mode
TM.ua = (beta_a + StimesT0);        % constant of DE in active mode
TM.ui = (beta_i + StimesT0);        % constant of DE in idle mode
%B_i2 = (beta_i + StimesT02);
TM.T_inf_a = TM.lc_a\TM.ua;         % steady state temperature in active mode
T_inf_i =  TM.lc_i\TM.ui;           % steady state temperature in idle mode
%T_inf_i2 = A_i\B_i2;

TM.initT = T_inf_i; % Initial temperature [K]

% Setup LTI model and state space representation
A = single(-INVC * (SplusG-alpha_a));
B = single(INVC);
TM.A = A;
TM.B = B;
sys = ss(A, B, eye(size(A)), 0);
H = impulse(sys, t);
 n = TM.n;
 N = TM.N;
%% post processing, get the equation of curve fitting for H
fitResults = cell(TM.N, TM.N);
sfitResults = cell(TM.n, TM.n);
V = zeros(size(H,2), size(H,3));
for i = 1:size(H,2)
    for j = 1:size(H,3)
        string = strcat(['curve fitting : i = ', num2str(i), ', j = ', num2str(j)]);
        disp(string);
         
        [fitresult, gof] = createTMresponseFit(t, H(:,i,j)');
       
        fitResults{i,j} = struct('fitresult',fitresult,'gof',gof);
        if i <= n 
            sfitResults{i,j} = struct('fitresult',fitresult,'gof',gof);
        end
    end
end
TM.fitResults = sfitResults;

%% find the point where H(:,i,j) and initTrace(i,:) become 0
epsilon = 3*10^-4;
TM.tend=[];
for i = 1:size(H,2)
    for j = 1:size(H,3)
        peak =  find(H(:,i,j)==max(H(:,i,j)), 1, 'last' );
        pointEnd = size(t,2);
        while (pointEnd-peak>=5)
            midP = round((pointEnd + peak)/2);
            if H(midP,i,j) <= epsilon
                pointEnd = midP;
            else
                peak = midP;
            end
        end
        TM.tend(i,j)=t(pointEnd);           %unit: sec
    end
end

maxt    = max(t);
mint    = 0;
epsilon = 1e-2;
while maxt-mint > epsilon
    middle = 0.5*(maxt + mint);
    if max(expm(A*middle)*TM.T_inf_a) > epsilon
        mint = middle;
    else
        maxt = middle;
    end
end
TM.tendA = mint;

%% 
% replace t with a new high resolution time trace

t           = 0 : p : max(t);
TM(1).sizet = size(t,2);
TM.p        = p;                       % resolution of time vector
%%  get constant impulses 
%   from   
%   cores to cores,
%   Noncore to cores, sum,
%   Allcores to noncores, sum


TM.TimpCores2Cores = zeros(n,n);
TM.TimpSumNonCore2Cores = zeros(1,n);
TM.TimpSumAllCores2NonCores = zeros(1, N);


for i = 1 : size(H,2)
    for j = 1 : size(H,3)
        NH = max( 0, fitResults{i,j}.fitresult(t) );
        
        if TM.isCore(i) && TM.isCore(j) %cores to cores,
            TM.TimpCores2Cores(i, j) = sum(NH) * TM.ui(j) * p;
        end
        
        if TM.isCore(i) && ~TM.isCore(j) %   Noncore to cores, sum,
            TM.TimpSumNonCore2Cores(i) = TM.TimpSumNonCore2Cores(i) + ...
            sum(NH) * TM.ui(j) * p;
        end
        
        if ~TM.isCore(i)        %   Allcores to noncores, sum
            TM.TimpSumAllCores2NonCores(i) = TM.TimpSumAllCores2NonCores(i) + ...
            sum(NH) * TM.ui(j) * p;
        end
        
    end
end


%% get Nodes
path = '../../input/';
floorplanName = strcat(path, name, 'floorplan.mat');

if exist(floorplanName, 'file') == 2
    load(floorplanName);
    TM.Nodes = flp.Nodes;
end

%%  fourier transform the impulses
%  
 fftLength = round( max(t) * 2 / p ) ;  % the dimension of the extended time vector
 TM.fftLength = fftLength;
TM.isComplete = false(TM.n, TM.n);
savename1 = strcat(path, name, 'TM', num2str(p),'p.mat');
clear H;
save(savename1, 'TM','-v7.3');
end
% 




