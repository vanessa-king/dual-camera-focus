//This macro is to help focus a multi-channel image on the microscope.
//It gets called by the evaluateFocusScript.
open();
originalImage = getImageID();
originalDirectory = getInfo("image.directory");
width = getWidth;
//Here we ask where to split up the image
Dialog.create("");
Dialog.addNumber("Where is the channel border? \n (1-"+width+")",width/2);
Dialog.show();
Split = Dialog.getNumber();

//Now we are going to split the image into two separate windows. 
//Rectangle function is of form (x1,y1,width,height)
//This one is for the right hand side
makeRectangle(Split, 0, getWidth-Split, getHeight);
run("Duplicate...", "title=Right");

//Now for the left hand side
selectImage(originalImage);
makeRectangle(0, 0, Split, getHeight);
run("Duplicate...", "title=Left");

selectImage(originalImage);
close();

//Our next step is to scale our red image. 
//This is done using Plugins -> Registration -> Align Image by line ROI.
instruction = "Draw a line between two specific objects on each image. Select OK when you're done.";
waitForUser(" ", instruction);
//Here we run the plugin.
run("Align Image by line ROI", "source=Right target=Left scale rotate");


//Now we want to save our duplicated images so they can be used later.
selectWindow("Right");
close();
selectWindow("Right aligned to Left");
saveAs("PNG", originalDirectory+"Right.png");
close();
selectWindow("Left");
saveAs("PNG", originalDirectory+"Left.png");

//LEFT HAND SIDE
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
open(originalDirectory+"Right.png");
run("8-bit");
run("Options...", "iterations=1 count=1 black");
setOption("BlackBackground", true);
setThreshold(25,255);
run("Convert to Mask");

//Now we are going to find all the particles.
selectWindow("Right.png");
run("Analyze Particles...", "  show=Outlines exclude add in_situ");

//Now we want to save the positions of all the ROIs as a csv.
roiManager("List");
saveAs("Results", originalDirectory+"RightROIpositions.csv");

//Close the binary masked images.
selectWindow("Right.png");
close();
//Reopen the original.
open(originalDirectory+"Right.png");
selectWindow("Right.png");

//Measure the intensity of all ROIs.
roiManager("Deselect");
roiManager("Measure");
saveAs("Results", originalDirectory+"RightIntensities.csv");

//Close extraneous windows
run("Close");
selectWindow("RightROIpositions.csv");
run("Close");
selectWindow("Right.png");
close();
selectWindow("ROI Manager");
run("Close");

//and we're done! Back to the matlab script...
