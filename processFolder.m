function newSortData = processFolder(net, folderPath)
if nargin == 0
    [netPath,folder] = uigetfile();
    if isequal(file,0)
        error('No network was selected.');
    else
        load(fullfile(folder,netPath),'-regexp','^net');
        names = who;
        if any(contains(names,'net2'))
            net = net2;
        else
            error('The network loaded is not named ''net2'', please rename the network.')
        end
    end
    folderPath = uigetdir();
else
    validateattributes(net,{'DAGNetwork'},{'nonempty'});
    validateattributes(folderPath,{'char'},{'scalartext'});
end
files = struct2table(dir(folderPath));
files = files(~files.isdir,:);
newSortData =[];
for i = 1:height(files)
    newSortData = [newSortData;newProcessImage(net,fullfile(files.folder{i},files.name{i}))];
%     [str,score] = processImage(net,fullfile(files.folder{i},files.name{i}));
end
end