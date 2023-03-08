function config = outfigconfig()
config.i        = 1;
config.j        = 2;
config.epsilon 	= 2e-4;
config.tons     = [200,200,200];
config.toffs    = [160,400,200];
config.p        = 1e-4;
config.length   = 20;
config.t        = 0 : config.p : config.length;
config.fftlength= 50;
config.periods  = config.tons + config.toffs;
config.lcmp     = nlcm(config.periods/1000, 0.001);
end