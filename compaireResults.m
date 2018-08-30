%function results = compaireResults(data1,data2,varargin)
%% inputs
data1 = AndrewTableData;
data2 = SuryaTableData;
folder = 'C:\Users\MainUser\Pictures\ComputerVisionTest';
comparisonChar = 'AndrewvsSurya';
% data2.File{4320} = 'Mar2118_130540_200.tiff';
% data1.File{3796} = 'Mar2118_130540_201.tiff';
%% Determine fully analized files
mkdir(fullfile(folder,'comparisons',comparisonChar));
data1 = sortrows(data1,'File','ascend');
data2 = sortrows(data2,'File','ascend');
index = reshape(1:36*24,[36,24]);
files1 = unique(data1.File);
files2 = unique(data2.File);
[diff, ind1, ind2] = setxor(files1,files2);
if ~isempty(ind1)
    data1 = data1(~contains(data1.File,files1(ind1)),:);
end
if ~isempty(ind2)
    data2 = data2(~contains(data2.File,files2(ind2)),:);
end
files = unique(data1.File);
imgCount = zeros(2,numel(files));
for i = 1:numel(files)
    imgCount(1,i)= sum(strcmpi(data1.File,files(i)));
    imgCount(2,i)= sum(strcmpi(data2.File,files(i)));
end
validImages = imgCount(1,:)==imgCount(2,:);
data1 = data1(contains(data1.File,files(validImages)),:);
data2 = data2(contains(data2.File,files(validImages)),:);
%% generate differences table
outputTable = data1;
outputTable.Properties.VariableNames = {'File','Expert1','row','col'};
outputTable.Expert2 = data2.Category;
outputTable = movevars(outputTable, 'Expert2', 'After', 'Expert1');
outputTable.E1vE2 = outputTable.Expert1==outputTable.Expert2;
%% plot Tables
outFiles = unique(outputTable.File);
subSizeX = 224;
subSizeY = 224;
for i = 1:numel(outFiles)
    figure;
    h = axes;
    imshow(fullfile(folder,outFiles{i}));
    testTable = outputTable(contains(outputTable.File,outFiles(i)),:);
    p1 = ((testTable.col-1)*subSizeY)+1;
    p2 = ((testTable.row-1)*subSizeX)+1;
    p4 = ones(size(p1))*subSizeX-1;
    p3 = ones(size(p1))*subSizeY-1;
    
    points = bbox2points([p1,p2,p3,p4]);
    points = permute(points,[2,1,3]);
    vert = reshape(points,[2,numel(points)/2])';
    ind = 1:length(vert);
    ind = reshape(ind,[4,length(ind)/4])';
    
    exp = {'0','1'};
    rep = {'r','g'};
    c = num2str(double(testTable.E1vE2))';
    c = regexprep(c,exp,rep);
    color = c(:);
    
    patch(h,'Faces',ind(color=='r',:),'vertices',vert,'FaceColor','r','FaceAlpha',.3)
    patch(h,'Faces',ind(color=='g',:),'vertices',vert,'FaceColor','g','FaceAlpha',.3)
    FigImage = frame2im(getframe(h));
    fullPath = fullfile(folder,'comparisons',comparisonChar,outFiles{i});
    imwrite(FigImage,fullPath);
end
