
clear all
clc
addpath 'raw dataset path'

load('rpmSpoofing.mat')
load('gearSpoofing.mat')
load('fuzzyAttack.mat')
load('dosAttack.mat')
load('normalRunData.mat')
IDs = unique(normalRunData.id);



trainSize=1;
canDataPayload = 8;
name="merge";

% sort all data based on time
temp1 = dosAttack(1:floor(size(dosAttack,1)*trainSize),:);
temp1 = sortrows(temp1,'timeStamp','ascend');

temp2 = fuzzyAttack(1:floor(size(fuzzyAttack,1)*trainSize),:);
temp2 = sortrows(temp2,'timeStamp','ascend');

temp3 = rpmSpoofing(1:floor(size(rpmSpoofing,1)*trainSize),:);
temp3 = sortrows(temp3,'timeStamp','ascend');

temp4 = gearSpoofing(1:floor(size(gearSpoofing,1)*trainSize),:);
temp4 = sortrows(temp4,'timeStamp','ascend');

% ofset time to zero
temp1.timeStamp=temp1.timeStamp-temp1.timeStamp(1);
temp2.timeStamp=temp2.timeStamp-temp2.timeStamp(1);
temp3.timeStamp=temp3.timeStamp-temp3.timeStamp(1);
temp4.timeStamp=temp4.timeStamp-temp4.timeStamp(1);

rawDataFull = vertcat( temp1,temp2 ,temp3,temp4);

clear normalRunData dosAttack fuzzyAttack rpmSpoofing gearSpoofing temp1 temp2 temp3 temp4


for i=1:size(IDs,1)

    tempData = rawDataFull( rawDataFull.id == string(IDs(i)),:);         
    tempData = sortrows(tempData,'timeStamp','ascend');
    
    if isempty(tempData) % prevent error if there is no messages for string(IDs(i))
        string(IDs(i))
        continue
    end

    totalSampleSize=floor(size(tempData,1));
    
    counter=0;

    % get CAN payload
    for indexSampleSize=1:totalSampleSize
        flag=5; % 5 is random number to see errror
        counter=counter +1;
        % for variable size dlc
        startPosition = 4; % start position of first data byte
        DLC = tempData{counter,"dlc"}; % dlc
        endPosition = startPosition + DLC - 1;
        flagPosition = DLC + startPosition;     % flagPosition= 12; %for normalRunData

        inputMatrix (indexSampleSize,1:DLC)=table2array(tempData(counter,startPosition:endPosition)); 

        if DLC<8 % to prevent missing string conversion during hex conversion
            inputMatrix (indexSampleSize,DLC+1:canDataPayload) = "0";
        end

        if tempData{counter,flagPosition}=="T"   % data is variable size, get the flag position with dlc size
            flag=1;
        elseif tempData{counter,flagPosition}=="R"
            flag=0;
        end
        labels(indexSampleSize)=flag;
    end

    inputMatrix=hex2dec(string(inputMatrix)); % convert to string in case it is categorical
    
    save('path\Ali AI IDS\matlab\ftrain\'+name+"_"+string(IDs(i))+"_"+"ftrain_1x8"+".mat",'inputMatrix','labels','-v7.3')
    clear inputMatrix labels 
    toc
    
end

