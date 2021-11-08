function [policy_matrix] = sirpolicy(current_policy, slird_vals)

% this function returns a new policy (for the next time step) based on the current policy and current SLIRD values
% slird_vals: a 5 dimensional vector containing the current proportion of individuals in susceptible, lockdown, infected, recovered and deceased
% current_polc: a 5x5 matrix containing the current SLIRD policy (i.e., the state transition matrix)
policy_matrix = current_policy;

% if (slird_vals(1, 3) > 0.03 && current_policy(1,1)>=0.1) % When infection rate is higher than recover rate
%     % More quarantine and vaccination
%      policy_matrix(1, 1)= current_policy(1,1) - 0.1; 
%      policy_matrix(4, 1)= current_policy(4,1)+0.05;
%      policy_matrix(2, 1)= current_policy(2,1) +0.05;
% end

end