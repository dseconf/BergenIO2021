function Play(obj)
%
% Outputs human-readable summary of estimation results.
%

% First stage estimates
disp(' ');
disp('=============================================');
disp('GMM first stage estimates: ');
disp('---------------------------------------------');
disp(['Objective function: ', num2str(obj.firststage_fval)]);
disp('Parameter estimates: ');
disp([obj.model.paramlist', num2cell(obj.firststage_param)]);
disp('---------------------------------------------');
disp(' ');

% Second stage estimates
disp('GMM second stage estimates: ');
disp('---------------------------------------------');
disp(['Objective function: ', num2str(obj.fval)]);
disp('Parameter estimates: ');
disp([obj.model.paramlist', num2cell(obj.param)]);
disp('---------------------------------------------');
disp(' ');

% Model information
disp('---------------------------------------------');
disp(['Inner loop tolerance: ', num2str(obj.model.delta_tol)]);
disp(['Importance sampling: ', num2str(obj.importance_sample)]);
disp(['Number of unobservables: ', num2str(size(obj.unobs, 1))]);
disp('=============================================');
disp(' ');

end