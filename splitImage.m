function y = splitImage(originalImage, path, division, refSide)
%This function takes the photo and crops it into two based on the division.
%Then, it has to save the sides according to the reference side.

%Get size of original image
[xmax, ymax, zmax] = size(originalImage);

%The crop rectangle is specified by [xmin, ymin, width, height]
%Left side
left = imcrop(originalImage,[1,1,division,ymax]);
%Right side
rightWidth = xmax-division;
right = imcrop(originalImage,[division,1,rightWidth,ymax]);

greenFileName = fullfile(path, 'Green.png');
redFileName = fullfile(path, 'Red.png');

%Now we save the images based on the reference side
if refSide == "Left"
    %Left side is green, right side is red. Save images
    imwrite(left,greenFileName);
    imwrite(right,redFileName);
else
    %Left side is red, right side is green. Save images
    imwrite(left,greenFileName);
    imwrite(right,redFileName);
end
%Images have been saved, we are done.
end
