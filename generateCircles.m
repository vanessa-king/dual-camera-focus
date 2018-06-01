function [goodXYKLB, numPoints ] = generateCircles(fulldatapath, aveImage, threshold)

%This creates circles over peaks using a gaussian peak estimation. Peaks are sized at 7x7 pixels.
%! debug will be marked by %!


circle = [0,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,1,1,1,0,0,0,0;
          0,0,0,1,0,0,0,1,0,0,0;
          0,0,1,0,0,0,0,0,1,0,0;
          0,1,0,0,0,0,0,0,0,1,0;
          0,1,0,0,0,0,0,0,0,1,0;
          0,1,0,0,0,0,0,0,0,1,0;
          0,0,1,0,0,0,0,0,1,0,0;
          0,0,0,1,0,0,0,1,0,0,0;
          0,0,0,0,1,1,1,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0];

%%%%% YG(explanation) This function generates all combinations of gpeaks on
%%%%% a 7x7 matrix.

g_peaks = zeros(7, 7, 3, 3);
for k = 1:3
    for l = 1:3
        %an offset of -.5 means a shift to the positive direction, a shift
        %of 0.5 means a shift to the negative direction.
        offx = 0.5 * double(k-2);
        offy = 0.5 * double(l-2);
        for i = 1:7
            for j = 1:7
                dist = 0.4 * ((double(i)-4.0+offx)^2 + (double(j)-4.0+offy)^2);
                %%%%YG(explanation of 0.4) Sigma^2 is 1.25 pixels or FWHM
                %%%%is 2.63 pixels (130nm pixelsize is 342 nm)
                %j = y-point, i= x-point, l=ofssets of y, k=offsets of x.
                g_peaks(j,i,l,k) = exp(-dist);
            end
        end
    end            
end

% initialize variables, set to integer value 1

film_x = 1;
film_y = 1;
fr_no  = 1;

%produce a smoothed average image.
smoothedAveImage = medfilt2(aveImage,[2 2]);
temp1 = smoothedAveImage;

%%%% YG (explanation) get the size Y and X of the image
sizeImage = size(aveImage);
film_x = sizeImage(2);
film_y = sizeImage(1);

%Background subtraction:
%create floating point array consisting of 256 times (16x16)less points 
%than the actual picture. Imagine taking the full picture, cutting it up 
%into pieces of 16x16 and coloring each piece with the least intense pixel.
remainder = mod(film_x,8);
film_x = film_x - mod(film_x,8);
aves = zeros(film_y/16, film_x/8);

 for i=9:16:film_y
     for j=9:16:film_x 
         %if (j == 265) % this ignores the line passing through the middle
         %YG(we dont need this for 1COLOR images)
             %aves(((i-9)/16) + 1,((j-9)/16) + 1) = min(min(temp1(i-8:i+7,j-3:j+7)));
         %if (i == film_y-7) && (j == film_x-7) 
             %aves(((i-9)/16) + 1,((j-9)/16) + 1) = min(min(temp1(i-8:i+3,j-8:j+3)));
             % YG (expl) removes 4 pixels border at right-bottom corner to
             % average
         %elseif (i == film_y-7)
             %aves(((i-9)/16) + 1,((j-9)/16) + 1) = min(min(temp1(i-8:i+5,j-8:j+7)));
             % YG (expl) removes 2 pixels border at the bottom to average
         %elseif (j == film_x-7)
             %aves(((i-9)/16) + 1,((j-9)/16) + 1) = min(min(temp1(i-8:i+7,j-8:j+2)));
             % YG (expl) removes 5 pixels border at the bottom to average
         %else
             aves(((i-9)/16) + 1,((j-9)/16) + 1) = min(min(temp1(i-8:i+7,j-8:j+7)));
         %end
     end
end
%resize array from aves to original size of image, then smooth the array with width 
%30, edge truncated. Finally subtract each point in the smoothed average array with 
%the smoothed minnimum array -10 (god knows why - 10... perhaps not to make some 
%points go to 0)

