%===============================================================================
% tleed_nomadm_Param:  Parameter file for the tleed_nomadm problem
% ------------------------------------------------------------------------------
% VARIABLES:
%  Param       = structure of parameters set by the Parameter file
%    .iterate0 =   initial iterate
%    .p_dir    =   directory where the problem files are located
%    .delta    =   required parameter (0.4)
%    .rank     =   required parameter (0)
%    .nMax     =   number of atoms (14)
%    .nDim     =   dimension of the atom position variable (3)
%    .A        =   matrix of linear/bound constraint coefficient
%    .l        =   vector of linear/bound constraint lower bounds 
%    .u        =   vector of linear/bound constraint upper bounds 
%    .plist    =   cell array of lists of allowed values for each .p variable
%  n           = number of continuous variables in the optimization problem
%===============================================================================
function Param = tleed_nomadm_Param

% Get initial iterate
Param.iterate0 = tleed_nomadm_x0;

% Set input arguments for Fortran code
Param.p_dir    = fileparts(mfilename('fullpath'));
Param.delta    = 0.4;
Param.dir      = int32(0);
Param.rank     = int32(0);
Param.nMax     = length(Param.iterate0.p);
n              = length(Param.iterate0.x);
m              = n - Param.nMax;
Param.nDim     = n/Param.nMax;

% Set linear/bound constraint parameters
Param.A        = eye(n);
Param.l        = [-2.4*ones(3,1); -0.4*ones(5,1); 0.8*ones(6,1); -10*ones(m,1)];
Param.u        = [-0.4*ones(3,1);  0.8*ones(5,1); 2.2*ones(6,1);  10*ones(m,1)];

% Set categorical variable lists of allowable variables
for i = 1:Param.nMax
	Param.plist{i} = {1,2};
end

% PAST DATA (from Omega file)

% l/u = -0.4 in vectors above used to be -0.1
% l(1:14,1) = -5*ones(14,1);
% u(1:14,1) =  5*ones(14,1);

%  Something is wrong in this boundary from the pgaleed1.C
%  parmz(0+1)  = -1.8757;
%  parmz(1+1)  = -1.8067;
%  parmz(2+1)  = -1.7941;
%  parmz(3+1)  = -0.3861;
%  parmz(4+1)  = -0.2528;
%  parmz(5+1)  = -0.0461;
%  parmz(6+1)  =  0.0690;
%  parmz(7+1)  =  0.1874;
%  parmz(8+1)  =  1.7112;
%  parmz(9+1)  =  1.7350;
%  parmz(10+1) =  1.7378;
%  parmz(11+1) =  1.7467;
%  parmz(12+1) =  1.7751;
%  parmz(13+1) =  1.7897;

%  parmx(0+1)  =  0.0000;
%  parmx(1+1)  =  3.0047;
%  parmx(2+1)  =  3.1141;
%  parmx(3+1)  =  6.2250;
%  parmx(4+1)  =  6.2250;
%  parmx(5+1)  =  1.2552;
%  parmx(6+1)  =  3.6738;
%  parmx(7+1)  =  3.7093;
%  parmx(8+1)  =  5.0398;
%  parmx(9+1)  =  0.0000;
%  parmx(10+1) =  5.0355;
%  parmx(11+1) =  5.0402;
%  parmx(12+1) =  2.5445;
%  parmx(13+1) =  2.4371;

%  parmy(0+1)  =  0.0000;
%  parmy(1+1)  =  3.0047;
%  parmy(2+1)  =  0.0000;
%  parmy(3+1)  =  1.2913;
%  parmy(4+1)  =  3.9379;
%  parmy(5+1)  =  1.2552;
%  parmy(6+1)  =  1.2125;
%  parmy(7+1)  =  3.7093;
%  parmy(8+1)  =  0.0000;
%  parmy(9+1)  =  0.0000;
%  parmy(10+1) =  5.0355;
%  parmy(11+1) =  2.4703;
%  parmy(12+1) =  0.0000;
%  parmy(13+1) =  2.4371;

%  bfp = [parmz'; parmx'; parmy'];
%  l   = bfp - 0.4;
%  u   = bfp + 0.4;

return
