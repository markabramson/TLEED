%===============================================================================
% tleed_nomadm:  Returns the R-factor of a given structure in the TLEED
%                calculation (specifically for Ni(001)-Li-(5x5), which contains
%                14 inequivalent atoms).  This function is set up for use with
%                the NOMADm optimization software.
% ------------------------------------------------------------------------------
% VARIABLES:
%  fx       = computed r-factor of the given structure
%  x        = vector of atom xyz positions
%  p        = cell array of atom identities (1 = Ni, 2 = Li)
%  Param    = structure of parameters set by the Parameter file
%    .nMax  =   number of atoms (14)
%    .nDim  =   dimension of the atom position variable (3)
%    .delta =   required parameter (0.4)
%    .rank  =   required parameter (0)
%    .p_dir =   directory where the problem files are located
%  PARM     = NMAX x NDIM matrix containing a reshape of x
%  MINB     = required parameter (x - 0.4)
%  MAXB     = required parameter (x + 0.4)
%  NTYPE    = a conversion of p from cell array to numerical array
%===============================================================================
function fx = tleed_nomadm(x,p)

Param = getappdata(0,'PARAM');
PARM  = reshape(x,Param.nMax,Param.nDim);
MINB  = PARM - Param.delta*ones(Param.nMax,Param.nDim);
MAXB  = PARM + Param.delta*ones(Param.nMax,Param.nDim);
NTYPE = int32(cell2mat(p));

% Call mex function to do TLEED calculations
fx = GPStleed_wg(Param.p_dir,Param.dir,Param.rank,PARM,MINB,MAXB,NTYPE);
if fx >= 1.6, fx = Inf; end
return
