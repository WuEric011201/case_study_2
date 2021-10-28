%% Function to simulate SIRD

function xt = simulateSIRD()

% Setup x so that it is zero at the beginning
xt = [1; zeros(3, 1)];

model = [.95, 0.04, 0, 0; .05, .85, 0, 0; 0, .1, 1, 0; 0, .01, 0, 1];

% 
% for i=1:t
%     xt=[xt, model*xt(i)];
% end

i =1; %i is counter of time

while abs(xt(1, i)) > .01
   xt=[xt, model*xt(:, i)]; % add another column to x, ie x(t+1), that is model and x of current t
    i=i+1;
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
title("SIRD model simulation 9.3");
legend("Susceptible", "Infected", "Recovered", "Deceased");

end