function [this, event] = fetch(this)
if isclear(this)
    event = [];
    return;
end

event = this.eventArray(1);

this.eventArray(1) = [];
this.Q = this.Q - 1;
end