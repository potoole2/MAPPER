function [ watershedImage ] = runWatersheds( seeds, rawImage, imageSettings )

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


seedImage= zeros(y,x);

for iseed = 1:size(seeds)
    seedImage(seeds(iseed,1),seeds(iseed,2)) = 1;
end

i2 = imimposemin(rawImage,seedImage);
labelMatrix = watershed(i2);
labelBorder = zeros(2*x+2*y,1);
labelBorder(1:x) = labelMatrix(1,1:x);
labelBorder(x+1:y+x) = labelMatrix(1:y,x)';
labelBorder(y+x+1:y+2*x) = fliplr(labelMatrix(y,1:x));
labelBorder(y+2*x+1:2*y+2*x) = fliplr(labelMatrix(1:y,1)');
n = 1;
m = 1;
nonCells(n) = labelBorder(m);

for m = 2:2*y+2*x
    if labelBorder(m) ~= nonCells(n) && labelBorder(m) ~= 0
        n = n+1;
        nonCells(n) = labelBorder(m);
    end
end

if ~isempty(imageSettings.nonCellCoordinates)
    for iNonCell = 1:size(imageSettings.nonCellCoordinates,1)
        n = n+1;
        nonCells(n) = labelMatrix(imageSettings.nonCellCoordinates(iNonCell,1),imageSettings.nonCellCoordinates(iNonCell,2));
    end
end

nonCells = unique(nonCells);


n = length(nonCells);
for icell = 1:n
    labelMatrix(labelMatrix==nonCells(icell)) = 0;
end







watershedImage = label2rgb(labelMatrix,imageSettings.colorMap,'k','shuffle');

end