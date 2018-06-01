function [x,y,intensity] = findROI(data, side, filePath, threshold, emitterRadius, exclusionRadius, backgroundRadius)
%This function is an attempt at using the generateCircles and 
%intensitytrace functions. It will replace Focus.ijm

threshold = threshold*256;
meanImage = data;
imSz = size(data);

% Localize features and keep the positions.
[goodXYKLB, numPoints] = generateCircles(filePath, meanImage, threshold);

numpoints= numPoints/2;

pos = goodXYKLB(1:2:end,1:2);

% Intensity traces are columns.
[ I, B, C ] = intensitytrace( ...
    data, ...
	pos, ...
    emitterRadius, ...
    exclusionRadius, ...
    backgroundRadius );

%Now, C is the 2 column list of positions, I is a row list of intensities
%and B is a row list of backgrounds. 
%Transpose I
intensity = I.' ;
x = C(:,1);
y = C(:,2);

outputTable = table(x,y,intensity);
%write the data
writetable(outputTable,filePath+side+'_features.txt');  

end
