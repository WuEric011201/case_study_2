%% This function takes three inputs
% x - a set of parameters
% t - the number of time-steps you wish to simulate

function [f, wobble_val] = sliroutput_full_policy(x,t)

% define each entry for x
k_infections = x(1);
k_fatality = x(2);
k_recover = x(3);
k_lockdown = x(4);
k_outlockdown=x(5);
k_vaccine = x(6);
k_lockinfections = x(7);
k_lockvaccine=x(8);

% set up initial conditions
ic_susc = x(9);
ic_lockdown = x(10);
ic_inf = x(11);
ic_rec = x(12);
ic_fatality = x(13);


susceptible = 1-k_lockdown-k_infections-k_vaccine;
quarantine = 1-k_lockinfections-k_lockvaccine-k_outlockdown;

% Set up SIRD within-population transmission matrix
model = [ susceptible    k_outlockdown                 0            0 0; 
        k_lockdown   quarantine        0                        0 0;
        k_infections k_lockinfections  (1-k_recover-k_fatality) 0 0;
        k_vaccine    k_lockvaccine     k_recover                1 0;
        0            0                 k_fatality               0 1];


% Set up the vector of initial conditions
x0 = [ic_susc, ic_lockdown, ic_inf, ic_rec, ic_fatality];

y_policy= zeros(t, 5); % Initialize the y_policy
y_policy(1, :) = x0;
wobble = zeros(t, 4); % Initialize wobble
% into lockdown rate, vaccine rate, lock vaccination rate and outlock rate
wobble(1, :) = [model(2, 1), model(4,1), model(4, 2), model(1, 2)]; 
for i = 1: t-1
    model = sirpolicy(model, y_policy(i,:));
    % Add the possible modified data in the next iteration
    wobble(i+1, :) = [model(2, 1), model(4,1), model(4, 2), model(1, 2)]; 
    next_state = model * y_policy(i, :)' ;
    y_policy(i+1, :) = next_state' ; % add another row
end
% Return the wobble value
wobble_val = max(std(wobble));

% return the output of the simulation
f = y_policy;

end