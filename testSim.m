%===============================================================================
% testSim:  Tests the functionality of the TLEED and KLEED mex interface between 
%           MATLAB and Fortran.
% ------------------------------------------------------------------------------
% VARIABLES:
%   problem_dir = directory where TLEED and KLEED files are located
%   work_dir    = name of subfolder where working files are stored
%   success     = success/failure flag for creating working directory
%   message     = error message thrown if working directory creation fails
%   code        = name of executable (tleed or kleed) in loop
%   prob        = name of functions file used in NOMADm runs
%   Param       = name of parameter file used in NOMADm runs
%   fx          = function value obtained from running TLEED or KLEED
% ==============================================================================
function testSim(varargin)

% Error check number of input arguments
if nargin > 1, error('Number of input arguments must be 0 or 1.'); end

% If work directory not set up, construct it
problem_dir = fileparts(mfilename('fullpath'));
work_dir    = [problem_dir, filesep, 'work000'];
if ~exist(work_dir,'dir')
   [success,message] = mkdir(work_dir);
   if ~success, error(message); end
end

% Test KLEED and/or TLEED
for code = {'kleed','tleed'}
   if ~nargin || strcmpi(varargin{1},code{1})
      if ~exist(['GPS',lower(code{1}),'_wg.mexw64'],'file')
         compile_tleed_kleed(code{1});
      end
      fprintf('\n%s\n',['   Testing ',upper(code{1}),':']);
      prob  = [lower(code{1}),'_nomadm'];
      Param = feval([prob, '_Param']);
      setappdata(0,'PARAM',Param);
      for k = 1:length(Param.iterate0)
         fx = feval(prob,Param.iterate0.x, Param.iterate0.p);
         fprintf('%s\n',['      fx = ', num2str(fx)]);
      end
      rmappdata(0,'PARAM');
   end
end
fprintf('\n');
return
