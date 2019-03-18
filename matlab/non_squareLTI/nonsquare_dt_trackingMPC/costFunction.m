function J = costFunction(u,theta,x,xs,N,u0,theta0,P,T,K,LAMBDA,PSI)
%% Cost function of non-quadratic discrete time LTI
% Inputs:
%   u:      optimization variable, from time k to time k+N-1 
%   theta:  optimisation variable, state and input parametrisation 
%   x:      current state at time k
%   Ts:     controller sample time
%   N:      prediction horizon
%   xref:   state references, constant from time k+1 to k+N
%   u0:     previous controller output at time k-1
%   theta0: previous theta output at time k-1

% Output:
%   J:      objective function cost
%
% Copyright 2016 The MathWorks, Inc.

%% Nonlinear MPC design parameters

Q = diag([1,1]);
R = diag([1,1]);

% Set initial plant states, controller output and cost.
xk = x;
uk = u0;

J = 0;
% Loop through each prediction step.
for ct=1:N
    % Obtain plant state at next prediction step.
    [xk1,~]= getTransitions(xk, uk, K, xs);
    
    % RUNNING COST
    if ct < N-1
        % accumulate state tracking cost from x(k+1) to x(k+N).
        J = J + (xk1-LAMBDA*theta)'*Q*(xk1-LAMBDA*theta);
        % accumulate MV rate of change cost from u(k) to u(k+N-1).
        if ct==1
              J = J + (xk1-LAMBDA*theta0)'*Q*(xk1-LAMBDA*theta0);
%             J = J + (uk-u0)'*R*(uk-u0);
              J = J + (uk-u0)'*R*(uk-u0);
        else
              % accumulate state tracking cost from x(k+1) to x(k+N).
              J = J + (xk1-LAMBDA*theta)'*Q*(xk1-LAMBDA*theta);
%             J = J + (uk-u(ct-1))'*R*(uk-u(ct-1));
              J = J + (uk-PSI*theta)'*R*(uk-PSI*theta);
        end
    end
    %TERMINAL COST
    if ct == N
        J = J + (xk1-LAMBDA*theta)'*P*(xk1-LAMBDA*theta) + (LAMBDA*theta-xs)'*T*(LAMBDA*theta-xs);
    end
    % Update xk and uk for the next prediction step.
    xk = xk1;
    if ct<N
        uk = u(:,ct+1);
    end
end


