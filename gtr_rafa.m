function [ Int, BG, C ] = gtr_rafa( mov, emi, bgi )
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here
import Core.Static.SM.*

im_size = [size(mov,1), size(mov,2)];

[emX,emY] = ind2sub(im_size, emi); % Positions in x,y of relevant pixels
[bgX,bgY] = ind2sub(im_size, bgi);
C(:) = [mean(emY), mean(emX)]; % Position of center

tmp = uint16(zeros(size(mov,3),size(emY,1))); %trajectories with zeros
for j = 1:size(emY,1)
    tmp(:,j) = mov(emX(j),emY(j),:);
end
Int(:) = mean(tmp,2)*size(emY,1); %YASSER (multiply by the amount of pixels)

tmp = uint16(zeros(size(mov,3),size(bgY,1)));
for j = 1:size(bgY,1)
    tmp(:,j) = mov(bgX(j),bgY(j),:);
end
BG(:) = mean(tmp,2)*size(emY,1); %%YASSER (multiply by the amount of pixels)

end


