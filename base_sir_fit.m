
% Here is an example that reads in infection and fatalities from STL City
% and loads them into a new matrix covidstlcity_full
% In addition to this, you have other matrices for the other two regions in question
% Load the data
load("COVIDdata.mat");
% covidstlcity_full = double(table2array(COVID_STLcity(:,[5:6])))./300000;

coviddata = COVID_MO; % Specify the data we are looking for 
time = coviddata(coviddata{:, 5} == 2, 1); % Specify the time
t = datenum(time{size(time, 1), 1}-time{1, 1})+1; % Specify the t

populationSTL=populations_MO{2, 2}; % Looking for the MO population

% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.
sirafun= @(x)siroutput(x,t,coviddata);

%% set up rate and initial condition constraints
% Set A and b to impose a parameter inequality constraint of the form A*x < b
% Note that this is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
A = [];
b = [];

%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [];
bf = [];

%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = []';
lb = []';

% Specify some initial parameters for the optimizer to start from
x0 = [0 0 0 populationSTL 0 0 0]; 

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub);

% plot(Y);
% legend('S','L','I','R','D');
% xlabel('Time')

Y_fit = siroutput_full(x,t);

figure(1);

% Make some plots that illustrate your findings.
% TO ADD

hold on;
plot(Y_fit(:, 1));
plot(Y_fit(:, 2));
plot(Y_fit(:, 3));
plot(Y_fit(:, 4));

