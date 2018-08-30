function outTable= convertImageTable(path,str)
%
%
%
%% code part1
c = char(str);
c = c(:);
c = cellstr(c);
exp = {'2'};
rep = {'6'};
c = regexprep(c,exp,rep);
exp = {'0','1','2','3','4','5','6'};
rep = {'NotASample','None','Low','Moderate','High','OutOfFocus','Infection'};
c = regexprep(c,exp,rep);
cCategories = categorical(c,{'Uncategorized','NotASample','OutOfFocus','None','Low','Moderate','High','Infection'},'Ordinal',true);
%% code part 2
index = reshape(1:36*24,[36,24]);
[col,row,~] = find(index<=strlength(str));
file = repmat(path,[strlength(str),1]);
%% output
outTable = table(cellstr(file),cCategories,row,col,'VariableNames',{'File','Category','row','col'});
end