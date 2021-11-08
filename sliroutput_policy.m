%% This function takes three inputs
% x - a set of parameters
% t - the number of time-steps you wish to simulate
% data - actual data that you are attempting to fit

function f = sliroutput_policy(x,t,data)

% set up transmission constants

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

A = [ susceptible    k_outlockdown                 0            0 0; 
        k_lockdown   quarantine        0                        0 0;
        k_infections k_lockinfections  (1-k_recover-k_fatality) 0 0;
        k_vaccine    k_lockvaccine     k_recover                1 0;
        0            0                 k_fatality               0 1];
    
B = zeros(5,1);
% Set up the vector of initial conditions
x0 = [ic_susc, ic_lockdown, ic_inf, ic_rec, ic_fatality];

% simulate the base model
sys_sir_base = ss(A,B,eye(5),zeros(5,1),1);
y = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);
                    
y_policy= zeros(t, 5);
y_policy(1, :) = x0;
wobble_cost = zeros(t, 3);

for i = 1: t-1
    model = sirpolicy(A, y_policy(i,:));
    wobble_cost(i, :) = [model(4, 1)+ model(4, 2), model(2,1), model(1, 2)];

    next_state = model * y_policy(i, :)' ;
    y_policy(i+1, :) = next_state' ; % add another column to xt, ie x(t+1), that is model and x of current t
end
wobble_cost (t, :) = [model(4, 1)+ model(4, 2), model(2,1), model(1, 2)]; % configure the last row 

% sys_sir_base = ss(sirpolicy(A, x0),B,eye(5),zeros(5,1),1)
% y_policy = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);

% return a "cost"
averagei = mean(y(:, 3)); % Caculate the average of infection rate
averagei_policy = mean(y_policy(:, 3));
averaged = mean(y(:,5)); % Calculate the average of fatality rate
averaged_policy  = mean(y_policy(:,5)); 
J_benefit = 10*norm(y(: , 3)-y_policy(: , 3))+10*norm(y(:, 5)-y_policy(:, 5));
J_cost = 100* (norm(y(: , 2)-y(:,2))).^2 + 800*(1 - averagei_policy/averagei)*(norm(y(: , 3)-y_policy(: , 3))).^2 ...
    + 800*(1 - averaged_policy/averaged)* (norm( y(: , 5)-y_policy(: , 5) ) ).^2;
a = 1; % define alpha 
wobble = max(std(wobble_cost));
J_relative = J_benefit - a* J_cost - wobble
f = -J_relative;
end