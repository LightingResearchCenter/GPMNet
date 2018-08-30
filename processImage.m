function [str,score] = processImage(net, path,net2)
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
f = waitbar(0,'Loading Image');
showIntStep = true; % set true to see the results as they are claculated
index = reshape(1:36*24,[36,24]);
figure;
h = axes;
curImage = im2uint8(imread(path));
imshow(curImage);
subSizeX = 224;
subSizeY = 224;
str = "";
for i = 1:numel(index)
    waitbar(i/(numel(index)+1),f,sprintf('Analyizing Image %d out of %d',i, numel(index)));
    [row,col,~] = find(index==i,1,'first');
    rectPosBbox = [((row-1)*subSizeY)+1,((col-1)*subSizeX)+1,subSizeY-1,subSizeX-1];
    if showIntStep
        rectangle(h,'Position', rectPosBbox); %#ok<UNRCH>
    end
    CurSubImage = imcrop(curImage,rectPosBbox);
    drawnow;
    % test if the image contains a sample
    [isSample, ~ ] = isSampleMask(CurSubImage);
    if isSample == false
        choice = "0";
        score{i} = 1;
    else
        [pred,score{i}] = classify(net,CurSubImage);
        switch lower(char(pred))
            case 'none'
                if nargin == 3
                    choice = "1";
                else
                    choice = "1";
                end
            case 'low'
                choice = "2";
            case 'moderate'
                choice = "3";
            case 'high'
                choice = "4";
            case 'outoffocus'
                choice = "5";
            case 'infection'
                if nargin == 3
                    [pred2,score{i}] = classify(net2,CurSubImage);
                    switch lower(char(pred2))
                        case 'none'
                            choice = "1";
                        case 'low'
                            choice = "2";
                        case 'moderate'
                            choice = "3";
                        case 'high'
                            choice = "4";
                        case 'outoffocus'
                            choice = "5";
                        otherwise
                            warn('Image returned a classification not listed above');
                            keyboard
                    end
                else
                    choice = "6";
                end
            otherwise
                warn('Image returned a classification not listed above');
                keyboard
        end
    end
    str = strcat(str,choice);
    
    [row,col,~] = find(index<=strlength(str));
    if ~isempty(row) && showIntStep
        p1 = ((row-1)*subSizeY)+1;
        p2 = ((col-1)*subSizeX)+1;
        p4 = ones(size(p1))*subSizeX-1;
        p3 = ones(size(p1))*subSizeY-1;
        
        points = bbox2points([p1,p2,p3,p4]);
        points = permute(points,[2,1,3]);
        vert = reshape(points,[2,numel(points)/2])';
        ind = 1:length(vert);
        ind = reshape(ind,[4,length(ind)/4])';
        textLoc = squeeze(mean(points(:,[1,3],:),2))';
        textLab = cellfun(@(x) sprintf('%0.2g',max(x)),score,'UniformOutput',false);
        exp = {'0','1','2','3','4','5'};
        rep = {'k','b','g','y','r','c'};
        c = regexprep(char(str),exp,rep);
        color = c(:);
        if exist('p','var')&&~isempty(p)
            delete(p{1});
            delete(p{2});
            delete(p{3});
            delete(p{4});
            delete(p{5});
            delete(p{6});
        end
        p{1} = patch(h,'Faces',ind(color=='k',:),'vertices',vert,'FaceColor','k','FaceAlpha',.2);
        p{2} = patch(h,'Faces',ind(color=='b',:),'vertices',vert,'FaceColor','b','FaceAlpha',.2);
        p{3} = patch(h,'Faces',ind(color=='r',:),'vertices',vert,'FaceColor','r','FaceAlpha',.2);
        p{4} = patch(h,'Faces',ind(color=='g',:),'vertices',vert,'FaceColor','g','FaceAlpha',.2);
        p{5} = patch(h,'Faces',ind(color=='y',:),'vertices',vert,'FaceColor','y','FaceAlpha',.2);
        p{6} = patch(h,'Faces',ind(color=='c',:),'vertices',vert,'FaceColor','c','FaceAlpha',.2);
        if strlength(str) == 1
            t = text(h,textLoc(:,1),textLoc(:,2),textLab,'HorizontalAlignment','center');
        else
            t(end+1) = text(h,textLoc(end,1),textLoc(end,2),textLab(end),'HorizontalAlignment','center');
        end
    end
end

waitbar(i+1/(numel(index)+1),f,'Plotting Results');
[row,col,~] = find(index<=strlength(str));
if ~isempty(row)
    p1 = ((row-1)*subSizeY)+1;
    p2 = ((col-1)*subSizeX)+1;
    p4 = ones(size(p1))*subSizeX-1;
    p3 = ones(size(p1))*subSizeY-1;
    
    points = bbox2points([p1,p2,p3,p4]);
    points = permute(points,[2,1,3]);
    vert = reshape(points,[2,numel(points)/2])';
    ind = 1:length(vert);
    ind = reshape(ind,[4,length(ind)/4])';
    textLoc = squeeze(mean(points(:,[1,3],:),2))';
    textLab = cellfun(@(x) sprintf('%0.2g',max(x)),score,'UniformOutput',false);
    exp = {'0','1','2','3','4','5','6'};
    rep = {'k','b','g','y','r','c','g'};
    c = regexprep(char(str),exp,rep);
    color = c(:);
    if exist('p','var')&&~isempty(p)
        delete(p{1});
        delete(p{2});
        delete(p{3});
        delete(p{4});
        delete(p{5});
        delete(p{6});
        delete(t);
    end
    patch(h,'Faces',ind(color=='k',:),'vertices',vert,'FaceColor','k','FaceAlpha',.2);
    patch(h,'Faces',ind(color=='b',:),'vertices',vert,'FaceColor','b','FaceAlpha',.2);
    patch(h,'Faces',ind(color=='r',:),'vertices',vert,'FaceColor','r','FaceAlpha',.2);
    patch(h,'Faces',ind(color=='g',:),'vertices',vert,'FaceColor','g','FaceAlpha',.2);
    patch(h,'Faces',ind(color=='y',:),'vertices',vert,'FaceColor','y','FaceAlpha',.2);
    patch(h,'Faces',ind(color=='c',:),'vertices',vert,'FaceColor','c','FaceAlpha',.2);
    text(h,textLoc(:,1),textLoc(:,2),textLab,'HorizontalAlignment','center');
end
delete(f);
end