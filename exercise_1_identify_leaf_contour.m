%{
Exercise 1 set by Hao-Chun Hsu
Write a MATLAB script to identify the contour of the maple leaf in image ‘Maple.jpg’. The program should be able to exclude the petiole from the contour. Draw the contour on top of the maple leaf in the image. Please also calculate the ratio of leaf contour and leaf area.
%}

clear all
close all

% Convert image to binary image based on threshold
I = imread('Maple.jpg');
grayI = rgb2gray(I);
level = graythresh(I);
thresh = round(level*255)
BW = im2bw(grayI, level);
figure;
subplot(1, 3, 1), imshow(grayI);
subplot(1, 3, 2); imhist(grayI);
line([thresh thresh], [0 300]);
subplot(1, 3, 3); imshow(BW);

% Complement the binary image and exclude the petiole by image opening
newBW = imcomplement(BW);
openedBW = imopen(newBW, strel('octagon', 6));
figure; 
subplot(1, 2, 1); imshow(newBW);
subplot(1, 2, 2); imshow(openedBW);

% Identify the contour and draw it on top of the leaf in the image
Icontour = I;
contour = bwperim(openedBW, 8);
num_pixels = prod(size(BW));
c_index = find(contour == 1);
Icontour([c_index c_index+num_pixels c_index+num_pixels*2]) = 0;
figure; 
subplot(1, 2, 1); imshow(contour);
subplot(1, 2, 2); imshow(Icontour);
imwrite(contour, 'Maple_bw_contour.jpg')
imwrite(Icontour, 'Maple_with_contour.jpg')

% Calculate the ratio of leaf contour and area
area = sum(openedBW(:))
contour_length = sum(contour(:))
ratio = contour_length/area
