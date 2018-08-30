%% Deep learning neural network just infection

digitDatasetPath = fullfile('C:\Users\MainUser\Pictures\Catagories');
imds2 = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
% Convert lables to '0' and '1'
fullLabel = imds2.Labels;
strgs = cell(length(fullLabel),1);
for loop = 1:length(fullLabel)
    temp = char(fullLabel(loop));
    switch temp
        case 'None'
            strgs(loop) = {'None'};
        case 'High'
            strgs(loop) = {'Infection'};
        case 'Low'
            strgs(loop) = {'Infection'};
        case 'Moderate'
            strgs(loop) = {'Infection'};
        case 'OutOfFocus'
            strgs(loop) = {'None'};
        otherwise
            
    end
end
catLabel = categorical(strgs);
imds2.Labels = catLabel;
% noNum = length(find(numLabel==0))
% yesNum = length(find(numLabel==1))
% End convert labels

T = countEachLabel(imds2)

img = readimage(imds2,1);
[rowNum,colNum,colors] = size(img);

numTrainFiles = .3;
[imdsValidation2,imdsTrain2] = splitEachLabel(imds2,numTrainFiles,'randomize');
% trainCount = countEachLabel(imdsTrain2);
% mincount = min(trainCount.Count);
% [imdsTrain2,~] = splitEachLabel(imdsTrain2,mincount,'randomize');
gNet = googlenet;
lgraph = layerGraph(gNet);
lgraph = removeLayers(lgraph, {'loss3-classifier','prob','output'});

numClasses = numel(categories(imdsTrain2.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);
lgraph = connectLayers(lgraph,'pool5-drop_7x7_s1','fc');

inputSize = lgraph.Layers(1).InputSize;

pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true,...
    'RandYReflection',true);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain2, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation2);
options2 = trainingOptions('sgdm', ...
    'MaxEpochs',8, ...
    'ValidationData',augimdsValidation, ...
    'InitialLearnRate',1e-6, ...
    'ValidationFrequency',15, ...
    'ValidationPatience',20,...
    'Verbose',true, ...
    'Plots','training-progress',...
    'ExecutionEnvironment','auto',...
    'MiniBatchSize',10); % 32

% analyzeNetwork(lgraph);
countEachLabel(imdsTrain2)
countEachLabel(imdsValidation2)
net2 = trainNetwork(augimdsTrain,lgraph,options2);
% 
YPred = classify(net2,imdsValidation2);
YValidation = imdsValidation2.Labels;
% accuracy = sum(YPred == YValidation)/numel(YValidation)

plotconfusion(YValidation,YPred)

% Save network
save('CNN7_08June2018.mat','net2')

%% Deep learning neural network Level of infection

digitDatasetPath = fullfile('C:\Users\MainUser\Pictures\Catagories');
imds2 = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
% Convert lables to '0' and '1'
fullLabel = imds2.Labels;
strgs = cell(length(fullLabel),1);
for loop = 1:length(fullLabel)
    temp = char(fullLabel(loop));
    switch temp
        case 'None'
            strgs(loop) = {'None'};
        case 'High'
            strgs(loop) = {'High'};
        case 'Low'
            strgs(loop) = {'Low'};
        case 'Moderate'
            strgs(loop) = {'Moderate'};
        case 'OutOfFocus'
            strgs(loop) = {'None'};
        otherwise
            
    end
end
catLabel = categorical(strgs);
imds2.Labels = catLabel;
% noNum = length(find(numLabel==0))
% yesNum = length(find(numLabel==1))
% End convert labels

T = countEachLabel(imds2)

img = readimage(imds2,1);
[rowNum,colNum,colors] = size(img);

numTrainFiles = .3;
[imdsValidation2,imdsTrain2] = splitEachLabel(imds2,numTrainFiles,'randomize','Exclude','None');
trainCount = countEachLabel(imdsTrain2);
mincount = min(trainCount.Count);
[imdsTrain2,~] = splitEachLabel(imdsTrain2,mincount,'randomize');
gNet = googlenet;
lgraph = layerGraph(gNet);
lgraph = removeLayers(lgraph, {'loss3-classifier','prob','output'});

numClasses = numel(categories(imdsTrain2.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);
lgraph = connectLayers(lgraph,'pool5-drop_7x7_s1','fc');

layers = lgraph.Layers;
connections = lgraph.Connections;

layers(1:110) = freezeWeights(layers(1:110));
lgraph = createLgraphUsingConnections(layers,connections);

inputSize = lgraph.Layers(1).InputSize;

pixelRange = [-30 30];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true,...
    'RandYReflection',true);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain2, ...
    'DataAugmentation',imageAugmenter);
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation2);
options2 = trainingOptions('sgdm', ...
    'MaxEpochs',8, ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',15, ...
    'ValidationPatience',20,...
    'Verbose',true, ...
    'Plots','training-progress',...
    'ExecutionEnvironment','auto',...
    'MiniBatchSize',10); % 32

% analyzeNetwork(lgraph);
countEachLabel(imdsTrain2)
countEachLabel(imdsValidation2)
net3 = trainNetwork(augimdsTrain,lgraph,options2);
% 
YPred = classify(net3,imdsValidation2);
YValidation = imdsValidation2.Labels;
% accuracy = sum(YPred == YValidation)/numel(YValidation)

plotconfusion(YValidation,YPred)

% Save network
save('CNN8_08June2018.mat','net3')


