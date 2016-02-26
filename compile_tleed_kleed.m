%===============================================================================
% compile_tleed_kleed:  Compile/link TLEED and KLEED files into mex executables.
% ------------------------------------------------------------------------------
% VARIABLES:
%   fileString = cell array of strings containing names of files to be compiled
%     .kleed   =   filenames for KLEED executable
%     .tleed   =   filenames for TLEED executable
%   code       = name of executable (tleed or kleed) in loop
%===============================================================================
function compile_tleed_kleed(varargin)

if nargin > 1, error('Number of input arguments must be 0 or 1.'); end
fileString.kleed = {'GPSkleed_wg.f','kleedlibGPS.f','GPSkleed.f', 'kleedGPS.f'};
fileString.tleed = {'GPStleed_wg.f','tleedlibGPS.f','GPStleed1.f','tleed1GPS.f','tleed2GPS.f'};

for code = fieldnames(fileString)'
   if ~nargin || strcmpi(varargin{1},code{1})
      fprintf('\n%s', ['Compiling ',upper(code{1}),' files.']);
      mex('-fortran', '-g', fileString.(code{1}){:});
   end
end
return
