function [tmptrace, trace]=gentrace_BWS(stream,tracetype,traceLen,deadlineFactor,WCETs,p,m)
%generate event
alphaA = rtcpjd(stream(1), stream(2), stream(3));
%% simple trace
if tracetype == 0
    tmptrace    = rtscurve2trace(alphaA(1), traceLen);
% complex trace
else
    tmptrace    = rtscurves2trace(alphaA, 'real', traceLen, traceLen/8, 0);
end
tmptrace(:,1)=ceil(tmptrace(:,1));
trace = accumulation2point(tmptrace);
%trace=divide_burst(trace);

%trace=divide_burst(trace);
%% A guess to function divide_burst
trace   = divide_burst_guess(trace);
% trace here: trace(:,1) the time points of event arrivals
%             trace(:,2) the number of events arriving at corresponding
%             time

% number of events
TolEvent    =size(trace,1);
% relative deadline
Deadline    =stream(1)*deadlineFactor;
% p = p(:)';
% WCETs = WCETs(:);

% absolute deadline
abs_deadline = trace(:,1) + Deadline.*ones(TolEvent,1);

p = p(:);
WCETs = WCETs(:);

% ew = WCETs;
% eb = p .* ew;


exe_time_at_stage = ones(TolEvent,1) * ( p.*WCETs )'+...
    (ones(TolEvent,1) * ((1-p).*WCETs)') .* rand(TolEvent,m);

trace = [trace, abs_deadline, exe_time_at_stage];
% trace here: trace(:,1) the time points of event arrivals
%             trace(:,2) the number of events arriving at corresponding
%             time
%             trace(:,3) the absolute deadlines
%             trace(:,4) exe time at first stage
%             trace(:,5)             second
%             trace(:,6)             third
%trace=[trace trace(:,1)+Deadline.*ones(TolEvent,1) ones(TolEvent,1)*(p.*WCETs)'+(ones(TolEvent,1)*((1-p).*WCETs)').*rand(TolEvent,m)];


% %% A guess to function divide_burst
% trace = divide_burst_guess(trace);
% 
% TolEvent=size(trace,1);
% Deadline=stream(1)*deadlineFactor;
% % p = p(:)';
% % WCETs = WCETs(:);
% trace=[trace trace(:,1)+Deadline.*ones(TolEvent,1) ones(TolEvent,1)*(p.*WCETs)'+(ones(TolEvent,1)*((1-p).*WCETs)').*rand(TolEvent,m)];
