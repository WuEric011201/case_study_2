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
k_vaccine = x(5);
k_lockinfections = x(6);
k_lockvaccine=x(7);

% set up initial conditions
ic_susc = x(8);
ic_lockdown = x(9);
ic_inf = x(10);
ic_rec = x(11);
ic_fatality = x(12);

susceptible = 1-k_lockdown-k_infections-k_vaccine;
quarantine = 1-k_lockinfections-k_lockvaccine;

% Set up SIRD within-population transmission matrix
A = [ susceptible    0                 0                        0 0; 
        k_lockdown   quarantine        0                        0 0;
        k_infections k_lockinfections  (1-k_recover-k_fatality) 0 0;
        k_vaccine    k_lockvaccine     k_recover                1 0;
        0            0                 k_fatality               0 1];
    
B = zeros(5,1);

% Set up the vector of initial conditions
x0 = [ic_susc, ic_lockdown, ic_inf, ic_rec, ic_fatality];

% simulate the SIRD model for t time-steps
sys_sir_base = ss(A,B,eye(5),zeros(5,1),1)
y = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);

% return a "cost".  This is the quantitity that you want your model to
% minimize.  Basically, this should encapsulate the difference between your
% modeled data and the true data. Norms and distances will be useful here.
% Hint: This is a central part of this case study!  choices here will have
% a big impact!
%stl = data(data{:, 5} == 2, :);


%population = ic_susc-stl{:,4};
population = 1-data(:, 2);
casesModel = y(:, 3) + y(:, 4) + y(:, 5);

%1: Suscpetible, 2: lockdown, 3: infected, 4: recovered, 5: dead

% f =sum( (population-y(:, 1)).^2+ (casesModel-stl{:, 3}).^2 +(stl{:, 4}-y(:, 2)).^2);
% Population , infected, deaths
% +(population-y(:, 1)-y(:, 2)).^2
f =sum( (casesModel-data(:, 1)).^2 + (data(:, 2)- y(:, 5)).^2 );
end