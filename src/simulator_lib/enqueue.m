function [this] = enqueue(this, event)
this.eventArray = [this.eventArray, event];
this.Q = this.Q + 1;

end