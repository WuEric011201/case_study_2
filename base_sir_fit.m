clc;
clear;
close all;
% Here is an example that reads in infection and fatalities from STL City
% and loads them into a new matrix covidstlcity_full
% In addition to this, you have other matrices for the other two regions in question
% Load the data
load("COVIDdata.mat");

coviddata = COVID_MO; % Specify the data we are looking for 
time = coviddata(coviddata{:, 5} == 2, 1); % select first column
t = datenum(time{size(time, 1), 1}-time{1, 1})+1; % caculate the length of t
phase1 = 110; % first phase
populationSTL=populations_MO{2, 2};

stl = coviddata(coviddata{:, 5} == 2, :);
percentSTL = stl{:, [3, 4]}/populationSTL; % First column means cases and the second column means death
percentSTL_phase1 = stl{1:110,[3,4]}/populationSTL;
% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.
%sirafun= @(x)siroutput(x,t,coviddata);
sirafun= @(x)siroutput(x,t,percentSTL);

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
lb = [ ]';

% Specify some initial parameters for the optimizer to start from
%x0 = [0 0 0 populationSTL 0 0 0]; 
x0 = [0 0 0 1 0 0 0]; 

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub); % set up the optimization process
Y_fit = siroutput_full(x, t); % 

% Make some plots that illustrate your findings.
figure;
hold on;
plot(Y_fit(:, 2) + Y_fit(:, 3)+Y_fit(:, 4)); % The total cases modeled
plot(percentSTL(:, 1)); % the real infection cases
title("COVID cases compared between the model and the real data");
legend("Model Infected", "Real Infected" );
xlabel("Time");
ylabel("Percent of population");
plot(percentSTL_phase1(:, 2));
xlabel('Time')
hold off;

figure;
hold on;
title('Comparison between fitted death and real death cases');
plot(Y_fit(:, 4)); % the death cases modeled
plot(percentSTL(:, 2)); % the real death cases
legend ("Model Deaths", "Real Dead");
xlabel('Time');
ylabel("Percent of population");
hold off;
