function y = evaluateFocusScript(name,division,gThreshold,rThreshold,emissionRadius,exclusionRadius,backgroundRadius,clearance,refSide)

%This is to call the restoreRed and evaluateFocus functions as well as
%Focus.ijm and Split.ijm
import focusScripts.*;

%Here we open the file that we saved from MM.
firstPath = strcat(name,'\');
path = strcat('C:\Users\2ColorTIRF\Desktop\',firstPath);
file = 'img_channel000_position000_time000000000_z000.tif';

originalImage = imread(fullfile(path,file),'tif');
disp("Step 1/6: Code started");

%Before we run any functions, we need to first split this image into the
%green and red sides. 
splitImage(originalImage, path, division, refSide);
currentDirectory = pwd;
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
