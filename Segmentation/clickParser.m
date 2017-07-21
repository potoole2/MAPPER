function [ clickCoordinates ] = clickParser( initialClick, rawImage, imageSettings )
% Parses clicks for a 2x2 where the left is full resolution and the right
% is magnified 10x

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

isTop = initialClick(1) <= y;
isLeft = initialClick(2) <= x;

if isLeft&&isTop % Quadrant II, no zoom
    coordinates(1) = initialClick(1);
    coordinates(2) = initialClick(2);
elseif isLeft&&~isTop % Quadrant III, no zoom
    coordinates(1) = initialClick(1)-y;
    coordinates(2) = initialClick(2);
elseif ~isLeft&&isTop % Quadrant I, yes zoom
    tempClick = initialClick - [0,x];
    distanceRightDown = (tempClick - [y/2,y/2]) / imageSettings.magnification;
    coordinates = distanceRightDown + double(imageSettings.zoomCoordinates);
elseif ~isLeft&&~isTop % Quadrant IV, yes zoom
    tempClick = initialClick - [y,x];
    distanceRightDown = (tempClick - [y/2,y/2]) / imageSettings.magnification;
    coordinates = distanceRightDown + double(imageSettings.zoomCoordinates);
else
    error('Click Parser cannot identify a valid quadrant for the click');
end

clickCoordinates = round(coordinates);

if initialClick(1) < 0 || initialClick(2) < 0 || initialClick(1) > 2*y || initialClick(2) > x + y
    clickCoordinates  = [];
end

end