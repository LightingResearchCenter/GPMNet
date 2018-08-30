function tableout = importSummaryFile(workbookFile,sheetName,startRow,endRow)
%importSummaryFile Import data from a spreadsheet
%   DATA = importSummaryFile(FILE) reads data from the first worksheet in the
%   Microsoft Excel spreadsheet file named FILE and returns the data as a
%   table.
%
%   DATA = importSummaryFile(FILE,SHEET) reads from the specified worksheet.
%
%   DATA = importSummaryFile(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   SubImageS2 = importSummaryFile('SubImage.xlsx','GoogLe13',2,5185);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2018/07/24 15:05:40

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    endRow = 5185;
end

%% Import the data
[~, ~, raw] = xlsread(workbookFile, sheetName, sprintf('A%d:E%d',startRow(1),endRow(1)));
for block=2:length(startRow)
    [~, ~, tmpRawBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:E%d',startRow(block),endRow(block)));
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
stringVectors = string(raw(:,[1,2]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4,5]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

%% Create table
tableout = table;

%% Allocate imported array to column variable names
tableout.File = stringVectors(:,1);
tableout.Category = categorical(stringVectors(:,2),{'Uncategorized','NotASample','OutOfFocus','None','Low','Moderate','High','Infection'},'Ordinal',true);
tableout.Score = data(:,1);
tableout.row = data(:,2);
tableout.col = data(:,3);
