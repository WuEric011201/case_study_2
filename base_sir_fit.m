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
t = datenum(time{size(time, 1), 1}-time{1, 1})+1; % caculate the total length of t
phase1 = 110; % first phase
phase2 = 130;
phase3 = 94;
phase4 = 151;
phase5 = 109;
populationSTL=populations_MO{2, 2};

stl = coviddata(coviddata{:, 5} == 2, :);
percentSTL = stl{:, [3, 4]}/populationSTL; % First column means cases and the second column means death
percentSTL_phase1 = stl{1:110,[3,4]}/populationSTL;
percentSTL_phase2 = stl{111:240,[3,4]}/populationSTL;
percentSTL_phase3 = stl{241:334,[3,4]}/populationSTL;
percentSTL_phase4 = stl{335:485,[3,4]}/populationSTL;
percentSTL_phase5 = stl{486:594,[3,4]}/populationSTL;
% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.

sirafun= @(x)siroutput(x,t,percentSTL); %total
sirafun1= @(x)siroutput(x,phase1,percentSTL_phase1);  % phase 1
sirafun2= @(x)siroutput(x,phase2,percentSTL_phase2);  % phase 2
sirafun3= @(x)siroutput(x,phase3,percentSTL_phase3);  % phase 3
sirafun4= @(x)siroutput(x,phase4,percentSTL_phase4);  % phase 4
sirafun5= @(x)siroutput(x,phase5,percentSTL_phase5);  % phase 5

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
x0 = [0 0 0 1 0 0 0]; 

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub); % set up the optimization process
x1 = fmincon(sirafun1,x0,A,b,Af,bf,lb,ub); % phase 1
x2 = fmincon(sirafun2,x0,A,b,Af,bf,lb,ub); % phase 2
x3 = fmincon(sirafun3,x0,A,b,Af,bf,lb,ub); % phase 3
x4 = fmincon(sirafun4,x0,A,b,Af,bf,lb,ub); % phase 4
x5 = fmincon(sirafun5,x0,A,b,Af,bf,lb,ub); % phase 5

Y_fit = siroutput_full(x, t); % create the model 
Y_fit1 = siroutput_full(x1, phase1); % phase 1
Y_fit2 = siroutput_full(x2, phase2); % phase 2
Y_fit3 = siroutput_full(x3, phase3); % phase 3
Y_fit4 = siroutput_full(x4, phase4); % phase 4
Y_fit5 = siroutput_full(x5, phase5); % phase 5

% Make some plots that illustrate your findings.
figure;
hold on;
plot(1: 594, (Y_fit(:, 2) + Y_fit(:, 3)+Y_fit(:, 4))); % The total cases modeled
plot(1:110,(Y_fit1(:, 2) + Y_fit1(:, 3)+Y_fit1(:, 4)), "--o"); 
plot(111: 240, Y_fit2(:, 2) + Y_fit2(:, 3)+Y_fit2(:, 4),"*"); 
plot(241: 334, Y_fit3(:, 2) + Y_fit3(:, 3)+Y_fit3(:, 4),"--o"); 
plot(335: 485, Y_fit4(:, 2) + Y_fit4(:, 3)+Y_fit4(:, 4),"*"); 
plot(486: 594, Y_fit5(:, 2) + Y_fit5(:, 3)+Y_fit5(:, 4),"--o"); 

plot(percentSTL(:, 1), 'LineWidth',3); % the real infection cases

title("COVID cases compared between the model and the real data");
legend("Model Infected", "Phase 1","Phase 2","Phase 3","Phase 4","Phase 5","Real Infected" );
xlabel("Time");
ylabel("Percent of population");

xlabel('Time')
hold off;

figure;
hold on;
title('Comparison between fitted death and real death cases');
plot(Y_fit(:, 4)); % the death cases modeled
plot(Y_fit1(:, 4),"--o"); 
plot(111: 240, Y_fit2(:, 4),"--o"); 
plot(241: 334, Y_fit3(:, 4),"--o"); 
plot(335: 485, Y_fit4(:, 4),"--o"); 
plot(486: 594, Y_fit5(:, 4),"--o"); 
plot(percentSTL(:, 2),  'LineWidth',3); % the real death cases
legend ("Model Deaths", "Phase 1","Phase 2","Phase 3","Phase 4","Phase 5","Real Dead");
xlabel('Time');
ylabel("Percent of population");
hold off;
