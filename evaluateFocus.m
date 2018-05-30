function y = evaluateFocus(filePath)
%MATLAB script to follow Focus.ijm
%Purpose is to:
% 1. open the csv files outputted by Focus.ijm and put into matrix
% 2. correlate the points between channels
% 3. compute intensity ratio and output a graph.

%Step 1

%open positions csv
%read only the section of the csv thats needed

strFilePath = string(filePath);

%Left ROI positions
fileID = fopen(strFilePath+'LeftROIpositions.csv', 'r' ); 
leftPosMatrix = textscan( fileID, '%s %s %s %f %f %*[^\n]', 'Delimiter',',','Headerlines',1);
%Here we load x,y data into two arrays.
leftPosX = leftPosMatrix{4};
leftPosY = leftPosMatrix{5};
fclose( fileID ); 

%Right ROI positions
fileID = fopen( strFilePath+'RightROIpositions.csv', 'r' ); 
rightPosMatrix = textscan( fileID, '%s %s %s %f %f %*[^\n]', 'Delimiter',',','Headerlines',1);
%Here we load x,y data into two arrays.
rightPosX = rightPosMatrix{4};
rightPosY = rightPosMatrix{5};
fclose( fileID ); 


%open intensities csv
%read only the section of the csv thats needed

%Left Intensities
fileID = fopen( strFilePath+'LeftIntensities.csv', 'r' ); 
leftIntensitiesMatrix = textscan( fileID, '%s %s %f %*[^\n]', 'Delimiter',',','Headerlines',1);
%Here we load the data into an arrays.
leftInt = leftIntensitiesMatrix{3};
fclose( fileID ); 

%Right Intensities
fileID = fopen( strFilePath+'RightIntensities.csv', 'r' ); 
rightIntensitiesMatrix = textscan( fileID, '%s %s %f %*[^\n]', 'Delimiter',',','Headerlines',1);
%Here we load the data into an arrays.
rightInt = rightIntensitiesMatrix{3};
fclose( fileID ); 


%Step 2

%Now we want to find the Right point closest to each Left point.
%It is assumed that there are more points in left than right. First let's
%check this assumption:
if length(leftPosX)<length(rightPosX)
    disp("The threshold on the right image is too low! Right image has more points than left.");
end

distance = 0.0;
best = 100.0;
bestIndex = 0;
correlation = zeros(1,length(rightPosX));

%for every point in Right...
for i = 1:length(rightPosX)
    %compare to every point in Left...
    for j = 1:length(leftPosX)
        %compute the distance between the points...
        distance = sqrt((leftPosX(j)-rightPosX(i))^2+(leftPosY(j)-rightPosY(i))^2);
        %if this is the shortest distance found so far, save it...
        if distance < best
            best = distance;
            bestIndex = j;
        end
    end
    %at this point, we have found the closest right point.
    %the closest point is the "best index"th right point.
    %want to save this information for the ith left point
    correlation(i) = bestIndex;
    
    %reset our reference variable.
    best = 100.0;
end
%We now have our point correlations described by the correlation matrix


%Step 3

%Using the correlations, we want to compute ratio of intensities between
%correlating points. 

ratio = zeros(1,length(correlation));
j=0;

%for all correlating points...
for i=1:length(correlation)
    %Consider correlation(i)=j, 
    %then the ith point in Right correlates to the jth point in Left.
    j = correlation(i);
    ratio(i) = leftInt(j)/rightInt(i);
end

%Now that we've computed all the ratios, we need to display them.

%Plot Figure
h = figure;
            
%Plot the 3d scatter plot of ratio over position
plot3(rightPosX,rightPosY, ratio, '.r',...
'MarkerSize',10);   
hold on
               
%Create horizontal plane as reference.
%First find min and max for plane to sit
meshMin = [min(rightPosX),min(rightPosY)];
meshMax = [max(rightPosX),max(rightPosY)];
%make 2d grid. Note that unfortunately it has to be square
[X,Y] = meshgrid(min(meshMin):50:max(meshMax));
%set Z value to constant at average ratio value
Z = 0.*X + 0.*Y + sum(ratio)/length(ratio);
%plot the plane.
surf(X,Y,Z);
hold on

%Create x and y lines of best fit for visual guidance.

%Compute average x and y values
avgX = sum(rightPosX)/length(rightPosX);
avgXMat = zeros(1,length(rightPosX));
for i=1:length(avgXMat)
    avgXMat(i)=avgX;
end

avgY = sum(rightPosY)/length(rightPosY);
avgYMat = zeros(length(rightPosY),1);
for i=1:length(avgYMat)
    avgYMat(i)=avgY;
end

%Turn ratio from a row vector to a column vector
ratio = ratio';

%First: linear regression for x,z.
fitXZ = polyfit(rightPosX,ratio,1);
fitXValues = polyval(fitXZ,rightPosX);
plot3(rightPosX, avgYMat, fitXValues,'-k',...
    'LineWidth',5);   
hold on


%Second: linear regression for y,z.
fitYZ = polyfit(rightPosY,ratio,1);
fitYValues = polyval(fitYZ,rightPosY);
plot3(avgXMat, rightPosY, fitYValues,'-k',...
    'LineWidth',5);

legend('Ratio','Green channel (ref)','Red channel tilt','Location','northeast');
title('Green:Red Intensity Ratio.');
hold off
rotate3d on;


end
