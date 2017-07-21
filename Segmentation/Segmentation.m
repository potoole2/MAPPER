clear
clc



%% Parameter definitions
sigmaX = 5; % sigma value in the x direction for the gaussian fit, smaller value = more seeds
sigmaY = 5; % sigma value in the y direction for the gaussian fit, smaller value = more seeds
threshold = 10; % threshold percentage for removing background from watershed
filterDiameter = 5; % filter diameter


%% Initialize image and image settings

loadFile = struct2cell(uiimport('-file')); % user loaded file
image =  loadFile{1,1}; %initial image

% image = imread('cell boundaries.tif');
image = image*(65536/prctile(image(:),100)); % scale image brightness
[y,x] = size(image); % set [y,x] to image dimensions
imageSettings.zoomCoordinates = uint16([y/2,x/2]); % set initial coordinates of zoom image
imageSettings.magnification = 5; % set magnification of zoom image
imageSettings.colorMap = 'parula'; % set colormap of watershed image
imageSettings.addCellCoordinates = []; % initialize vector designating added cells
imageSettings.nonCellCoordinates = []; % initialize vector designating non-cells
imageSettings.runWatershed = 1; % initialize watershed mode
imageSettings.runBorder = 0; % initialize border mode
imageSettings.recenter = 0; %initialize magnified image mode
imageSettings.showFilter = 0;
imageSettings.addBorder = 0;
imageSettings.filterImage0 = ridgeenhhessian(dircohenh(im2double(image),filterDiameter,[1 1 3]),[1 1 3]); % filter image
imageSettings.filterImage = imageSettings.filterImage0;
imageSettings.filterBrightness = 100;
imageSettings.rawBrightness = 100;

%% Determine seed locations or load previous data

if size(loadFile,1) == 1
    gaussFit = imgaussfilt(imageSettings.filterImage,[sigmaX,sigmaY]);
    gaussFit(gaussFit <= prctile(gaussFit(:),threshold)) = prctile(gaussFit(:),threshold);
    minima = imregionalmin(gaussFit);
    seedLocations = regionprops(minima,'Centroid');
    for iseed = 1:size(seedLocations)
        markerLocations(iseed,1) = round(seedLocations(iseed).Centroid(2));
        markerLocations(iseed,2) = round(seedLocations(iseed).Centroid(1));
    end
elseif size(loadFile,1) == 3
    markerLocations = loadFile{2,1};
    imageSettings.filterImage = loadFile{3,1};
elseif size(loadFile,1) == 4
    markerLocations = loadFile{2,1};
    imageSettings.filterImage = loadFile{3,1};
    imageSettings.nonCellCoordinates = loadFile{4,1};
    
end


%% Perform watershed and display

