














if doStitch
    %% Stitching
    
    % This application takes a folder with raw z-stacks and converts them into
    % stitched confocal images. The files should have the default metamorph
    % naming conventions, for example:
    %
    % FILENAME 00001_w1Confocal 405.TIF
    % FILENAME 00001_w2Confocal 488.TIF
    % FILENAME 00001_w3Confocal 561.TIF
    % FILENAME 00001_w4Confocal 640.TIF
    %
    % Inputs required in order to read the file will be a string array of
    % channels in order (for example, here it would include 405, 488, 561, and
    % 640), the filename immediately prior to the numbers (which would be
    % 'FILENAME ' here), and the number of digits in the filenumber, as well
    % as the index of the starting image, the dimensions of the montages and
    % the number of tiles.
    %
    % The order of the channels in the colors array determines which channel is
    % represented by which color in the RGB image, in the order red, green,
    % blue, white.
    %
    % This script z-projects each file, and saves the z-projections in a new
    % folder, with the index and channel number. Then, if selected, a high-pass
    % filter is applied to each image and the images are normalized. Finally,
    % images are stitched with calculated overlaps with the assumption that the
    % different channels in each tile should align with each other.
    
    
    % Inputs
    % Stitching Inputs
    

    inputDirectory = directory{1}; % The full directory of raw data
    tempDirectory =  [inputDirectory 'temp' '\']; % Temp directory
    zprojDirectory = [inputDirectory 'zproj\']; % z-proj directory
    outputDirectory = [inputDirectory 'stitched\']; % output directory
    fftDirectory = [inputDirectory 'fft\'];
    
    
   
    tiles = numembs*M*N; % Total number of tiles in folder
    outputNumber = 1; % Starting index of the final stitched image
    outputName = [fileName,'Stitched']; % Name of the final stitched image
    
    
    % Initialize
    addpath(fijiDir);
    Miji(false);
    
    mkdir(tempDirectory);
    mkdir(outputDirectory);
    mkdir(zprojDirectory);

    mkdir(fftDirectory);
    
    % Z-project and FFT
    for k = 1:tiles
        for j = 1:length(channels)
            path = [inputDirectory fileName num2str(k,['%0' num2str(numChars) 'd']) '_w' num2str(j) 'Confocal ' channels{j} '.TIF'];
            savepath = [zprojDirectory fileName num2str(k,['%0' num2str(numChars) 'd']) '_w' num2str(j) 'Confocal ' channels{j} '_MIP.TIF'];
            savepath2 = [fftDirectory fileName num2str(k,['%0' num2str(numChars) 'd']) '_w' num2str(j) 'Confocal ' channels{j} '_MIP.TIF'];
            
            MIJ.run('Open...', ['path=[' strrep(path, '\', '\\') ']']);
            
            if filterchoice == 1
                MIJ.run('Bandpass Filter...',[ 'filter_large=' num2str(gaussSigma) ' filter_small=0 suppress=None tolerance=5 process']);
            elseif filterchoice == 2
                MIJ.run('Gaussian Blur...',['sigma=' num2str(gaussSigma) ' stack' ]);
                MIJ.run('Open...', ['path=[' strrep(path, '\', '\\') ']']);
                MIJ.run('Image Calculator...',...
                    ['image1=['  fileName num2str(k,['%0' num2str(numChars) 'd']) '_w' num2str(j) 'Confocal ' channels{j} '-1.TIF] '...
                    'image2=['  fileName num2str(k,['%0' num2str(numChars) 'd']) '_w' num2str(j) 'Confocal ' channels{j} '.TIF] '...
                    'operation=Subtract create stack'])
            end
            
            MIJ.run('Tiff...', ['path=[' strrep(savepath2, '\', '\\') ']']);
            
            MIJ.run('Z Project...', 'projection=[Max Intensity]');
            
            MIJ.run('Tiff...', ['path=[' strrep(savepath, '\', '\\') ']']);
            
            MIJ.run('Close All');
        end
    end
    

    
    % Combine Channels
    for k = 1:tiles
        for j = 1:length(channels)
            path = [zprojDirectory fileName num2str(k,['%0' num2str(numChars) 'd']) '_w' num2str(j) 'Confocal ' channels{j} '_MIP.TIF'];

             
          
            if j ==1
                imwrite(importdata(path),[tempDirectory 'Tile ' num2str(k,'%05d') '.TIF'])
            elseif j>1
                imwrite(importdata(path),[tempDirectory 'Tile ' num2str(k,'%05d') '.TIF'],'WriteMode','append')
            end
        end
        
    end
    

    
    
    
    
    
    % Stitch
   
    for embnum = 1:numembs
            
            MIJ.run('Memory & Threads...', 'maximum=12137 parallel=8 run');
        
            MIJ.run('Grid/Collection stitching', ['type=[Grid: row-by-row] order=[Right & Down                ]'...
                ' grid_size_x=' num2str(M) ' grid_size_y=' num2str(N) ' tile_overlap=' num2str(overlap) ' first_file_index_i=' num2str(1+M*N*(embnum-1)) ...
                ' directory=[' strrep(tempDirectory, '\', '\\') '] file_names=[Tile {iiiii}.tif] ' ...
                'output_textfile_name=TileConfiguration' num2str(embnum) '.txt fusion_method=[Do not fuse images (only write TileConfiguration)] ' ...
                'regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement' ...
                '_threshold=3.50 compute_overlap computation_parameters=[Save memory (but be slower)]' ...
                ' image_output=[Fuse and display]']);

            Optimization(M,N,tempDirectory,channels,embnum)
            
            MIJ.run('Grid/Collection stitching', ['type=[Grid: row-by-row] order=[Right & Down                ]'...
                ' grid_size_x=' num2str(M) ' grid_size_y=' num2str(N) ' tile_overlap=' num2str(overlap) ' first_file_index_i=' num2str(1+M*N*(embnum-1)) ...
                ' directory=[' strrep(tempDirectory, '\', '\\') '] file_names=[Optimized Tile {iiiii}.tif] ' ...
                'output_textfile_name=OptimizedTileConfiguration' num2str(embnum) '.txt fusion_method=[Linear Blending] ' ...
                'regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement' ...
                '_threshold=3.50 compute_overlap computation_parameters=[Save memory (but be slower)]' ...
                ' image_output=[Fuse and display]']);
            
            
            
            MIJ.run('Tiff...', ['path=[' strrep([outputDirectory ' ' outputName ' ' num2str(outputNumber,'%03d')], '\', '\\') '.TIF]']);
           
            
            MIJ.run('Close All');
            
            
     
        outputNumber = outputNumber + 1;
    end
    
    
    
    % Cleanup

    MIJ.exit;
        rmdir(tempDirectory,'s');
    end





if doSegmentCells
%% Segmentation






% Initialize image and image settings
if isstruct(file) == 0
    loadFile{1,1} = file;
elseif isstruct file == 1
    loadFile = struct2cell(file); % user loaded file
end

image =  loadFile{1,1}; %initial image

image = uint16(image); %convert to uint16

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
if size(loadFile,1) == 1
    imageSettings.filterImage0 = ridgeenhhessian(dircohenh(im2double(image),filterDiameter,[1 1 3]),[1 1 3]); % filter image
    imageSettings.filterImage = imageSettings.filterImage0;
end
imageSettings.filterBrightness = 100;
imageSettings.rawBrightness = 100;

% Determine seed locations or load previous data

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


% Perform watershed and display

figure('units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1])
guiImage = makeGUIFigure(markerLocations,image,imageSettings);
imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
imageSettings.runWatershed = 0;
guiImage = makeGUIFigure(markerLocations,image,imageSettings);
imageSettings.watershedImage = guiImage((y+1):(2*y),1:x,:);
imshow(guiImage,'InitialMagnification','fit');

% Add or remove seeds

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
                filterImage = imageSettings.filterImage;
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







%% Outputs

% Segmentation label
label = getFinalLabel(markerLocations, im2uint16(imageSettings.filterImage), imageSettings);
[y,x] = size(label);
label = imresize(label, [2*y,2*x],'nearest');
label = imdilate(label, strel('square',3));
%[saveFile,path] =uiputfile('*.tif');
%imwrite(label,[path,saveFile]);
i = 1;
while i < max(max(label))
    if ~ismember(i,label)
          label = label - uint16(label > i);
    elseif ismember(i,label)
        i=i+1;
    end
end

% vertex indices
vertexNumber = 0;
cellVertices = cell(max(max(label)),1);
for i = 1:2*y-1
    for j = 1:2*x-1
        cellNumbers = unique([label(i,j),label(i+1,j),label(i,j+1),label(i+1,j+1)]);
        if length(cellNumbers) > 2
            vertexNumber = vertexNumber + 1;
            vertices{vertexNumber,1} = [i+0.5,j+0.5];
            cellNumbers = cellNumbers(cellNumbers~=0);
            for k = 1:length(cellNumbers)
                cellVertices{cellNumbers(k),1} = [cellVertices{cellNumbers(k),1},vertexNumber];
            end
        end
    end
end





save('cellVertices','cellVertices')
save('vertices','vertices')
save('label','label')


end






