function y = evaluateFocus(greenX,greenY,greenI,redX,redY,redI)
%MATLAB script to follow Focus.ijm
%Purpose is to:
% 1. correlate the points between channels
% 2. compute intensity ratio and output a graph.

%Step 1

%Now we want to find the red point closest to each green point.
%It is assumed that there are more points in green than red. First let's
%check this assumption:
if length(greenX)<length(redX)
    disp("Warning. Because of current threshold values, the red image has more points than the green image.");
end

distance = 0.0;
best = 100.0;
bestIndex = 0;
correlation = zeros(1,length(redX));

%for every point in red...
for i = 1:length(redX)
    %compare to every point in green...
    for j = 1:length(greenX)
        %compute the distance between the points...
        distance = sqrt((greenX(j)-redX(i))^2+(greenY(j)-redY(i))^2);
        %if this is the shortest distance found so far, save it...
        if distance < best
            best = distance;
            bestIndex = j;
        end
    end
    %at this point, we have found the closest red point.
    %the closest point is the "best index"th red point.
    %want to save this information for the ith green point
    correlation(i) = bestIndex;
    
    %reset our reference variable.
    best = 100.0;
end
%We now have our point correlations described by the correlation matrix


%Step 2

%Using the correlations, we want to compute ratio of intensities between
%correlating points. 

ratio = zeros(1,length(correlation));
j=0;

%for all correlating points...
for i=1:length(correlation)
    %Consider correlation(i)=j, 
    %then the ith point in red correlates to the jth point in green.
    j = correlation(i);
    ratio(i) = greenI(j)/redI(i);
end

%Now that we've computed all the ratios, we need to display them.

%Plot Figure
h = figure;
            
%Plot the 3d scatter plot of ratio over position
plot3(redX,redY, ratio, '.r',...
'MarkerSize',10);   
hold on
               
%Create horizontal plane as reference.
%First find min and max for plane to sit
meshMin = [min(redX),min(redY)];
meshMax = [max(redX),max(redY)];
%make 2d grid. Note that unfortunately it has to be square
[X,Y] = meshgrid(min(meshMin):50:max(meshMax));
%set Z value to constant at average ratio value
Z = 0.*X + 0.*Y + sum(ratio)/length(ratio);
%plot the plane.
surf(X,Y,Z);
hold on

%Create x and y lines of best fit for visual guidance.

%Compute average x and y values
avgX = sum(redX)/length(redX);
avgXMat = zeros(1,length(redX));
for i=1:length(avgXMat)
    avgXMat(i)=avgX;
end

avgY = sum(redY)/length(redY);
avgYMat = zeros(length(redY),1);
for i=1:length(avgYMat)
    avgYMat(i)=avgY;
end

%Turn ratio from a row vector to a column vector
ratio = ratio';

%First: linear regression for x,z.
fitXZ = polyfit(redX,ratio,1);
fitXValues = polyval(fitXZ,redX);
plot3(redX, avgYMat, fitXValues,'-k',...
    'LineWidth',5);   
hold on


%Second: linear regression for y,z.
fitYZ = polyfit(redY,ratio,1);
fitYValues = polyval(fitYZ,redY);
plot3(avgXMat, redY, fitYValues,'-k',...
    'LineWidth',5);

legend('Ratio','Green channel (ref)','Red channel tilt','Location','northeast');
title('Green:Red Intensity Ratio.');
hold off
rotate3d on;


end
