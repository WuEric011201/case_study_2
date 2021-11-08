% Clearing all the codes
clc;
clear;
close all;
% load the data
load("COVIDdata.mat");

coviddata = COVID_MO; % Specify the name
populationSTL=populations_MO{2, 2}; % Find the population

stl = coviddata(coviddata{:, 5} == 2, :); % Specify we are looking are St. Louis data
% Specify the start and end date
startin = find(stl{:, 1} == '2021-01-01'); 
endin = find(stl{:, 1} == '2021-10-01');
t =  endin(1,1)-startin(1,1) +1; % Length of t
% Find the real cases and death in this time frame
percentSTL = stl{startin(1,1):endin(1,1), [3, 4]}/populationSTL;

%% set up rate and initial condition constraints
% Set A and b to impose a parameter inequality constraint of the form A*x < b
A = [0 0 0 0 1 0 1 1 0 0 0 0 0; 1 0 0 1 0 1 0 0 0 0 0 0 0];
b = [1; 1];

%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf

Af = [0 0 0 0 0 0 0 0 1 0 0 0 0;
      0 0 0 0 0 0 0 0 0 1 0 0 0;
      0 0 0 0 0 0 0 0 0 0 1 0 0;
      0 0 0 0 0 0 0 0 0 0 0 1 0;
      0 0 0 0 0 0 0 0 0 0 0 0 1];
  
bf = [0.1025; 0.4445; 0.0241; 0.4201; 0.0088];

%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters lb < x < ub 

ub = [1 0.1 1 0.3 1 0.05 0.1 0.1 1 1 1 1 1]'; 
lb = [0.1 0 0 0 0.01 0 0 0 -1 -1 -1 -1 -1]'; 

% Specify some initial parameters for the optimizer to start from
x0 = [0.11 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1025 0.4445 0.0241 0.4201 0.0088]; 

% Set up the base case
sirafun = @(x)sliroutput(x,t,percentSTL);
x =  fmincon(sirafun,x0,A,b,Af,bf,lb,ub);
Y_fit = sliroutput_full(x,t);

% set up the modified case based on the base case
Y_fit_policy = sliroutput_full_policy(x, t);

% return a "cost"
averagei = mean(Y_fit(:, 3)); % Caculate the average of infection rate
averagei_policy = mean(Y_fit_policy(:, 3));
averaged = mean(Y_fit(:,5)); % Calculate the average of fatality rate
averaged_policy  = mean(Y_fit_policy(:,5)); 
% Calculate the cost and benefit 
J_benefit = 10*norm(Y_fit(: , 3)-Y_fit_policy(: , 3))+10*norm(Y_fit(:, 5)-Y_fit_policy(:, 5));
J_cost = 100* (norm(Y_fit(: , 2)-Y_fit_policy(:,2)))^2 + 800*(1 - averagei_policy/averagei)*(norm(Y_fit(: , 3)-Y_fit_policy(: , 3)))^2 ...
    + 800*(1 - averaged_policy/averaged)* (norm( Y_fit(: , 5)-Y_fit_policy(: , 5) ) ).^2;

J_relative = zeros(10, 1); % Initialize J_relative 
i = 1;
for a = 1: 1: 10 % alpha values range from 1 to 10
    J_relative(i , 1) = J_benefit - a* J_cost;  % compute the final j
    i = i+1; 
end

% Make a plot for J values different values of a
figure;
stem(J_relative);
xlabel("alpha value");
ylabel("J_relative valu");
title('Comparing the J_relative value against different alpha values');

% Make a plot for comparison
figure;
hold on;
plot(Y_fit(:, 3) + Y_fit(:, 5),'--o'); % Plot the base model cases
plot(Y_fit_policy(:, 3) + Y_fit_policy(:, 5)); % Plot the modified model cases
hold off;
legend("Base model Infected", "Controlled model Infected");
xlabel("Time");
ylabel("Percent of population");
title('Comparing the cases of the base model and the modified model');

figure;
hold on;
plot(Y_fit(:, 5), '--o'); % Plot the base model death 
plot(Y_fit_policy(:, 5)); % Plot the modified model death
hold off;
legend("Base model Deaths", "Controlled model Deaths");
xlabel("Time");
ylabel("Percent of population");
title('Comparing the death of the base model and the modified model');

% Plot for the projected modified case after applying policy
figure;
hold on;
plot(Y_fit_policy(:, 1));
plot(Y_fit_policy(:, 2));
plot(Y_fit_policy(:, 3));
plot(Y_fit_policy(:, 4));
plot(Y_fit_policy(:, 5));
hold off;
legend("Susceptible", "lockdown", "infected", "recovered", "dead");
xlabel("Time");
ylabel("Percent of population");
title('Plotting different parameters within the modified model ');

% Plot for the projected base case after applying policy
figure;
hold on;
plot(Y_fit(:, 1));
plot(Y_fit(:, 2));
plot(Y_fit(:, 3));
plot(Y_fit(:, 4));
plot(Y_fit(:, 5));
legend("Susceptible", "lockdown", "infected", "recovered", "dead");
xlabel("Time");
ylabel("Percent of population");
title('Plotting different parameters within the base model ');
