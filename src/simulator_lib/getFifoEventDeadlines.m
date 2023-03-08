function deadlines = getFifoEventDeadlines(fifo)

deadlines = [];
for i = 1 : fifo.Q
    deadlines = [deadlines, fifo.eventArray(i).absDeadline];  
end
end