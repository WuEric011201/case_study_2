clc;
clear;
close all;
% Here is an example that reads in infection and fatalities from STL City
% and loads them into a new matrix covidstlcity_full
% In addition to this, you have other matrices for the other two regions in question
load("COVIDdata.mat");
% covidstlcity_full = double(table2array(COVID_STLcity(:,[5:6])))./300000;


coviddata = COVID_MO; % TO SPECIFY
populationSTL=populations_MO{2, 2};

stl = coviddata(coviddata{:, 5} == 2, :);
startin = find(stl{:, 1} == '2021-01-01');
endin = find(stl{:, 1} == '2021-10-01');
t =  endin(1,1)-startin(1,1) +1;
percentSTL = stl{startin(1,1):endin(1,1), [3, 4]}/populationSTL;

% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.
%sirafun= @(x)siroutput(x,t,coviddata);
sirafun_policy= @(x)sliroutput_policy(x,t,percentSTL);
sirafun = @(x)sliroutput(x,t,percentSTL);
%% set up rate and initial condition constraints
% Set A and b to impose a parameter inequality constraint of the form A*x < b
% Note that this is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
A = [0 0 0 0 1 0 1 1 0 0 0 0 0; 1 0 0 1 0 1 0 0 0 0 0 0 0];
b = [1; 1];

%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [0 0 0 0 0 0 0 0 1 0 0 0 0;
      0 0 0 0 0 0 0 0 0 1 0 0 0;
      0 0 0 0 0 0 0 0 0 0 1 0 0;
      0 0 0 0 0 0 0 0 0 0 0 1 0;
      0 0 0 0 0 0 0 0 0 0 0 0 1];
  
bf = [1; 0; 0; 0; 0;];

%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = [1 0.1 1 0.3 1 0.05 0.1 0.1 1 1 1 1 1]'; %outlockdown is a funky one
lb = [0.1 0 0 0 0.01 0 0 0 -1 -1 -1 -1 -1]';

% Specify some initial parameters for the optimizer to start from
x0 = [0.11 0.1 0.1 0.1 0.1 0.1 0.1 0.1 1 0 0 0 0]; 

% This is the key line that tries to opimize your model parameters in order to
% fit the data
x_policy = fmincon(sirafun_policy,x0,A,b,Af,bf,lb,ub)
x =  fmincon(sirafun,x0,A,b,Af,bf,lb,ub);

Y_fit_policy = sliroutput_full_policy(x_policy,t);
Y_fit = sliroutput_full(x,t);
% Make some plots that illustrate  findings.
figure;
hold on;

plot(Y_fit(:, 3) + Y_fit(:, 5));
plot(Y_fit_policy(:, 3) + Y_fit_policy(:, 5));
plot(Y_fit(:, 5));
plot(Y_fit_policy(:, 5));
title("Cases and deaths");
legend("Base model Infected", "Controlled model Infected", "Base model Deaths", "Controlled model Deaths");
xlabel("Time");
ylabel("Percent of population");

figure;
hold on;
plot(Y_fit_policy(:, 1));
plot(Y_fit_policy(:, 2));
plot(Y_fit_policy(:, 3));
plot(Y_fit_policy(:, 4));
plot(Y_fit_policy(:, 5));
legend("Susceptible", "lockdown", "infected", "recovered", "dead");

figure;
hold on;
plot(Y_fit(:, 1));
plot(Y_fit(:, 2));
plot(Y_fit(:, 3));
plot(Y_fit(:, 4));
plot(Y_fit(:, 5));
legend("Susceptible", "lockdown", "infected", "recovered", "dead");