avesTemp = zeros(film_y, film_x);
for i=1:16:film_y-15 
    %%%% YG This makes 32 quadrants for 512 images
    for j=1:16:film_x-15 
    %%%% YG This makes 32 quadrants for 512 images
        avesTemp(i:i+15,j:j+15) = aves(ceil(i/16),ceil(j/16)); 
        %%%%YG (explanation) ceil rounds toward positive infinity
    end
end

%Y = uint16(avesTemp);
%imshow(Y);
aves = avesTemp;
aves = medfilt2(aves,[30 30]);  %smooth image with 30x30 radius
%imshow(aves);

extraColumns = zeros(512,remainder);
aves = [aves extraColumns];

%%%%% Subtract background to the full image %%%%%
temp1 = aveImage-uint16(aves-1203); %%% Yasser (1203 is to match empirically 8 bit, no other reason)
%temp1 = aveImage - (aves - 10);
%d = figure; %%%Separate plot
%tempp = uint16(temp1) %%%%YG to be able to plot it
%imshow(tempp);    

% find the peaks, temp2,3,4 are all set to frame which is the 16-bit
% unsmoothed average picture. CHANGEDDD

temp2 = temp1;
temp3 = temp1;
temp4 = temp1;

goodXYKLB = zeros(8000,5);
%foob = zeros(7,7);
diff = zeros(3,3);

numPoints = 0;

%obtain median intensity from smoothed background subtracted image.
med = double(median(median(temp1)));

%set threshold to default or user defined...
if threshold == 0
threshold = 10;
else threshold = threshold; %redundant but clear
end

%ignore around half of the points (because of blurriness)
%for i=16:film_x-10
for i=6:film_x-5 
%%%% YG (explanation) This ignores 15 at the left and 10 at the right.
     for j=6:film_y-5
   % for j=16:film_y-10 %originally set as j=16:495
        if temp2(j,i) >= threshold 
            if temp2(j,i) >= 0 
                %find nearest maxima
                foob = temp2(j-3:j+3, i-3:i+3);
                %if there is more than one local maxima, it will make a
                %list of them.
                [row,col] = find(foob == max(foob(:)));
                [maxIntensity,maxIndicesX] = max(max(foob));
                y1 = row(1);
                x1 = col(1);
              
