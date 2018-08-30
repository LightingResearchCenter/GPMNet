function dataSummary = summarizeData(data,thresh)
names = unique(data.File);
dataSummary = table('Size',[numel(names),6],'VariableTypes',{'cell','double','double','double','double','double'},'VariableNames',{'file','infectedPercent','NumSample','avgScore','numGTThresh','numLTThresh'});
dataSummary.file = names;
if nargin ==1
    thresh = 0.5;
end
for i = 1:numel(names)
    tempData = data(contains(data.File, names{i}),:);
    dataSummary.infectedPercent(i) = sum(tempData.Category == 'Infection')/height(tempData);
    dataSummary.NumSample(i) =sum(tempData.Category ~= 'NotASample');
    dataSummary.avgScore(i) = mean(tempData.Score);
    dataSummary.numGTThresh(i) = sum(tempData.Score>=thresh);
    dataSummary.numLTThresh(i) = sum(tempData.Score<thresh);
end
end