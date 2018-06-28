function y = evaluateFocusScript(name,division,gThreshold,rThreshold,emissionRadius,exclusionRadius,backgroundRadius,clearance,refSide)

%This is to call the restoreRed and evaluateFocus functions as well as
%Focus.ijm and Split.ijm

import focusScripts.*;

%To be developed later, this is the desired name of the data folder.
disp("Working on "+name);

%Here we open the file, and get its the name and path.
[file,path] = uigetfile('*.tif');
originalImage = imread(fullfile(path, file));
disp("Step 1/6: Image opened");

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
ij.IJ.run("Split", "division="+division+" green="+refSide);
disp("Step 2/6: Channels split");

%Now we align the red image. This is done using the restoreRed function
%which uses the Matlab 'estimateGeometricTransform' function.
restoreRed(path,gThreshold,rThreshold);
disp("Step 3/6: Red image transformed");

%Next we want to find ROIs and intensities using the green image and the
%This is done using the findROI function.
green = imread(strcat(path,'Green.png'));
red = imread(strcat(path,'Restored.png'));
[greenX,greenY,greenI]=findROI(green,"Green",path,gThreshold,emissionRadius,exclusionRadius,backgroundRadius,clearance);
disp("Step 4/6: Green beads found");
[redX,redY,redI]=findROI(red,"Red",path,gThreshold,emissionRadius,exclusionRadius,backgroundRadius,clearance);
disp("Step 5/6: Red beads found");

%Now we evaluate the tilt of the focuses.
evaluateFocus(greenX,greenY,greenI,redX,redY,redI);
disp("Step 6/6: Tilt evaluated");
%and we're done!
disp("Script complete.");
end
