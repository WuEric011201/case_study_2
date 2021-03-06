%% Function to simulate SIRD

function xt = simulateSIRD()

% Setup x so that it is zero at the beginning
xt = [1; zeros(3, 1)];

% Build the model from the textbook 9.3
model = [.95, 0.04, 0, 0; 
            .05, .85, 0, 0; 
            0, .1, 1, 0; 
            0, .01, 0, 1];
%  Set up the test case
xt_test =[1; zeros(3, 1)]; 
xt_test2 =[1; zeros(3, 1)]; 

% Build the model with a higher infection rate
model1 = [.7, 0.04, 0, 0; 
                .3, .85, 0, 0; 
                0, .1, 1, 0; 
                0, .01, 0, 1];
            
% Build the model with a higher death rate
model2 = [.95, 0.04, 0, 0; 
                .05, .78, 0, 0; 
                0, .08, 1, 0; 
                0, .1, 0, 1];
% 
% for i=1:t
%     xt=[xt, model*xt(i)];
% end

i =1; %i is counter of time
% Compute the next iteration as long as the infection population is larger
% than 1% of the total population. 
while abs(xt(1, i)) > .01
   xt=[xt, model*xt(:, i)]; % add another column to x, ie x(t+1), that is model and x of current t
    i=i+1;
end

% testing1
j = 1;
while abs(xt_test(1, j)) > .01
    xt_test=[xt_test, model1*xt_test(:, j)]; 
    j=j+1;
end

% testing2
z = 1;
while abs(xt_test2(1, z)) > .01
    xt_test2=[xt_test2, model2*xt_test2(:, z)]; 
    z=z+1;
end
% t = 30;
% for i=1:t
%    current = model * xt(:,i);
%    xt = cat(2,xt,current);
% end

figure;
hold on;
plot(xt(1, :));
plot(xt(2, :));
plot(xt(3, :));
plot(xt(4, :));
xlabel("Days"); %label the x axis
ylabel("Percentage of Total Population");  %Label y axis
title("SIRD model simulation from the book 9.3");
legend("Susceptible", "Infected", "Recovered", "Deceased");

% Plot the test case with higher infection rate
figure;
hold on;
plot(xt_test(1, :));
plot(xt_test(2, :));
plot(xt_test(3, :));
plot(xt_test(4, :));
xlabel("Days"); %label the x axis
ylabel("Percentage of Total Population");  %Label y axis
title("SIRD model simulation with a higher infection rate");
legend("Susceptible", "Infected", "Recovered", "Deceased");

% Plot the test case with higher death rate
figure;
hold on;
plot(xt_test2(1, :));
plot(xt_test2(2, :));
plot(xt_test2(3, :));
plot(xt_test2(4, :));
xlabel("Days"); %label the x axis
ylabel("Percentage of Total Population");  %Label y axis
title("SIRD model simulation with a higher death rate");
legend("Susceptible", "Infected", "Recovered", "Deceased");

end