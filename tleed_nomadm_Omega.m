%===============================================================================
% tleed_nomadm_Omega:  Sets linear/bound constraints for tleed_nomadm problem.
% ------------------------------------------------------------------------------
% VARIABLES:
%  A           = matrix of linear constraint coefficients
%  l           = vector of lower bounds
%  u           = vector of upper bounds
%  plist       = cell array of lists of allowed categorical variable values
%  n           = number of continuous variables in the optimization problem
%  Param       = structure of parameters set by the Parameter file
%                (all fields match their corresponding varianble names above)
%-------------------------------------------------------------------------------
%  Note:  Setting of specific values has been moved to the parameter file.
%===============================================================================

function [A,l,u,plist] = tleed_nomadm_Omega(n)  %#ok

% Bounds on the continuous variables
Param = getappdata(0,'PARAM');
A     = Param.A;
l     = Param.l;
u     = Param.u;
plist = Param.plist;
return
