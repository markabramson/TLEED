%===============================================================================
% tleed_nomadm:  Returns the R-factor of a given structure in the TLEED
%                calculation (specifically for Ni(001)-Li-(5x5), which contains
%                14 inequivalent atoms).  This function is set up for use with
%                the NOMADm optimization software.
% ------------------------------------------------------------------------------
% VARIABLES:
%  fx        = computed r-factor of the given structure (fx >= 1.6: invalid)
%  x         = vector of atom xyz positions
%  p         = cell array of atom identities (1 = Ni, 2 = Li)
%  Param     = structure of parameters set by the Parameter file
%    .nAtoms =   number of atoms (14)
%    .nDim   =   dimension of the atom position variable (3)
%    .p_dir  =   directory where the problem files are located
%  xVar      = nAtoms x nDim matrix containing a reshape of x
%  pVar      = a conversion of p from cell array to numerical array
%===============================================================================
function fx = tleed_nomadm(x,p)

% Process input arguments into Fortran arguments
Param = getappdata(0,'PARAM');
xVar  = reshape(x,Param.nAtoms,Param.nDim);
pVar  = int32(cell2mat(p));

% Call mex function to do TLEED calculations (values of >= 1.6 are invalid)
fx = GPStleed_wg(Param.p_dir, xVar, pVar);
if fx >= 1.6, fx = Inf; end
return
