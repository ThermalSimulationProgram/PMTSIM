function event_point=accumulation2point(event_trace)
if(size(event_trace,1)<2)
    error('please input at least two point event!!!');
end
event_point=event_trace;
for i=2:size(event_trace,1)
    event_point(i,2)=event_trace(i,2)-event_trace(i-1,2);
end
