clear
clc
close all


%% Parameter definitions
sigmaX = 3; % sigma value in the x direction for the gaussian fit, smaller value = more seeds
sigmaY = 3; % sigma value in the y direction for the gaussian fit, smaller value = more seeds
threshold = 25; % threshold percentage for removing background from watershed


%% Initialize images and image settings

tiff = 'Apoptosis highlight1.tif';
for image = 1:numel(imfinfo(tiff))
    tiffstack(:,:,:,image) = imread('Apoptosis highlight1.tif',image);
end
tiffstack = uint16(tiffstack);
tiffstack = tiffstack*256;
image = tiffstack(:,:,1,1);
image = image*(65536/(max(image(:))));
[y,x] = size(image); % set [y,x] as image dimensions
imageSettings.zoomCoordinates = uint16([y/2,x/2]); % set coordinates of zoom image to center of image
imageSettings.magnification = 5; % set magnification of zoom image
imageSettings.colorMap = 'parula';
imageSettings.nonCellCoordinates = []; % initialize vector designating non-cells
imageSettings.runWatershed = 1; % initialize watershed mode
imageSettings.runBorder = 0; % initialize border mode

%% Fit Gaussian and determine seed locations

gaussFit = imgaussfilt(image,[sigmaX,sigmaY]);
gaussFit(gaussFit <= prctile(gaussFit(:),threshold)) = prctile(gaussFit(:),threshold);
minima = imregionalmin(gaussFit);
seedLocations = regionprops(minima,'Centroid');
for iseed = 1:size(seedLocations)
    markerLocations(iseed,1) = round(seedLocations(iseed).Centroid(2));
    markerLocations(iseed,2) = round(seedLocations(iseed).Centroid(1));
end


%% Perform watershed and display

figure('units','normalized','outerposition',[0 0 1 1])
guiImage = makeGUIFigure(markerLocations,image,imageSettings);
imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
imshow(guiImage,'InitialMagnification','fit');

