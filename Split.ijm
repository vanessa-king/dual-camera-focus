// This script splits our two channel image into a left and right.
// It then saves these images for later use. 

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
//First the left hand side
selectImage(originalImage);
makeRectangle(0, 0, Split, getHeight);
run("Duplicate...", "title=Left");
selectWindow("Left");
saveAs("PNG", originalDirectory+"Left.png");
close();


//Now for the right hand side
makeRectangle(Split, 0, getWidth-Split, getHeight);
run("Duplicate...", "title=Right");
selectWindow("Right");
saveAs("PNG", originalDirectory+"Right.png");
close();



selectImage(originalImage);
close();

//And we're done, back to Matlab...
