function label = mappingInputs(byte_code)
% MAPPINGINPUTS converts the byte-code of an event into a string
% 
% The result of axona_io::read_input_file is a byte-code for each event.
% This function converts this into a string representation which is
% specific to this experiment.
% 
% Input: 
%      byte_code ... Integer, as return by `axona_io::read_input_file`
%
% Output:
%      label     ... String. Label describing the event code, or 
%                    'unknown byte-code' if the event code is unrecognized
% 
% see also:
%   READ_INPUT_FILE, CONVERTINPUT
%


switch byte_code
   
    case 256
        label = 'on: tone';
   
    case 1024
        label = 'on: infrared tracking';
        
    otherwise
        label = 'unknown byte-code';
end


