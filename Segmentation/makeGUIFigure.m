function [ GUIScreen ] = makeGUIFigure( seeds, rawImage, imageSettings )
% rawImage is the top image
% watershedImage is the bottom image
% imageSettings is a settings file, use [] for default settings

[y,x] = size(rawImage);

if isempty(imageSettings)
    imageSettings.zoomCoordinates = uint16([y/2,x/2]);
    imageSettings.magnification = 5;
    imageSettings.colorMap = 'parula';
    imageSettings.addCellCoordinates = [];
    imageSettings.nonCellCoordinates = [];
    imageSettings.runBorder = 0;
    imageSettings.runWatershed = 1;
    imageSettings.recenter = 0;
    imageSettings.showFilter = 0;
    imageSettings.filterBrightness = 100;
    imageSettings.rawBrightness = 100;
end

if imageSettings.showFilter == 1;
    
    rawWithSeeds = uint16(insertMarker(im2uint16(imageSettings.filterImage),fliplr(seeds),'+','Color',[prctile((im2uint16(imageSettings.filterImage(:))),100) prctile((im2uint16(imageSettings.filterImage(:))),0) prctile((im2uint16(imageSettings.filterImage(:))),0)],'Size',1));
    rawWithSeeds = (65536/prctile(rawWithSeeds(:),imageSettings.filterBrightness))*rawWithSeeds;
    filterSetting = 'ON';
elseif imageSettings.showFilter == 0;
    rawWithSeeds = uint16(insertMarker(rawImage,fliplr(seeds),'+','Color',[prctile((rawImage(:)),100) prctile(rawImage(:),0) prctile(rawImage(:),0)],'Size',1));
    rawWithSeeds = (65536/prctile(rawWithSeeds(:),imageSettings.rawBrightness))*rawWithSeeds;
    filterSetting = 'OFF';
end


rawWithSeeds = uint8(rawWithSeeds/256);

if imageSettings.runWatershed == 1;
    watershedImage = runWatersheds(seeds, im2uint16(imageSettings.filterImage), imageSettings);
    watershedSetting = 'ON';
elseif imageSettings.runWatershed == 0;
    watershedImage = imageSettings.watershedImage;
    watershedSetting = 'OFF';
end
if imageSettings.runBorder == 1;
    borderSetting = 'ON';
    for iy = 1:y
        for ix = 1:x
            if watershedImage(iy,ix) == 0
                rawWithSeeds(iy,ix,1) = 256;
                rawWithSeeds(iy,ix,2) = 256;
                rawWithSeeds(iy,ix,3) = 256;
            end
        end
    end
elseif imageSettings.runBorder == 0;
    borderSetting = 'OFF';
end
if imageSettings.recenter == 1;
    recenterSetting = 'ON';
elseif imageSettings.recenter == 0;
    recenterSetting = 'OFF';
end





textWidth = round(3*y/5);
GUIScreen = zeros(2*y,x+y+textWidth,3);

leftTop = imageSettings.zoomCoordinates - y/(imageSettings.magnification*2);
rightBottom = imageSettings.zoomCoordinates + y/(imageSettings.magnification*2);
leftTop = round(leftTop);
rightBottom = round(rightBottom);

zoomRaw = rawWithSeeds(leftTop(1):rightBottom(1),leftTop(2):rightBottom(2),1:3);
zoomWater = watershedImage(leftTop(1):rightBottom(1),leftTop(2):rightBottom(2),1:3);


GUIScreen(1:y,1:x,:) = rawWithSeeds;
GUIScreen((y+1):(2*y),1:x,:) = watershedImage;
GUIScreen(1:y,(x+1):(x+y),:) = imresize(zoomRaw,[y,y]);
GUIScreen((y+1):(2*y),(x+1):(x+y),:) = imresize(zoomWater,[y,y],'nearest');
GUIScreen(1:2*y,x+y+1:x+y+textWidth,:) = 255;
if round(y/30) <= 72
    GUIScreen(1:2*y,x+y+1:x+y+textWidth,:) = insertText(GUIScreen(1:2*y,x+y+1:x+y+textWidth,:),...
        [ y/50 0; y/50 2*y/25; y/50 4*y/25; y/50 5*y/25; y/50 7*y/25; y/50 9*y/25; y/50 11*y/25; y/50 12*y/25; y/50 14*y/25 ; y/50 16*y/25 ; y/50 18*y/25; y/50 20*y/25; y/50 22*y/25; y/50 23*y/25; y/50 25*y/25; y/50 27*y/25; y/50 29*y/25; y/50 33*y/25; y/50 37*y/25; y/50 41*y/25; y/50 45*y/25],...
        {'Left click adds seed','Right click removes seed','Middle click marks','non-cellular regions','B toggles borders','R toggles watersheds','M toggles magnified image','recentering','F toggles filtering','L toggles border addition mode','Q increases magnification','E decreases magnification','Arrow keys move magnified','images up, left, down, right','Z saves current seeds','DELETE resets segmentation','Space displays output',['Borders: ',borderSetting],['Running watersheds: ',watershedSetting],['Magnified image recentering: ',recenterSetting],['Anisotropic filtering: ',filterSetting]},...
        'FontSize',round(y/30),'TextColor','black','BoxColor','white','BoxOpacity',0);
elseif round(y/30) > 72
    GUIScreen(1:2*y,x+y+1:x+y+textWidth,:) = insertText(GUIScreen(1:2*y,x+y+1:x+y+textWidth,:),...
        [ y/50 0; y/50 2*y/25; y/50 4*y/25; y/50 5*y/25; y/50 7*y/25; y/50 9*y/25; y/50 11*y/25; y/50 12*y/25; y/50 14*y/25 ; y/50 16*y/25 ; y/50 18*y/25; y/50 20*y/25; y/50 22*y/25; y/50 23*y/25; y/50 25*y/25; y/50 27*y/25; y/50 29*y/25; y/50 33*y/25; y/50 37*y/25; y/50 41*y/25; y/50 45*y/25],...
        {'Left click adds seed','Right click removes seed','Middle click marks','non-cellular regions','B toggles borders','R toggles watersheds','M toggles magnified image','recentering','F toggles filtering','L toggles border addition mode','Q increases magnification','E decreases magnification','Arrow keys move magnified','images up, left, down, right','Z saves current seeds','DELETE resets segmentation','Space displays output',['Borders: ',borderSetting],['Running watersheds: ',watershedSetting],['Magnified image recentering: ',recenterSetting],['Anisotropic filtering: ',filterSetting]},...
        'FontSize',round(y/30),'TextColor','black','BoxColor','white','BoxOpacity',0);
end
GUIScreen = uint8(GUIScreen);






end