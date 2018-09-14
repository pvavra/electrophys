function output = ConvertToNumber(inputString)
% converts `inputString` into a number if possible, otherwise returns the
% original string

% check whether only white-space or digits present in input string
indices = regexp(inputString ,'[\s\d]'); % return all indices of digits/whitespace
toConvert = isequal((1:length(inputString)),indices);

if toConvert
    output = str2num(inputString);
else
    output = inputString;
end

end