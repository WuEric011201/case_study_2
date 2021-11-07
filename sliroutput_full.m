%% This function takes three inputs
% x - a set of parameters
% t - the number of time-steps you wish to simulate

function f = sliroutput_full(x,t)

% Here is a suggested framework for x.  However, you are free to deviate
% from this if you wish.

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


% The next line creates a zero vector that will be used a few steps.
B = zeros(5,1);

% Set up the vector of initial conditions
x0 = [ic_susc, ic_lockdown, ic_inf, ic_rec, ic_fatality];

% Here is a compact way to simulate a linear dynamical system.
% Type 'help ss' and 'help lsim' to learn about how these functions work!!
sys_sir_base = ss(A,B,eye(5),zeros(5,1),1)
y = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);
% return the output of the simulation
f = y;

end