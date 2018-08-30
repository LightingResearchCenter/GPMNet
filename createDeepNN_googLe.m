% Deep learning neural network

digitDatasetPath = fullfile('C:\Users\MainUser\Pictures\temporary_MarchDay1\Catagories');
imds2 = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames','ReadFcn',@myReadDatastoreImage);
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
%{
figure(1);
figure(2)
perm = randperm(1000,12);
lab = imds.Labels;
for i = 1:12
    if char(lab(perm(i)))=='0'
        figure(1)
        subplot(3,4,i);
        imshow(imds.Files{perm(i)});
    else
        figure(2)
        subplot(3,4,i);
        imshow(imds.Files{perm(i)});
    end
end    

%}
img = readimage(imds2,1);
[rowNum,colNum,colors] = size(img);

numTrainFiles = 0.70;
[imdsTrain2,imdsValidation2] = splitEachLabel(imds2,numTrainFiles,'randomize');

gNet2 = googlenet;
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

analyzeNetwork(lgraph);

countEachLabel(imdsTrain2)
countEachLabel(imdsValidation2)
net2 = trainNetwork(augimdsTrain,lgraph,options2);
% 
YPred = classify(net2,imdsValidation2);
YValidation = imdsValidation2.Labels;
% accuracy = sum(YPred == YValidation)/numel(YValidation)

plotconfusion(YValidation,YPred)


save('CNN7_08June2018.mat','net2')

%{
Saved network configurations
Resulting accuracy = 78.1%
layers2 = [
    imageInputLayer([rowNum colNum colors])

    convolution2dLayer(7,36,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2)
    
    convolution2dLayer(19,64,'Padding',9)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(7,'Stride',5)
    
    convolution2dLayer(5,24,'Padding',4)
    batchNormalizationLayer
    reluLayer
        
    maxPooling2dLayer(3,'Stride',2)
    %
    convolution2dLayer(3,12,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    %
    fullyConnectedLayer(64)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

Saved network configurations
Resulting accuracy = 71.38%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(17,20,'Padding',8)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(9,8,'Padding',4)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,8,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% ****************************************************
Resulting accuracy = 74.3%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(11,40,'Padding',5)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(4,'Stride',4)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',3)
    
    convolution2dLayer(5,30,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',3)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% ******************************************************
Resulting accuracy = 74.6%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(7,60,'Padding',3)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',3)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',3)
    
    convolution2dLayer(5,30,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% ****************************************************
Resulting accuracy 74.6%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(9,60,'Padding',4)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',3)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',3)
    
    convolution2dLayer(5,30,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% Resulting accuracy 74.3%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% *************************************************
Resulting accuracy 76.8%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(13,60,'Padding',6)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(5,'Stride',5)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(5,30,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,6,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% ***********************************************************
Resulting accuracy 80.7%
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(5,16,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(5,16,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(19,50,'Padding',9)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(7,'Stride',7)
    
    convolution2dLayer(3,7,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];
% **********************************************************
Resulting accuracy 81.7% larger dataset
layers = [
    imageInputLayer([rowNum colNum 1])
    
    convolution2dLayer(19,48,'Padding',9)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(7,'Stride',7)
    
    convolution2dLayer(5,16,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
        
    convolution2dLayer(7,24,'Padding',3)
    batchNormalizationLayer
    reluLayer
        
    maxPooling2dLayer(3,'Stride',3)
    %
    convolution2dLayer(3,7,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    %
    fullyConnectedLayer(256)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% ***********************************************************
Resulting accuracy 81.3% larger dataset
layers = [
    imageInputLayer([rowNum colNum 1])

    convolution2dLayer(19,64,'Padding',9)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(7,'Stride',7)
    
    convolution2dLayer(5,128,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
        
    convolution2dLayer(7,24,'Padding',3)
    batchNormalizationLayer
    reluLayer
        
    maxPooling2dLayer(3,'Stride',3)
    %
    convolution2dLayer(3,7,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    %
    fullyConnectedLayer(64)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% ***********************************************************
Resulting accuracy 81.5% larger dataset
layers = [
    imageInputLayer([rowNum colNum 1])

    convolution2dLayer(15,72,'Padding',7)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(7,'Stride',5)
    
    convolution2dLayer(7,36,'Padding',2)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2)
    
    convolution2dLayer(5,24,'Padding',4)
    batchNormalizationLayer
    reluLayer
        
    maxPooling2dLayer(3,'Stride',2)
    %
    convolution2dLayer(3,12,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    %
    fullyConnectedLayer(64)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];
%}

