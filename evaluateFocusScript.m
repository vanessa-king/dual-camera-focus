%This is to call the restoreRed and evaluateFocus functions as well as 
%Focus.ijm and Split.ijm.

import focusScripts.*

%Here we open the open, and get its the name and path.
[file,path] = uigetfile('*.tif');
originalImage = imread(fullfile(path, file));
%Before we run any functions, we need to first split this image into the
%green and red sides. This is done in ImageJ because ImageJ retains the
%photo brightness, which is needed later.


%Add path needs to be where the Fiji app is on the computer.
%Example: 'C:\Users\2ColorTIRF\Downloads\fiji-win64\Fiji.app\scripts'
addpath '/Applications/Fiji.app/scripts'
%opens ImageJ
ImageJ;
currentDirectory = pwd;
%open our original image.
impG = ij.IJ.openImage(fullfile(path,file));
impG.show();
%Imports then runs the imagej macro 
ij.IJ.run("Install...", "install="+currentDirectory+"/Split.ijm");
ij.IJ.run("Split");

%Now we align the red image. This is done using the restoreRed function.
restoreRed(path);

%Next we want to find ROIs and intensities using the green image and the
%restored red image.
impG = ij.IJ.openImage(strcat(path,'restored.png'));
impG.show();
%Imports then runs the imagej macro to detect ROIs and intensities.
ij.IJ.run("Install...", "install="+currentDirectory+"/Focus.ijm");
ij.IJ.run("Focus");

%Now we evaluate the tilt of the focuses.
evaluateFocus(path);
%and we're done!
