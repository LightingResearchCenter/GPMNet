function ColoredImage = plotImageLables(folder,tableData)
% folder =  path to the image files found in the table tableData
% tableData = table genereated by the ImageSortingApp and saved in Data.mat

index = reshape(1:36*24,[36,24]);
newTableData = table;

%     newTableData = [newTableData;convertImageTable(char(tableData.ImageName(i)),char(tableData.SubImgCode(i)))];

% figure;
% h = axes;
CurImage = imread(fullfile(folder,char(tableData.File(1))));
% imshow(CurImage)
subSizeX = 224;
subSizeY = 224;

[row,col,~] = find(index<=height(tableData));
if ~isempty(row)
    p1 = ((row-1)*subSizeY)+1;
    p2 = ((col-1)*subSizeX)+1;
    p4 = ones(size(p1))*subSizeX-1;
    p3 = ones(size(p1))*subSizeY-1;
    colorCell = repmat({'black'},[size(p1),1]);
    colorCell(tableData.Category=='NotASample') = {'black'};
    colorCell(tableData.Category=='None') = {'red'};
    colorCell(tableData.Category=='Infection') = {'green'};
    ColoredImage = insertShape(CurImage,'FilledRectangle',[p1,p2,p3,p4],'Color',colorCell,'Opacity',0.3);
%     imshow(ColoredImage);
%     points = bbox2points([p1,p2,p3,p4]);
%     points = permute(points,[2,1,3]);
%     vert = reshape(points,[2,numel(points)/2])';
%     ind = 1:length(vert);
%     ind = reshape(ind,[4,length(ind)/4])';
%     
%     %     exp = {'0','1','2','3','4','5'};
%     %     rep = {'k','b','g','y','r','c'};
%     %     c = regexprep(char(tableData.SubImgCode(i)),exp,rep);
%     %     color = c(:);
%     
%     patch(h,'Faces',ind(tableData.Category=='NotASample',:),'vertices',vert,'FaceColor','k','FaceAlpha',.3)
%     patch(h,'Faces',ind(tableData.Category=='None',:),'vertices',vert,'FaceColor','r','FaceAlpha',.3)
%     patch(h,'Faces',ind(tableData.Category=='Infection',:),'vertices',vert,'FaceColor','g','FaceAlpha',.3)
    
    
end