%% Add or remove seeds
nNonCell=1;
toggleBorder = 0;
toggleWatershed = 0;
notdone = true;
while notdone
    [x,y,b] = ginput(1);
    switch b
        case 1 % left click adds seed
            markerLocations = vertcat(markerLocations,clickParser([y,x],image,imageSettings));
            imageSettings.zoomCoordinates = clickParser([y,x],image,imageSettings);
            [y,x] = size(image);
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 3 % right click deletes seed
            X = pdist2(markerLocations, clickParser([y,x],image,imageSettings));
            [~,i] = min(X);
            markerLocations(i,:) = [];
            imageSettings.zoomCoordinates = clickParser([y,x],image,imageSettings);
            [y,x] = size(image);
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 2 % middle click removes cell
            imageSettings.runWatershed = 1;
            imageSettings.nonCellCoordinates(nNonCell,:) = clickParser([y,x],image,imageSettings);
            if imageSettings.watershedImage(imageSettings.nonCellCoordinates(nNonCell,1),imageSettings.nonCellCoordinates(nNonCell,2)) ~= 0
                nNonCell = nNonCell+1;
                imageSettings.zoomCoordinates = clickParser([y,x],image,imageSettings);
                [y,x] = size(image);
                if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                    imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
                elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                    imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
                end
                if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                    imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
                elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                    imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
                end
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
                imshow(guiImage,'InitialMagnification','fit');
            elseif imageSettings.watershedImage(imageSettings.nonCellCoordinates(nNonCell,1),imageSettings.nonCellCoordinates(nNonCell,2)) == 0
                
            end
            imageSettings.runWatershed = 0;
        case 32 % space button ends loop
            notdone = false;
        case 114 % r runs watersheds
            if toggleWatershed == 0
                imageSettings.runWatershed = 1;
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                [y,x] = size(image);
                imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
                imshow(guiImage,'InitialMagnification','fit');
                toggleWatershed = 1;
            elseif toggleWatershed ==1
                imageSettings.runWatershed = 0;
                toggleWatershed = 0;
            end
        case 98 % b shows borders
            if toggleBorder == 0
                imageSettings.runBorder = 1;
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imshow(guiImage,'InitialMagnification','fit');
                toggleBorder = 1;
            elseif toggleBorder ==1
                imageSettings.runBorder = 0;
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imshow(guiImage,'InitialMagnification','fit');
                toggleBorder = 0;
            end
        case 127 % delete resets watershed
            markerLocations = [];
            for iseed = 1:size(seedLocations)
                markerLocations(iseed,1) = round(seedLocations(iseed).Centroid(2));
                markerLocations(iseed,2) = round(seedLocations(iseed).Centroid(1));
            end
            imageSettings.runWatershed = 1;
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            [y,x] = size(image);
            imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
            imshow(guiImage,'InitialMagnification','fit');
            imageSettings.runWatershed = 0;
        case 119 % w moves zoom image up
            [y,x] = size(image);
            imageSettings.zoomCoordinates(1) = imageSettings.zoomCoordinates(1) - round(y/(2 * imageSettings.magnification));
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 97 % a moves zoom image left
            [y,x] = size(image);
            imageSettings.zoomCoordinates(2) = imageSettings.zoomCoordinates(2) - round(y/(2 * imageSettings.magnification));
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 115 % s moves zoom image down
            [y,x] = size(image);
            imageSettings.zoomCoordinates(1) = imageSettings.zoomCoordinates(1) + round(y/(2 * imageSettings.magnification));
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 100 % d moves zoom image right
            [y,x] = size(image);
            imageSettings.zoomCoordinates(2) = imageSettings.zoomCoordinates(2) + round(y/(2 * imageSettings.magnification));
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 113 % q increases zoom
            if imageSettings.magnification >= 3
                imageSettings.magnification = imageSettings.magnification + 1;
            elseif imageSettings.magnification < 3
                imageSettings.magnification = imageSettings.magnification + 0.25;
            end
            [y,x] = size(image);
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 101 % e decreases zoom
            if imageSettings.magnification >= 3
                imageSettings.magnification = imageSettings.magnification - 1;
            elseif imageSettings.magnification > 1.25
                imageSettings.magnification = imageSettings.magnification - 0.25;
            elseif imageSettings.magnification <= 1.25
                imageSettings.magnification = 1.01;
            end
            [y,x] = size(image);
            if imageSettings.zoomCoordinates(1) > round(y - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(1) = round(y - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(1) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(1) = round(y/(2 * imageSettings.magnification))+1;
            end
            if imageSettings.zoomCoordinates(2) > round(x - y/(2 * imageSettings.magnification))-1;
                imageSettings.zoomCoordinates(2) = round(x - y/(2 * imageSettings.magnification))-1;
            elseif imageSettings.zoomCoordinates(2) < round(y/(2 * imageSettings.magnification))+1;
                imageSettings.zoomCoordinates(2) = round(y/(2 * imageSettings.magnification))+1;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 122 % z saves current seeds
            uisave({'image';'markerLocations'},'watershedSave')
    end
end
%% Give cells identifiers

label = getLabel(markerLocations, image, imageSettings);
cellprops = regionprops(label,'Centroid');
for imarker = size(cellprops,1)+1:size(markerLocations,1)
    cellprops(imarker).Centroid = [NaN,NaN];
end

nCell = 1;
nNonCell = 1;
for imarker = 1:size(markerLocations,1)
    if cellprops(imarker).Centroid(1) >= 0
        markerLocations(imarker,1)  = round(cellprops(imarker).Centroid(2));
        markerLocations(imarker,2) = round(cellprops(imarker).Centroid(1));
    end
    if label(markerLocations(imarker,1),markerLocations(imarker,2)) ~= 0
        CellID{nCell,1} = imarker;
        CellID{nCell,2} = [markerLocations(imarker,1),markerLocations(imarker,2)];
        nCell = nCell+1;
    end
    if label(markerLocations(imarker,1),markerLocations(imarker,2)) == 0
        nonCellID{nNonCell,1} = imarker;
        nonCellID{nNonCell,2} = [markerLocations(imarker,1),markerLocations(imarker,2)];
        nNonCell = nNonCell+1;
    end
end

%% Segment second image


image2 = tiffstack(:,:,1,2);
image2(image2 <= 1265) = image2(image2 <= 1265)*(65535/1265);
image2 = image2*(65536/(max(image2(:))));
[y,x] = size(image2);


imageSettings.zoomCoordinates = uint16([y/2,x/2]);
imageSettings.magnification = 5;
imageSettings.bigDim = [y,x];
imageSettings.colorMap = 'parula';
imageSettings.nonCellCoordinates = [];
imageSettings.runWatershed = 1;


guiImage = makeGUIFigure(markerLocations,image2,imageSettings);
imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
imshow(guiImage,'InitialMagnification','fit');




