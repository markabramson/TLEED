%*******************************************************************************
% kleed_nomadm_N:  User function defining discrete set of neighbors for a
%                  a given vector with categorical variables.
% ------------------------------------------------------------------------------
% VARIABLES:
%   N        = vector of iterates who are neighbors of the input iterate
%   Problem  = structure describing Omega as a function of categorical values
%   Param    = structure of parameters saved for later use
%   iterate  = iterate for whom discrete neighbor point will be found
%     .x     =   vector of continuous variable values
%     .p     =   cell array of categorical variable values
%   plist    = cell array of lists of allowed values for each .p variable
%   delta    = mesh size parameter (used to make sure neighbors stay on mesh)
%   neighbor = an element of the vector of iterates N
%   nt       = a matrix of random selections of categorical values
%*******************************************************************************
function N = kleed_nomadm_N(Problem,iterate,plist,delta)  %#ok

% Param = getappdata(0,'PARAM');
%Mesh = inline('delta*round(x/delta)','x','delta');

Nump = length(iterate.p);
N = [];

% Include neighbors in which 1 atom changes its identity
for k = 1:Nump
   for j = 1:length(plist{k})
      if iterate.p{k} ~= plist{k}{j}
         neighbor.x = iterate.x;
         neighbor.p = iterate.p;
         neighbor.p{k} = plist{k}{j};
         N = [N, neighbor];  %#ok
      end
   end
end

% Include random neighbors without changing .x 
neighbor.x = iterate.x;
% nt = mod(floor(rand(Nump*10,Nump)*10),2) + 1;
nt = mod(floor(rand(Nump,Nump)*10),2) + 1;
%for II=1:Nump*10
for j = 1:Nump
   for k = 1:Nump
       neighbor.p{k} = nt(j,k);
   end
   N = [N, neighbor];  %#ok
end

%%flip all identities
%for k = 1:Nump
%   for j = 1:length(plist{k})
%      if iterate.p{k} ~= plist{k}{j}
%         neighbor.p{k} = plist{k}{j};
%      end
%   end
%end
%neighbor.x=iterate.x;
%N = [N neighbor];

%%in favor of {1 1 1 ... 1 2 2 2 ...2}
%y=floor(rand(1,14)*10);
%ind=mod(sum(y),10);
%for i=1:ind
%       neighbor.p{i}=1;
%end
%for i=1+ind:Nump
%       neighbor.p{i}=2;
%end
%neighbor.x=iterate.x;
%N = [N neighbor];
%
% Include neighbors in which 2 atoms change their identities
%for k = 1:Nump-1
%	for l = k+1:Nump
%   		for j = 1:length(plist{k})
%      			if iterate.p{k} ~= plist{k}{j}  
%         			neighbor.x = iterate.x;
%         			neighbor.p = iterate.p;
%         			neighbor.p{k} = plist{k}{j};
%				for i=1:length(plist{l})
%                        		if iterate.p{l} ~= plist{l}{i}    
%                                		neighbor.p{l} = plist{l}{i};
%         					N = [N neighbor];
%					end
%				end
%      			end
%   		end
%	end
%end
