function index = validSampleArr(curImage)

[rows columns numberOfColorBands] = size(curImage);

blockSizeR = 224; % Rows in block.
blockSizeC = 224; % Columns in block.

% Figure out the size of each block in rows.
% Most will be blockSizeR but there may be a remainder amount of less than that.
wholeBlockRows = floor(rows / blockSizeR);
blockVectorR = [blockSizeR * ones(1, wholeBlockRows), rem(rows, blockSizeR)];
% Figure out the size of each block in columns.
wholeBlockCols = floor(columns / blockSizeC);
blockVectorC = [blockSizeC * ones(1, wholeBlockCols), rem(columns, blockSizeC)];

% Create the cell array, ca. 
% Each cell (except for the remainder cells at the end of the image)
% in the array contains a blockSizeR by blockSizeC by 3 color array.
% This line is where the image is actually divided up into blocks.
if numberOfColorBands > 1
    % It's a color image.
    ca = mat2cell(curImage, blockVectorR, blockVectorC, numberOfColorBands);
else
    ca = mat2cell(curImage, blockVectorR, blockVectorC);
end
ca = ca(1:end-1,1:end-1);
ca=ca';
ca=ca(:);
index = cellfun(@(x) isSampleMask(x),ca);
end