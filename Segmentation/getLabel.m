function [ labelMatrix] = getLabel( seeds, rawImage )
[y,x] = size(rawImage);
seedImage= zeros(y,x);

for iseed = 1:size(seeds)
    seedImage(seeds(iseed,1),seeds(iseed,2)) = 1;
end

i2 = imimposemin(rawImage,seedImage);
labelMatrix = watershed(i2);

end