%if x and y are center of current 7x7 matrix, ie is the most intense spot 
%in a 7x7 radius.
                    if x1 == 4 
                        if y1 == 4 
                            y = j;
                            x = i;
                            
                            quality = 1;
                            for k = -5:5
                                for l = -5:5
                                    %through the circumference of the circle, 
                                    %check quality, if bad set to 0.
                                    %if there is an intensity that is too large
                                    %set quality to zero.
                                    if circle(l+6,k+6) > 0
                                    %%% YG See function circle at the
                                    %%% beginning
                                        if temp1(y+l,x+k) > med + 0.45 * double(maxIntensity) 
                                        %%%%YG(expl) this is how it rejects
                                        %%%%two close spots. Check the
                                        %%%%intensity of the circunference.
                                            quality = 0;
                                        end
                                    end
                                end
                            end
                            
                            if quality == 1 
                            
                            % draw circle around point, assuming the
                            % strongest point is at the center. Since the
                            % offset is used to draw around the circle (using temp3) this
                            % code is kinda useless. 
                            
                            for k = -5:5
                                for l = -5:5
                                    if circle(l+6,k+6) > 0
                                        %temp3(y+l,x+k) = 90;
                                        temp4(y+l,x+k) = 90;
                                    end
                                end
                            end
                            
                            % compute difference between peak and gaussian peak. 
                            % Here we take into account offsets. z is the maximum
                            % value in the 7x7 array. aves(y,x) is the minimum  		         
                            % value near that spot. g_peaks(:,:,l,k) is the 
                            % gaussian peak distribution. We subtract this 
                            % with the total 7x7 array that has already been 		  
                            % smoothened. The difference that is closest to 
                            % 0 gives the best offset.  
                            
                            cur_best = 10000;
                            for k = 1:3 
                                for l = 1:3
                                    diff(l,k) = sum(sum(abs((double(maxIntensity - aves(y,x))) * g_peaks(:,:,l,k) - (double(temp2(y-3:y+3,x-3:x+3) - aves(y,x))))));
                                    %%%% remember that g_peaks are
                                    %%%% normalized                          
                                    if diff(l,k) < cur_best 
                                        bestK = k;
                                        bestL = l;
                                        cur_best = diff(l,k);
                                    end
                                end
                            end
                            
                            % use proper offsets to get the 'center' of the 
                            % peak. 
                            
                            %flt_x = double(x) - 0.5*double(best_x-2);
                            %flt_y = double(y) - 0.5*double(best_y-2);
                            
                            %xf = flt_x;
                            %yf = flt_y;
                            
                            % round the x and y of the center to the nearest 
                            % integer, ie. 4.5->5
                            
                            %int_xf = round(flt_x);
                            %int_yf = round(flt_y);
                            
                            for k = -5:5 
                                for l = -5:5
                                    if circle(l+6,k+6) > 0
                                        
                                     % [Robert] To prevent index out-of-bounds 
                                     % errors. Continues skips to the next 
                                     % iteration...
                                        if (x+k) < 1  
                                            continue;
                                        end
                                        if (y+l) < 1  
                                            continue;
                                        end
                                     % [Robert] To prevent index out-of-bounds 
                                     % errors
                                        if (x+k) > 512  
                                            continue;
                                        end
                                        if (y+l) > 512 
                                            continue;
                                        end
                          
                                     % draw new circle? over the one we already 
                                     % have? I guess to center it properly...
                                        %%%temp3(y+l,x+k) = 256*256;%%%%Yasser added *256
                                        temp3(y+l,x+k) = med*3;%%%%Yasser
                                    end
                                end
                            end
                            
                            
                            numPoints = numPoints + 2;
                            goodXYKLB(numPoints-1,1) = x;
                            goodXYKLB(numPoints-1,2) = y;
%                             goodXYKLB(numPoints-1,3) = bestK;
%                             goodXYKLB(numPoints-1,4) = bestL;
%                            goodXYKLB(numPoints-1,5) = aves(y,x);
                            goodXYKLB(numPoints,1) = x;
                            goodXYKLB(numPoints,2) = y;
%                             goodXYKLB(numPoints,3) = bestK;
%                             goodXYKLB(numPoints,4) = bestL;
%                            goodXYKLB(numPoints,5) = aves(y,x);
                            
                            %{
                            
                            I really fail to see the importance of this... 
                            
                            %xf = double(round(2 * xf)) * 0.5;
                            %yf = double(round(2 * yf)) * 0.5;
                            
                            % all this good, no good stuff is to print out 
                            % the values of the "center" using slightly different
                            % methods. 
                            
                            %goodXY(currentPoint, 1) = flt_x;
                            %goodXY(currentPoint, 2) = flt_y;
                            %backgroundXY(currentPoint) = aves(y,x);
                            %no_good = no_good + 1;
                            
                            
                            
                            % [Robert] To prevent index out-of-bounds errors
                            if (int_xf+k) < 1 
                                %continue;
                            end             
                            if (int_yf+l) < 1 
                                continue;
                            end
                   
                            % [Robert] To prevent index out-of-bounds errors
                            if (int_xf+k) > 512
                                continue;
                            end
                            if (int_yf+l) > 512 
                                continue;
                            end
                            %}
                          
                           
                            end
                        end
                    end
            end
        end
    end
end
%d = figure; Yasser deleted this to prevent two images showing
%hold on Yasser

%clear unused points in array.
goodXYKLB(numPoints+1:8000,:) = [];
circlesDrw = uint16(temp3);

% show picture with 
[ path, file, ext ] = fileparts(fulldatapath);
s = filesep;
%imshow(circlesDrw);
fileWritePath = [path s file , '_Circles.tif'];
imwrite(circlesDrw,fileWritePath,'tif'); 

%uiwait(d)Yasser
            
end
