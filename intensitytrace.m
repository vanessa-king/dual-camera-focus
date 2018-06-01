function [ I, B, C ] = intensitytrace( imagestack, positions, emitterRadius, exclusionRadius, bgRadius )
% INTENSITYTRACE Summary of this function goes here
%   Detailed explanation goes here
import Core.Static.SM.*

frameNumber = size(imagestack,3); % Number of Frames
imageSize = [size(imagestack,1), size(imagestack,2)];  %Size of the image
npos    = size(positions,1); % Number of molecules

I = zeros(frameNumber,npos); %Creates rows with zeros for trjectory
B = zeros(frameNumber,npos); %Creates rows with zeros for background trajectory
C = zeros(npos,2); % 2 columns for positions

str_em = strel('disk', emitterRadius); %%strel is a disk shaped structuring element
str_ex = strel('disk', exclusionRadius);
str_bg = strel('disk', bgRadius);

linearInd = sub2ind(imageSize, positions(:,2), positions(:,1)); %The sub2ind command determines the
%equivalent single index corresponding to a set of subscript values (one number to find position of the peak)

BW = false(imageSize);% false(sz) is an array of logical zeros where the size vector, sz, defines size(F). 
%For example, false([2 3]) returns a 2-by-3 array of logical zeros.
BW(linearInd) = true; % Creates 1 values at the peaks positions
BW_excl = imdilate(BW,str_ex);  %dilates the grayscale, binary, or packed binary image I, returning the dilated image,


%Note: A radius 3 will give a square of 5x5. 


%Disk for r=2 is
% 0 0 1 0 0
% 0 1 1 1 0
% 1 1 1 1 1
% 0 1 1 1 0
% 0 0 1 0 0 

%Disk for r=3 is
% 1 1 1 1 1
% 1 1 1 1 1
% 1 1 1 1 1
% 1 1 1 1 1
% 1 1 1 1 1 

%Disk for r=4 is

% 0 0 1 1 1 0 0
% 0 1 1 1 1 1 0
% 1 1 1 1 1 1 1
% 1 1 1 1 1 1 1
% 1 1 1 1 1 1 1
% 0 1 1 1 1 1 0
% 0 0 1 1 1 0 0

for i = 1:npos
    
    BW = false(imageSize);
    BW(linearInd(i)) = true;
    BW_em   = imdilate(BW,str_em);
    BW_bg   = imdilate(BW,str_bg); %Creates the disk on desired position
    BW_bg = and(BW_bg, ~BW_excl); %Substract exclusion disk (~ reverts logical from 0 to 1)
    
    emi = find(BW_em); %%%Positions of emission
    bgi = find(BW_bg); %%%Positions of BG
    
    [ I(:,i), B(:,i), C(i,:) ] = gtr_rafa( imagestack, emi, bgi );
    
    disp(['Done with molec ' num2str(i)])
    
end