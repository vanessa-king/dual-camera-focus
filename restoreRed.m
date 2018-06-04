function y = restoreRed(filePath,gThreshold,rThreshold)

%This function uses the estimateGeometricTransform function to align the
%red image with the green image. It then saves the restored image. 

%read the images
gImage = imread(strcat(filePath,'Left.png'));
rImage = imread(strcat(filePath,'Right.png'));

%detect features
%Lower the 'MetricThreshold' variable to detect more features.
%Leave NumOctaves at 1. This determines the size of the features found, and
%it is already at its minimum.
gPoints = detectSURFFeatures(gImage,'MetricThreshold',gThreshold,'NumOctaves',1);
rPoints = detectSURFFeatures(rImage,'MetricThreshold',rThreshold,'NumOctaves',1);

%extract the features
[fg,vptsG] = extractFeatures(gImage,gPoints);
[fr,vptsR] = extractFeatures(rImage,rPoints);

%retrieve the location of matched points
indexPairs = matchFeatures(fg,fr) ;
matchedPointsG = vptsG(indexPairs(:,1));
matchedPointsR = vptsR(indexPairs(:,2));

%Delete outlier points
[tform,inlierPtsDistorted,inlierPtsOriginal] = ...
    estimateGeometricTransform(matchedPointsR,matchedPointsG,...
    'affine');
figure; 

showMatchedFeatures(gImage,rImage,...
    inlierPtsOriginal,inlierPtsDistorted);
title('Matched inlier points');

%Now we want to display the translation and rotation information
instructions = '\fontsize{15}Shift red frame by:';
xForm = {'X pixels:',num2str(tform.T(3,1))};
xstr = strjoin(xForm,' ');
yForm = {'Y pixels:',num2str(tform.T(3,2))};
ystr = strjoin(yForm,' ');
rotForm = {'Angle (deg):',num2str(rad2deg(asin(tform.T(1,2))))};
rotstr = strjoin(rotForm,' ');

messages = {instructions, xstr, ystr, rotstr};
message = strjoin(messages,'\n');

CreateStruct.WindowStyle = 'non-modal';
CreateStruct.Interpreter = 'tex';
info = msgbox(message,CreateStruct);


%Show the red image as it should be "aligned". Set to display as size of
%green image.
outputView = imref2d(size(gImage));
restoredRed = imwarp(rImage,tform,'OutputView',outputView);

%Now we have the "restored" image of the red channel that we want to pass
%to ImageJ to find ROIs. In order to do this, we need to save the image.
imwrite(restoredRed,strcat(filePath,'restored.png'));

end
