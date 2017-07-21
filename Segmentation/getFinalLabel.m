function [ labelMatrix] = getFinalLabel( seeds, rawImage,imageSettings)
[y,x] = size(rawImage);
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
    for inoncell = 1:size(imageSettings.nonCellCoordinates,1)
        n = n+1;
        nonCells(n) = labelMatrix(imageSettings.nonCellCoordinates(inoncell,1),imageSettings.nonCellCoordinates(inoncell,2));
    end
end

nonCells = unique(nonCells);

for iy = 1:y
    for ix = 1:x
        n = length(nonCells);
        for icell = 1:n
            if labelMatrix(iy,ix) == nonCells(icell);
                labelMatrix(iy,ix) = 0;
            end
        end
    end
end

end
