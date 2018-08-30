function [outTable] = newProcessImage(net, path,showIntStep)
% net = neural network that takes a 224x224x3 image and classifies how
% infected the image is, If the result is a binary result, then it will ask
% net2 how infected the sample is.
%
% path = full path to the full image to be classified
%
% net2 = network that specifies how infected a sample is, used if net is a
% binary classification
%
%

if nargin == 2
    showIntStep = false; % set true to see the results as they are claculated
end


indexArr = reshape(1:36*24,[36,24]);

curImage = im2uint8(imread(path));
if showIntStep
    figure;
    h = axes;
    f = waitbar(0,'Loading Image');
    imshow(curImage);
end
subSizeX = 224;
subSizeY = 224;
str = "";
imageSet = [];
newIndex = [];
% for i = 1:numel(index)
%     if showIntStep
%         waitbar(i/(numel(index)+1),f,sprintf('Analyizing Image %d out of %d',i, numel(index)));
%     end
%     [row,col,~] = find(index==i,1,'first');
%     rectPosBbox = [((row-1)*subSizeY)+1,((col-1)*subSizeX)+1,subSizeY-1,subSizeX-1];
%     if showIntStep
%         rectangle(h,'Position', rectPosBbox); %#ok<UNRCH>
%     end
%     CurSubImage = imcrop(curImage,rectPosBbox);
%     drawnow;
%     % test if the image contains a sample
%     [isSample, ~ ] = isSampleMask(CurSubImage);
%     if isSample == false
%     else
%         imageSet = cat(4,imageSet,CurSubImage);
%         newIndex = [newIndex;i];
%     end
% end
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
ca = ca(index);
imarr = reshape(ca,[1 1 1 numel(ca)]);
imageSet = cell2mat(imarr);
if showIntStep
    delete(f);
end
disp('Starting classification!')
tic;
[pred,score] = classify(net,imageSet);
disp('Ending classification');
toc
category = categorical(repelem({'NotASample'},36*24)',{'Uncategorized','NotASample','OutOfFocus','None','Low','Moderate','High','Infection'},{'Uncategorized','NotASample','OutOfFocus','None','Low','Moderate','High','Infection'},'Ordinal',true);
scoreOut =zeros(36*24,1);
scoreOut(index) = score(:,1);
category(index) = cellstr(pred);
[~,filename,fileext] = fileparts(path);
[col,row,~] = find(indexArr<=length(category));
file = repmat([filename,fileext],[length(category),1]);
outTable = table(cellstr(file),category,scoreOut,row,col,'VariableNames',{'File','Category','Score','row','col'});


% [folder,~,~] = fileparts(path);
% plotImageLables(folder,outTable);
end