figure('units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1])
guiImage = makeGUIFigure(markerLocations,image,imageSettings);
imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
imageSettings.runWatershed = 0;
guiImage = makeGUIFigure(markerLocations,image,imageSettings);
imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
imshow(guiImage,'InitialMagnification','fit');

%% Add or remove seeds

nNonCell=size(imageSettings.nonCellCoordinates,1)+1;
nLine = 1;
toggleBorder = 0;
toggleWatershed = 0;
notdone = true;
while notdone
    [x,y,b] = ginputedit1(1);
    switch b
        case 1 % left click adds seed
            if ~isempty(clickParser([y,x],image,imageSettings))
                markerLocations = vertcat(markerLocations,clickParser([y,x],image,imageSettings));
                if imageSettings.recenter == 1
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
                end
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imshow(guiImage,'InitialMagnification','fit');
            end
        case 3 % right click deletes seed
            if ~isempty(clickParser([y,x],image,imageSettings))
                X = pdist2(markerLocations, clickParser([y,x],image,imageSettings));
                [~,i] = min(X);
                markerLocations(i,:) = [];
                if imageSettings.recenter == 1;
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
                end
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imshow(guiImage,'InitialMagnification','fit');
            end
        case 2 % middle click adds/removes cell
            if ~isempty(clickParser([y,x],image,imageSettings))
                
                imageSettings.nonCellCoordinates(nNonCell,:) = clickParser([y,x],image,imageSettings);
                
                if imageSettings.watershedImage(imageSettings.nonCellCoordinates(nNonCell,1),imageSettings.nonCellCoordinates(nNonCell,2)) ~= 0
                    nNonCell = nNonCell+1;
                    if imageSettings.recenter == 1;
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
                    end
                    [y,x] = size(image);
                    guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                    imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
                    
                elseif imageSettings.watershedImage(imageSettings.nonCellCoordinates(nNonCell,1),imageSettings.nonCellCoordinates(nNonCell,2)) == 0
                    imageSettings.addCellCoordinates = clickParser([y,x],image,imageSettings);
                    imageSettings.nonCellCoordinates(nNonCell,:) = [];
                    dist = pdist2(imageSettings.nonCellCoordinates, imageSettings.addCellCoordinates);
                    [~,i] = min(dist);
                    imageSettings.nonCellCoordinates(i,:) = [];
                    nNonCell = nNonCell - 1;
                    [y,x] = size(image);
                    guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                    imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
                    
                end
                
                
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
                imshow(guiImage,'InitialMagnification','fit');
            end
        case 32 % space button ends loop
            if ~isempty(imageSettings.nonCellCoordinates)
                nonCells = imageSettings.nonCellCoordinates;
                filterImage = imageSettings.filterImage;
                uisave({'image';'markerLocations';'nonCells';'filterImage'},'watershedSave')
            else
                uisave({'image';'markerLocations';'filterImage'},'watershedSave')
            end
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
                [y,x] = size(image);
                imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
                guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                imshow(guiImage,'InitialMagnification','fit');
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
            imageSettings.runWatershed = 1;
            imageSettings.runBorder = 0;
            toggleBorder = 0;
            [y,x] = size(image);
            imageSettings.nonCellCoordinates = [];
            imageSettings.zoomCoordinates = uint16([y/2,x/2]);
            markerLocations = [];
            for iseed = 1:size(seedLocations)
                markerLocations(iseed,1) = round(seedLocations(iseed).Centroid(2));
                markerLocations(iseed,2) = round(seedLocations(iseed).Centroid(1));
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
            imshow(guiImage,'InitialMagnification','fit');
            imageSettings.runWatershed = 0;
        case 30 % up arrow moves zoom image up
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
        case 28 % left arrow moves zoom image left
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
        case 31 % down arrow moves zoom image down
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
        case 29 % right arrow moves zoom image right
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
            filterImage = imageSettings.filterImage;
            if ~isempty(imageSettings.nonCellCoordinates)
                nonCells = imageSettings.nonCellCoordinates;
                uisave({'image';'markerLocations';'filterImage';'nonCells'},'watershedSave')
            else
                uisave({'image';'markerLocations';'filterImage'},'watershedSave')
            end
            
        case 109 % m toggles image recentering
            if imageSettings.recenter == 0
                imageSettings.recenter = 1;
            elseif imageSettings.recenter == 1
                imageSettings.recenter = 0;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 102 % f toggles filtered image
            if imageSettings.showFilter == 0
                imageSettings.showFilter= 1;
            elseif imageSettings.showFilter== 1
                imageSettings.showFilter = 0;
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 43 % + increases brightness
            if imageSettings.showFilter == 0;
                imageSettings.rawBrightness = imageSettings.rawBrightness - 1;
                if imageSettings.rawBrightness < 0
                    imageSettings.rawBrightness = 0;
                end
            elseif imageSettings.showFilter == 1;
                imageSettings.filterBrightness = imageSettings.filterBrightness - 1;
                if imageSettings.filterBrightness < 0
                    imageSettings.filterBrightness = 0;
                end
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 45 % - decreases brightness
            if imageSettings.showFilter == 0;
                imageSettings.rawBrightness = imageSettings.rawBrightness + 1;
                if imageSettings.rawBrightness > 100;
                    imageSettings.rawBrightness = 100;
                end
            elseif imageSettings.showFilter == 1;
                imageSettings.filterBrightness = imageSettings.filterBrightness + 1;
                if imageSettings.filterBrightness > 100;
                    imageSettings.filterBrightness = 100;
                end
            end
            guiImage = makeGUIFigure(markerLocations,image,imageSettings);
            imshow(guiImage,'InitialMagnification','fit');
        case 108 % l manually adds borders
            done = 0;
            while ~done
                [x(1),y(1),b(1)] = ginputedit2(1);
                if b == 1
                    [x(2),y(2),b(2)] = ginputedit2(1);
                    if b == 1
                        lineCoordinates1 =clickParser([y(1),x(1)],image,imageSettings);
                        lineCoordinates2 =clickParser([y(2),x(2)],image,imageSettings);
                        imageSettings.lineCoordinates(nLine,1:4) = [lineCoordinates1(2) lineCoordinates1(1) lineCoordinates2(2) lineCoordinates2(1)];
                        nLine = nLine+1;
                        imageSettings.filterImage =  insertShape(imageSettings.filterImage,'line',[lineCoordinates1(2) lineCoordinates1(1) lineCoordinates2(2) lineCoordinates2(1)],'LineWidth', 1,'Color', [max(imageSettings.filterImage(:)) max(imageSettings.filterImage(:)) max(imageSettings.filterImage(:))]);
                        imageSettings.filterImage =  rgb2gray(imageSettings.filterImage);
                        guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                        imshow(guiImage,'InitialMagnification','fit');
                    else
                        done = 1;
                    end
                elseif b ==3
                    lineLocations(:,1) = (imageSettings.lineCoordinates(1)+ imageSettings.lineCoordinates(3))/2;
                    lineLocations(:,2) = (imageSettings.lineCoordinates(2)+ imageSettings.lineCoordinates(4))/2;
                    dist = pdist2( lineLocations,clickParser([y,x],image,imageSettings));
                    [~,i] = min(dist);
                    imageSettings.lineCoordinates(i,:) = [];
                    nLine = nLine - 1;
                    imageSettings.filterImage =  insertShape(imageSettings.filterImage0,'line',imageSettings.lineCoordinates,'LineWidth', 1,'Color', [max(imageSettings.filterImage0(:)) max(imageSettings.filterImage0(:)) max(imageSettings.filterImage0(:))]);
                    imageSettings.filterImage =  rgb2gray(imageSettings.filterImage);
                    guiImage = makeGUIFigure(markerLocations,image,imageSettings);
                    imshow(guiImage,'InitialMagnification','fit');
                    
                else
                    done = 1;
                end
            end
    end
end

%% Final watershed output

label = getFinalLabel(markerLocations, im2uint16(imageSettings.filterImage), imageSettings);
[y,x] = size(label);
label = imresize(label, [2*y,2*x],'nearest');
label = imdilate(label, strel('square',3));
[saveFile,path] =uiputfile('*.tif');
imwrite(label,[path,saveFile]);






