function y = evaluateFocusScript(gThreshold,rThreshold,emissionRadius,exclusionRadius,backgroundRadius,clearance,refSide)

%This is to call the restoreRed and evaluateFocus functions as well as
%Focus.ijm and Split.ijm

import focusScripts.*;

%Here we open the file, and get its the name and path.
[file,path] = uigetfile('*.tif');
originalImage = imread(fullfile(path, file));

%Before we run any functions, we need to first split this image into the
%green and red sides. This is done in ImageJ because ImageJ retains the
%photo brightness, which is needed later.
%Add path needs to be where the Fiji app is on the computer.
%Example: 'C:\Users\2ColorTIRF\Downloads\fiji-win64\Fiji.app\scripts'
addpath '/Applications/Fiji.app/scripts'
%open ImageJ
ImageJ;
currentDirectory = pwd;
%open our original image in an imagej window.
image = ij.IJ.openImage(fullfile(path,file));
image.show();
%Imports then runs the imagej macro 
ij.IJ.run("Install...", "install="+currentDirectory+"/Split.ijm");
ij.IJ.run("Split");

%Now we align the red image. This is done using the restoreRed function
%which uses the Matlab 'estimateGeometricTransform' function.
disp("Path");
disp(path);
disp("Green Threshold");
disp(gThreshold);
disp("Red Threshold");
disp(rThreshold);
restoreRed(path,gThreshold,rThreshold);

%Next we want to find ROIs and intensities using the green image and the
%This is done using the findROI function.
left = imread(strcat(path,'Left.png'));
right = imread(strcat(path,'restored.png'));
[leftX,leftY,leftI]=findROI(left,"Left",path,gThreshold,emissionRadius,exclusionRadius,backgroundRadius);
[rightX,rightY,rightI]=findROI(right,"Right",path,gThreshold,emissionRadius,exclusionRadius,backgroundRadius);

%Now we evaluate the tilt of the focuses.
evaluateFocus(leftX,leftY,leftI,rightX,rightY,rightI);
%and we're done!
end
