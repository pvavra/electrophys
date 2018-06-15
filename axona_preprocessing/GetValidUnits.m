function validUnits = GetValidUnits(nUnits, desiredUnits)
% GetValidUnits checks desiredUnits is a subset of 1:nUnits and handles
% string 'all' as a special case
% 
% Throws a warning if any units were requested which are larger than nUnits
% 
% Input:
%     nUnits         ... Integer. Number of cells that are present in a
%                        Tetrode
%
%     desiredUnits   ... Array/String. If string, should be 'all',
%                        otherwise an integer-array indicating which units
%                        are requested
%
% Output:
%      validUnits    ... returns the subset of desiredUnits which are part
%                        of 1:nUnits; if desiredUnits is 'all', it simply
%                        returns 1:nUnits. 
%



% first check whether desired units are 'all'
if strcmp(desiredUnits, 'all')
    validUnits = 1:nUnits;
   
% otherwise make sure there are no desired units which do not exist (e.g.
% requesting 13, while only 11 units in data)
elseif isnumeric(desiredUnits) && all(ismember(desiredUnits, 1:nUnits))
    validUnits = desiredUnits;

% throw a warning if not all desired units are present
else
    warning([ 'some of the requested units do not exist.\n'...
        'Please ensure that `whichUnits` refers only to existing units\n'...
        'attempting to plot the valid units at least...\n' ]);
    validOnes = ismember(desiredUnits, 1:nUnits);
    validUnits = desiredUnits(validOnes);
end
    
% throw an error if no valid units found
if isempty(validUnits)
        error('no valid units found');
end


end