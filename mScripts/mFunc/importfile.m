function importfile(fileToRead1,varNames)
%IMPORTFILE(FILETOREAD1)
%  Imports data from the specified file
%  FILETOREAD1:  file to read

%  Auto-generated by MATLAB on 15-Aug-2020 20:59:11

% Import the file
newData1 = load('-mat', fileToRead1);

% Create new variables in the base workspace from those fields.
if(nargin ==1)
    vars = fieldnames(newData1);
else
    vars = varNames;
end
for i = 1:length(varNames)
    assignin('base', vars{i}, newData1.(vars{i}));
end
