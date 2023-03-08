function obj = extendedResetPipeline(obj)

obj.currentEventId = 1;
obj.adaptionInterruptted = 0;
obj.simulationFinish = 0;
obj.temperatureConstraint = 380;

obj.rewardTime = 20000;
obj.violatedCounter = 0;
obj.adaptPeriod = 200;
obj.adaptTime = 0;



end