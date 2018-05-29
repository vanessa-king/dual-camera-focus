//This macro is to help focus a multi-channel image on the microscope.
//It gets called by the evaluateFocusScript.
rightImage = getImageID();
directory = getInfo("image.directory");
open(directory+File.separator+"Left.png");

//LEFT HAND SIDE
selectWindow("Left.png");
//Now in order to find the points, we need to first turn each image into binary.
run("8-bit");
run("Options...", "iterations=1 count=1 black");
setOption("BlackBackground", true);
run("Make Binary");

//Now we are going to find all the particles.
selectWindow("Left.png");
run("Analyze Particles...", "  show=Outlines exclude add in_situ");

//Now we want to save the positions of all the ROIs as a csv.
roiManager("List");
saveAs("Results", originalDirectory+"LeftROIpositions.csv");

//Close the binary masked images.
selectWindow("Left.png");
close();
//Reopen the original.
open(originalDirectory+"Left.png");
selectWindow("Left.png");

//Measure the intensity of all ROIs.
roiManager("Deselect");
roiManager("Measure");
saveAs("Results", originalDirectory+"LeftIntensities.csv");

//Remove ROIs from left hand side befores starting right hand side
roiManager("Delete");
run("Close");
selectWindow("LeftROIpositions.csv");
run("Close");
selectWindow("Left.png");
close();


//RIGHT HAND SIDE
//Now in order to find the points, we need to first turn each image into binary.
selectWindow("restored.png");
run("8-bit");
run("Options...", "iterations=1 count=1 black");
setOption("BlackBackground", true);
setThreshold(130,215);
run("Convert to Mask");

//Now we are going to find all the particles.
selectWindow("restored.png");
run("Analyze Particles...", "  show=Outlines exclude add in_situ");

//Now we want to save the positions of all the ROIs as a csv.
roiManager("List");
saveAs("Results", originalDirectory+"RightROIpositions.csv");

//Close the binary masked images.
selectWindow("restored.png");
close();
//Reopen the original.
open(directory+"restored.png");
selectWindow("restored.png");

//Measure the intensity of all ROIs.
roiManager("Deselect");
roiManager("Measure");
saveAs("Results", originalDirectory+"RightIntensities.csv");

//Close extraneous windows
run("Close");
selectWindow("RightROIpositions.csv");
run("Close");
selectWindow("restored.png");
close();
selectWindow("ROI Manager");
run("Close");

//and we're done! Back to the matlab script...
