% Immanuel Chu
% CS170
% Project 2
% December 17, 2018

clc;clear;

data = importdata('CS170_SMALLtestdata__100.txt');
% data = importdata('CS170_SMALLtestdata__108.txt'); %6  5  4
% data = importdata('CS170_SMALLtestdata__109.txt'); %7  9  2
% data = importdata('CS170_SMALLtestdata__110.txt'); %6  4  9

% data = importdata('CS170_LARGEtestdata__55.txt'); 
% data = importdata('CS170_LARGEtestdata__108.txt'); %46  26  95
% data = importdata('CS170_LARGEtestdata__109.txt'); %72  19   2
% data = importdata('CS170_LARGEtestdata__110.txt'); %1  66   6

promptIntro = 'Welcome to Immanuel Chu''s Feature Selection Algorithm.';
promptAlg = 'Type the number of the algorithm you want to run.\n    1. Forward Selection\n    2. Backward Elimination\n    3. Immanuel''s Special Algorithm\n\n                          ';

disp(promptIntro);
defAlg = input(promptAlg);
fprintf('\nThis dataset has %d features (not including the class attribute), with %d instances\n\n', size(data,2)-1, size(data,1));
fprintf('Running nearest neighbor with all %d features, using ''''leaving-one-out'''' evaluation, I get an accuracy of %d%% \n\n', size(data,2)-1, size(data,2));
fprintf('Beginning Search\n\n');

if defAlg == 3
    n = 10;
    dataTemp = data;
    idxRows = randsample(1:size(data,1),n);
    delRows = dataTemp(idxRows,:);
    dataTemp(idxRows,:)=[];
    disp('Running on modified Set #1');
    [setOne,accuracy] = feature_search(dataTemp,defAlg);
    disp(['Set #1 Returned features ', mat2str(setOne), ' with accuracy of ', num2str(accuracy*100), '%',]);
    disp('---------------------SET #1 FOUND--------------------');
    disp('-----------------------------------------------------'); 
    disp(' ');
    
    dataTemp = data; 
    idxRows = randsample(1:size(data,1),n);
    delRows = dataTemp(idxRows,:);
    dataTemp(idxRows,:)=[];
    disp('Running on modified Set #2');
    [setTwo,accuracy] = feature_search(dataTemp,defAlg);
    disp(['Set #2 Returned features ', mat2str(setTwo), ' with accuracy of ', num2str(accuracy*100), '%']);
    disp('---------------------SET #2 FOUND--------------------');
    disp('-----------------------------------------------------'); 
    disp(' ');

    dataTemp = data;
    idxRows = randsample(1:size(data,1),n);
    delRows = dataTemp(idxRows,:);
    dataTemp(idxRows,:)=[];
    disp('Running on modified Set #3');
    [setThree,accuracy] = feature_search(dataTemp,defAlg);
    disp(['Set #3 Returned features ', mat2str(setThree), ' with accuracy of ', num2str(accuracy*100), '%']);
    disp('---------------------SET #3 FOUND--------------------');
    disp('-----------------------------------------------------'); 
    disp(' ');

%     
%     setOne
%     setTwo
%     setThree
    features = intersect(intersect(setOne,setTwo,'stable'), (intersect(setOne,setThree,'stable')),'stable');
%     features = sprintf('%.0f,' , features);
%     features = features(1:end-1);
    disp(['Strongest Features in all three modifed sets ', mat2str(features), ' which has an accuracy of ', num2str(accuracy*100), '%']);
    
else
    [features,accuracy] = feature_search(data,defAlg);
    disp(['Finished search!! The best feature subset is, ' mat2str(features), ' which has an accuracy of ', num2str(accuracy*100), '%']);
end

