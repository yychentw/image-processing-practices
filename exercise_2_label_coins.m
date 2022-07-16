%{
Exercise 2 set by Hao-Chun Hsu
Calculate the mean area of 1 NTD, 5 NTD, 10 NTD and 50 NTD coins in image ‘NTDcoins.jpg’. Demonstrate the coins in a labeled image, where black pixels represent background, red pixels represent 1 NTD coins, yellow pixels represent 5 NTD coins, green pixels represent 10 NTD coins, and blue pixels represent 50 NTD coins. Describe your image processing procedure and approach.
%}

clear all
close all

pkg load statistics

% Convert image to binary image based on threshold
I = imread('NTDcoins.jpg');
grayI = rgb2gray(I);
level = graythresh(grayI);
thresh = round(level*255)
BW = im2bw(grayI, level);
figure; 
subplot(1, 2, 1); imhist(grayI); line([thresh thresh], [0 10000]);
subplot(1, 2, 2); imshow(BW);

% Noise reduction by removing extremely small connected objects
[labeled, numObjects] = bwlabel(BW, 8);
objdata = regionprops(labeled, 'basic');
[maxvalue, argmax] = max([objdata.Area]);
BW(find((labeled ~= argmax) & (labeled ~= 0))) = 0;
figure; imshow(BW);

comBW = imcomplement(BW);
[labeled, numObjects] = bwlabel(comBW, 8);
objdata = regionprops(labeled, 'basic');
[idx, C] = kmeans([objdata.Area]', 2);
[minvalue, argmin] = min(C);
comBW(ismember(labeled, find(idx == argmin))) = 0;
figure; imshow(comBW);

% Noise reduction using image closing (not work well...)
%{
comBW = imcomplement(BW);
closedBW = imclose(comBW, strel('diamond', 2));
figure; 
subplot(1, 2, 1); imshow(comBW);
subplot(1, 2, 2); imshow(closedBW);
%}

% Label connected components and obtain coins' area
[labeled, numObjects] = bwlabel(comBW, 8);
coindata = regionprops(labeled, 'basic');
areas = [coindata.Area]';
figure; hist(areas);

% Separate different coins by KMeans (reset index according to sorted area)
[idx, C] = kmeans(areas, 4);
[sorted_mean_areas, sorted_idx] = sort(C);
new_idx = zeros(size(idx));
for ii = 1:4
    new_idx(find(idx == sorted_idx(ii))) = ii;
end

% Demonstrate the coins in a labeled image
newI = uint8(zeros(size(I)));
num_pixels = prod(size(BW));
for ii = 1:4
    selected_idx = find(ismember(labeled, find(new_idx == ii)));
    if ii == 1
        newI(selected_idx) = 255;
    elseif ii == 2
        newI([selected_idx selected_idx+num_pixels]) = 255;
    elseif ii == 3
        newI(selected_idx+num_pixels) = 255;
    else
        newI(selected_idx+num_pixels*2) = 255;
    end
end
figure; imshow(newI);
imwrite(newI, 'labeled_coins.jpg');

% Mean area of 1 NTD, 5 NTD, 10 NTD, and 50 NTD coins
sorted_mean_areas