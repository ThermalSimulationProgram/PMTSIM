function this = FIFO()
this.Q                  = 0; % number of stored events
this.eventArray         = [];% array of stored events
this.nextEventInTime    = inf; 
end