% Functions ---------------------------------------------------------------
function  [set,acc] = feature_search(data,defAlg)
        BESTACC = 0;
        BESTSET = [];
        currentSet = []; % Initialize an empty set
        warning = 0;

    if defAlg == 1
        for i = 1 : size(data,2)-1 
        deletedFeature = [];
        bestAccuracy = 0;

         for k = 1 : size(data,2)-1 
            if isempty(intersect(currentSet,k)) % Only consider adding, if not already added.
                accuracy = crossValidation(data,currentSet,k+1,defAlg);
                combFeat = [currentSet k];
                feat2string = sprintf('%.0f,' , combFeat);
                feat2string = feat2string(1:end-1);
                fprintf('Using feature(s) {%s} accuracy is %.2f%%\n', feat2string, accuracy*100);

                if accuracy > bestAccuracy 
                    bestAccuracy = accuracy;
                    deletedFeature = k;
                    bestFeat = combFeat;
                    bestFeatComb = sprintf('%.0f,' , combFeat);
                    bestFeatComb = bestFeatComb(1:end-1);
                end
            end
         end
            
        if bestAccuracy > BESTACC 
           BESTACC = bestAccuracy;
           BESTSET = bestFeat;
        elseif warning == 0 && bestAccuracy < BESTACC
            fprintf('\n(Warning, Accuracy has decreased! Continuing search in case of local maxima)');
            warning = 1;
        end
        
        accuracySet(i) = bestAccuracy;
        currentSet(i) =  deletedFeature;
        fprintf('\nFeature set {%s} was best, accuracy is %.2f%%\n',bestFeatComb, bestAccuracy*100)
        disp(' '); % DELETE THIS IN FINAL!!!   
        end
        
    elseif defAlg == 2
        currentSet = [1:size(data,2)-1];
        warning = 0;
        for i = 1 : size(data,2)-1 
            bestAccuracy = 0;

            for k = 1 : size(data,2)-1 
                if (intersect(currentSet,k)) % Only consider deleting, if not already deleted.
                    accuracy = crossValidation(data,currentSet,k+1,defAlg);
                    tempSet = currentSet;
                    tempSet(tempSet == k) = [];
                    combFeat = tempSet;

                    feat2string = sprintf('%.0f,' , combFeat);
                    feat2string = feat2string(1:end-1);
                    fprintf('Using feature(s) {%s} accuracy is %.2f%%\n', feat2string, round(accuracy*100));

                    if accuracy > bestAccuracy 
                        bestAccuracy = accuracy;

                        bestFeat = tempSet;
                        bestFeatComb = sprintf('%.0f,' , bestFeat);
                        bestFeatComb = bestFeatComb(1:end-1);
                    end
                end
            end

        if bestAccuracy > BESTACC 
           BESTACC = bestAccuracy;
           BESTSET = bestFeat;
        elseif warning == 0 && bestAccuracy < BESTACC
            fprintf('\n(Warning, Accuracy has decreased! Continuing search in case of local maxima)');
            warning = 1;
        end
        currentSet = bestFeat;
        fprintf('\nFeature set {%s} was best, accuracy is %.2f%%\n',bestFeatComb, round(bestAccuracy*100));
        disp(' '); % DELETE THIS IN FINAL!!!   
        end

    elseif defAlg == 3
        for i = 1 : size(data,2)-1 
        deletedFeature = [];
        bestAccuracy = 0;
        
         for k = 1 : size(data,2)-1 
            if isempty(intersect(currentSet,k)) % Only consider adding, if not already added.
                accuracy = crossValidation(data,currentSet,k+1,defAlg);
                combFeat = [currentSet k];
                feat2string = sprintf('%.0f,' , combFeat);
                feat2string = feat2string(1:end-1);
                fprintf('Using feature(s) {%s} accuracy is %.2f%%\n', feat2string, accuracy*100);

                if accuracy > bestAccuracy 
                    bestAccuracy = accuracy;
                    deletedFeature = k;
                    bestFeat = combFeat;
                    bestFeatComb = sprintf('%.0f,' , combFeat);
                    bestFeatComb = bestFeatComb(1:end-1);
                end
            end
         end
         if bestAccuracy > BESTACC
           BESTACC = bestAccuracy;
           BESTSET = bestFeat;
         elseif warning == 0 && bestAccuracy < BESTACC
            fprintf('\n(Warning, Accuracy has decreased! Continuing search in case of local maxima)');
            warning = 1;
         end
        currentSet = bestFeat;
        accuracySet(i) = bestAccuracy;
        currentSet(i) =  deletedFeature;
        fprintf('\nFeature set {%s} was best, accuracy is %.2f%%\n',bestFeatComb, bestAccuracy*100)
        disp(' '); % DELETE THIS IN FINAL!!!   
        end
    end
    set = BESTSET;
    acc = BESTACC;
    
end

function accuracy = crossValidation(data,currentSet,addFeature,alg)
    counter = 0; 
    currentSet = currentSet + 1;
    if alg == 1
        Z = data( :,[currentSet, addFeature]);
    elseif alg == 2 
        currentSet(currentSet == addFeature) = [];
        Z = data( :,[currentSet]);
    elseif alg == 3
        Z = data( :,[currentSet, addFeature]);
    end
    partitionSize = size(data,1)/5;
    partStart = partitionSize*4;
    partEnd = partStart + partitionSize;
    
%     %Partition 5 out of 5
    trainSet = Z(1:partStart,:);
    trainClass = data(1:partStart,1);
    testSet = Z(partStart + 1:partEnd,:);
    testClass = NN(testSet, trainSet, trainClass); %find and compare to known testClass
    knownTestClass = data(partStart + 1:partEnd,1);
    
    for i=1:length(testClass)
        classOfPos = data(testClass(i,1),1);
        p1 = Z(testClass(i,1),:);
        p2 = knownTestClass(i,:);
        outDist = norm(data(testClass(i,1),:) - knownTestClass(i,:));
        if data(testClass(i,1),1) == knownTestClass(i,1)
            counter = counter + 1;
        end
    end
    accuracy = counter / length(testClass);
end

%K-nn 
function testClass = NN(testSet, trainSet, trainClass)
    for i = 1:size(testSet,1) 
        minDist = 1000;
        minPos = 1000;
        for j = 1:size(trainSet,1) 
            trainX = trainSet(j,:);
            testX = testSet(i,:);
            tempDist = norm(trainX - testX);
            if tempDist < minDist
                minDist = tempDist;
                minPos = j;
            end
        end  
        testClass(i,:) = minPos;
    end
end
% Functions ---------------------------------------------------------------
