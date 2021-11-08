%% This function takes three inputs
% x - a set of parameters
% t - the number of time-steps you wish to simulate
% data - actual data that you are attempting to fit

function f = sliroutput(x,t,data)

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

Aonly = [ susceptible    k_outlockdown                 0            0 0; 
        k_lockdown   quarantine        0                        0 0;
        k_infections k_lockinfections  (1-k_recover-k_fatality) 0 0;
        0    0     k_recover                1 0;
        0            0                 k_fatality               0 1];
% Set up the vector of initial conditions
x0 = [ic_susc, ic_lockdown, ic_inf, ic_rec, ic_fatality];

% simulate the SIRD model for t time-steps
sys_sir_base = ss(A,B,eye(5),zeros(5,1),1)
y = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);

sys_only = ss(Aonly, B, eye(5), zeros(5, 1), 1);
yOnly = lsim(sys_only,zeros(t,1),linspace(0,t-1,t),x0);

% return a "cost".  This is the quantitity that you want your model to
% minimize.  Basically, this should encapsulate the difference between your
% modeled data and the true data. Norms and distances will be useful here.
% Hint: This is a central part of this case study!  choices here will have
% a big impact!
population = 1-data(:, 2);
casesModel = y(:, 3) + y(:, 5)+yOnly(:, 4);

%1: Suscpetible, 2: lockdown, 3: infected, 4: recovered, 5: dead

f =sum((data(:, 2)- y(:, 5)).^2+ (casesModel-data(:, 1)).^2);
end