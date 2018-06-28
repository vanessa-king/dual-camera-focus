function [x,y,intensity] = findROI(data, colour, filePath, threshold, emitterRadius, exclusionRadius, backgroundRadius, clearance)
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

%Now we want to remove points outside of our clearance. 
outlierIndex = [];

%For all ROIs...
for index = 1:size(x)
    
    %If the x value is less than or equal to clearance
    if x(index) <= clearance
        %record index
        outlierIndex = [outlierIndex, index];
        
    %If the x value is greater than or equal to width-clearance
    elseif x(index) >= (imSz(2)-clearance)
        %record index
        outlierIndex = [outlierIndex, index];
  
    %If the y value is less than or equal to clearance
    elseif y(index) <= clearance
        %record index
        outlierIndex = [outlierIndex, index];
        
    %If the y value is greater than or equal to width-clearance
    elseif y(index) >= (imSz(1)-clearance)
        %record index
        outlierIndex = [outlierIndex, index];
        
    %If the x value is within the clearance.
    else %we do nothing
    end
end

%We now have a list of all points outside the clearance. Now we can delete
%them.
for i = 1:size(outlierIndex)
    %Delete ROI
    x(index) = [];
    y(index) = [];
    intensity(index) = [];
end


outputTable = table(x,y,intensity);
%write the data
writetable(outputTable,filePath+colour+'_features.txt');  

end
