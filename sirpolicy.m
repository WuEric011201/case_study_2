function [policy_matrix] = sirpolicy(current_policy, slird_vals)

% this function returns a new policy (for the next time step) based on the current policy and current SLIRD values
% slird_vals: a 5 dimensional vector containing the current proportion of individuals in susceptible, lockdown, infected, recovered and deceased
% current_polc: a 5x5 matrix containing the current SLIRD policy (i.e., the state transition matrix)
policy_matrix = current_policy;

if (current_policy(3, 1) > (current_policy(4, 3) +current_policy(5, 3) )) % When infection rate is higher than recover rate
    % More quarantine
    policy_matrix(1, 1)= current_policy(1,1)-0.04; 
     policy_matrix(4, 1)= current_policy(4,1)+0.02;
     policy_matrix(2, 1)= current_policy(2,1) +0.02;
end

% if (slird_vals(1, 5) > 1.73e-05  ) % When death rate is higher than 
%     % More vaccination
%     policy_matrix(1, 1)= current_policy(1,1)-0.02; 
%     policy_matrix(4, 1)= current_policy(4,1)+0.02;
% end

end