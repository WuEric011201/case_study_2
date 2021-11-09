function [policy_matrix] = sirpolicy(current_policy, slird_vals)

% this function returns a new policy (for the next time step) based on the current policy and current SLIRD values
% slird_vals: a 5 dimensional vector containing the current proportion of individuals in susceptible, lockdown, infected, recovered and deceased
% current_polc: a 5x5 matrix containing the current SLIRD policy 

policy_matrix = current_policy; % Set it to the status quo
% If the infection population is low and lockdown population is high and
% rate of remaining in the lockdown is high, we move people outside of
% lockdown
if(slird_vals(1, 3) <0.001 &&  slird_vals(1, 2) > 0.3  && current_policy(2,2)>=0.001)
    policy_matrix(1, 2)= current_policy(1, 2) + 0.0005;
    policy_matrix(2, 2)= current_policy(2, 2) - 0.001;
    policy_matrix(4, 2)= current_policy(4, 1) + 0.0005;
end

% If the infection population is high and lockdown population is low and
% the rate of remaining unvaccinated but active is high, we vaccinate and
% move people into lockdown. 

if (slird_vals(1, 3) > 0.01  && current_policy(1,1)>=0.002) % When infection rate is higher than recover rate
    % More quarantine and vaccination
     policy_matrix(1, 1)= current_policy(1,1) - 0.002; 
     policy_matrix(4, 1)= current_policy(4,1)+0.001;
     policy_matrix(2, 1)= current_policy(2,1) +0.001;
end

end