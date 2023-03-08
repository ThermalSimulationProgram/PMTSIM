numCores = 1;
tswoff = 1;
tswon = tswoff;


numObs = numCores * 2;
ObservationInfo = rlNumericSpec([numObs, 1]);
ObservationInfo.Name = 'observations';
% numObs = 4;
% ObservationInfo = rlNumericSpec([numObs, 1]);
% ObservationInfo.Name = 'CartPole States';
% ObservationInfo.Description = 'x, dx, theta, dtheta';

numAct = numCores*2;
ActionInfo = rlNumericSpec([numAct, 1], 'LowerLimit', tswoff*1.5, 'UpperLimit', 50);
ActionInfo.Name = 'ptm_value';

% numAct = 1;
% ActionInfo = rlNumericSpec([numAct, 1], 'LowerLimit', -10, 'UpperLimit', 10);
% ActionInfo.Name = 'CartPole Action';


env = rlFunctionEnv(ObservationInfo, ActionInfo, 'processorThermalStep', 'resetProcessor');

% action = 5*ones(numAct, 1);
% rng(0);
% initObs = reset(env);
% [NextObs,Reward,IsDone,LoggedSignals] = step(env, action);
% NextObs

Tf = 100;
Ts = 0.2;
agent = createDDPGAgent(numObs, ObservationInfo, numAct, ActionInfo, Ts);


%% 
% The |createDDPGAgent| and |createTD3Agent| helper functions perform the following 
% actions.
%% 
% * Create actor and critic networks.
% * Specify options for actor and critic representations.
% * Create actor and critic representations using created networks and specified 
% options.
% * Configure agent specific options.
% * Create agent.
% DDPG Agent
% A DDPG agent approximates the long-term reward given observations and actions 
% using a critic value function representation. A DDPG agent decides which action 
% to take given observations by using an actor representation. The actor and critic 
% networks for this example are inspired by [1]. 
% 
% For details on the creating the DDPG agent, see the |createDDPGAgent| helper 
% function. For information on configuring DDPG agent options, see <docid:rl_ref#mw_5e9a4c5d-03d5-48d9-a85b-3c2d25fde43c 
% rlDDPGAgentOptions>.
% 
% For more information on creating a deep neural network value function representation, 
% see <docid:rl_ug#mw_2c7e8669-1e91-4d42-afa6-674009a08004 Create Policy and Value 
% Function Representations>. For an example that creates neural networks for DDPG 
% agents, see <docid:rl_ug#mw_0b71212e-521a-4a57-bde7-5dde0c1e0c90 Train DDPG 
% Agent to Control Double Integrator System>.
% TD3 Agent
% A TD3 agent approximates the long-term reward given observations and actions 
% using two critic value function representations. A TD3 agent decides which action 
% to take given observations using an actor representation. The structure of the 
% actor and critic networks used for this agent are the same as the ones used 
% for DDPG agent. 
% 
% A DDPG agent can overestimate the Q value. Since the agent uses the Q value 
% to update its policy (actor), the resultant policy can be suboptimal and accumulating 
% training errors can lead to divergent behavior. The TD3 algorithm is an extension 
% of DDPG with improvements that make it more robust by preventing overestimation 
% of Q values [3].
%% 
% * Two critic networks — TD3 agents learn two critic networks independently 
% and use the minimum value function estimate to update the actor (policy). Doing 
% so prevents accumulation of error in subsequent steps and overestimation of 
% Q values.
% * Addition of target policy noise — Adding clipped noise to value functions 
% smooths out Q function values over similar actions. Doing so prevents learning 
% an incorrect sharp peak of noisy value estimate.
% * Delayed policy and target updates — For a TD3 agent, delaying the actor 
% network update allows more time for the Q function to reduce error (get closer 
% to the required target) before updating the policy. Doing so prevents variance 
% in value estimates and results in a higher quality policy update.
%% 
% For details on the creating the TD3 agent, see the |createTD3Agent| helper 
% function. For information on configuring TD3 agent options, see <docid:rl_ref#mw_372ffd1e-e1d2-453c-a691-cfef5da40ef8 
% rlTD3AgentOptions>.
%% Specify Training Options and Train Agent
% For this example, the training options for the DDPG and TD3 agents are the 
% same.
%% 
% * Run each training session for 2000 episodes with each episode lasting at 
% most |maxSteps| time steps.
% * Display the training progress in the Episode Manager dialog box (set the 
% |Plots| option) and disable the command line display (set the |Verbose| option).
% * Terminate the training only when it reaches the maximum number of episodes 
% (|maxEpisodes|). Doing so allows the comparison of the learning curves for multiple 
% agents over the entire training session. 
%% 
% For more information and additional options, see <docid:rl_ref#mw_1f5122fe-cb3a-4c27-8c80-1ce46c013bf0 
% |rlTrainingOptions|>.

maxEpisodes = 3000;
maxSteps = floor(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxEpisodes,...
    'MaxStepsPerEpisode',maxSteps,...
    'ScoreAveragingWindowLength',250,...
    'Verbose',false,...
    'Plots','training-progress',...
    'StopTrainingCriteria','EpisodeCount',...
    'StopTrainingValue',maxEpisodes,...
    'SaveAgentCriteria','EpisodeCount',...
    'SaveAgentValue',maxEpisodes);
%% 
% To train the agent in parallel, specify the following training options. Training 
% in parallel requires Parallel Computing Toolbox™. If you do not have Parallel 
% Computing Toolbox software installed, set |UseParallel| to |false|.
%% 
% * Set the |UseParallel| option to t|rue|.
% * Train the agent in parallel asynchronously.
% * After every 32 steps, have each worker send experiences to the parallel 
% pool client (the MATLAB® process which starts the training). DDPG and TD3 agents 
% require workers to send experiences to the client.

trainOpts.UseParallel = 0;
trainOpts.ParallelizationOptions.Mode = 'async';
trainOpts.ParallelizationOptions.StepsUntilDataIsSent = 32;
trainOpts.ParallelizationOptions.DataToSendFromWorkers = 'Experiences';
%% 
% Train the agent using the <docid:rl_ref#mw_c0ccd38c-bbe6-4609-a87d-52ebe4767852 
% |train|> function. This process is computationally intensive and takes several 
% hours to complete for each agent. To save time while running this example, load 
% a pretrained agent by setting |doTraining| to |false|. To train the agent yourself, 
% set |doTraining| to |true|. Due to randomness in the parallel training, you 
% can expect different training results from the plots that follow. The pretrained 
% agents were trained in parallel using four workers.

 
% Train the agent.
trainingStats = train(agent,env,trainOpts);

%% 
% 
% 
% 
% 
% 
% 
% For the preceding example training curves, the average time per training step 
% for the DDPG and TD3 agents are 0.11 and 0.12 seconds, respectively. The TD3 
% agent takes more training time per step because it updates two critic networks 
% compared to the single critic used for DDPG. 
%% Simulate Trained Agents
% Fix the random generator seed for reproducibility.

rng(0)
%% 
% To validate the performance of the trained agent, simulate it within the biped 
% robot environment. For more information on agent simulation, see <docid:rl_ref#mw_983bb2e9-0115-4548-8daa-687037e090b2 
% |rlSimulationOptions|> and <docid:rl_ref#mw_e6296379-23b5-4819-a13b-210681e153bf 
% |sim|>.

simOptions = rlSimulationOptions('MaxSteps',maxSteps);
experience = sim(env,agent,simOptions);




