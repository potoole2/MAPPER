function Optimization(M,N,tempDirectory,channels,numembs)




registration = importdata([tempDirectory 'TileConfiguration.registered.txt']);
registration = extractBetween(registration(4:size(registration)),'(',')');
for i = 1:size(registration)
    CoordinateString = extractAfter(registration{i},',');
    tileCoordinates(i,1) = str2num(CoordinateString);
    CoordinateString = extractBefore(registration{i},',');
    tileCoordinates(i,2) = str2num(CoordinateString);
end
tileCoordinates = round(tileCoordinates);
tileCoordinates(:,1) = tileCoordinates(:,1) + (1-min(tileCoordinates(:,1)));
tileCoordinates(:,2) = tileCoordinates(:,2) + (1-min(tileCoordinates(:,2)));

files = dir(tempDirectory);

for i = 1:M*N
    for j = 1:length(channels)
        tiles{i,1}(:,:,j) = imread([tempDirectory files(i+2).name],j);
    end
    tiles{i,2} = tileCoordinates(i,:);
    tiles{i,3} = tiles{i,2} + size(tiles{i,1}(:,:,1)) - 1;
end
overlapsize=0;
for i = 1:M*N
    for j = 1:M*N
        if i == j
            overlaps(i).reg(j) = 0;
        elseif ((tiles{j,2}(1) >= tiles{i,2}(1)) && ((tiles{j,2}(1) <= tiles{i,3}(1))) || ((tiles{j,3}(1) >= tiles{i,2}(1)) && ((tiles{j,3}(1) <= tiles{i,3}(1)))))...
                && ((tiles{j,2}(2) >= tiles{i,2}(2)) && ((tiles{j,2}(2) <= tiles{i,3}(2))) || ((tiles{j,3}(2) >= tiles{i,2}(2)) && ((tiles{j,3}(2) <= tiles{i,3}(2)))))
            overlaps(i).reg(j) = 1;
        else
            overlaps(i).reg(j) = 0;
        end
    end
    overlaps(i).reg = find(overlaps(i).reg);
    if length(overlaps(i).reg) > overlapsize
        overlapsize = length(overlaps(i).reg);
    end
end



overlaps1 = zeros(M*N,length(channels),20,20,overlapsize);
overlaps2 = zeros(M*N,length(channels),20,20,overlapsize);
for i= 1:M*N
    for k = 1:length(overlaps(i).reg)
        if tiles{overlaps(i).reg(k),2}(1) <= tiles{i,2}(1)
            i1 = 1;
        elseif tiles{overlaps(i).reg(k),2}(1) > tiles{i,2}(1)
            i1 = tiles{overlaps(i).reg(k),2}(1) - tiles{i,2}(1) + 1;
        end
        if tiles{overlaps(i).reg(k),2}(2) <= tiles{i,2}(2)
            j1 = 1;
        elseif tiles{overlaps(i).reg(k),2}(2) > tiles{i,2}(2)
            j1 = tiles{overlaps(i).reg(k),2}(2) - tiles{i,2}(2) + 1;
        end
        if tiles{overlaps(i).reg(k),3}(1) >= tiles{i,3}(1)
            i2 = tiles{i,3}(1) - tiles{i,2}(1) + 1;
        elseif tiles{overlaps(i).reg(k),3}(1) < tiles{i,3}(1)
            i2 = tiles{overlaps(i).reg(k),3}(1) - tiles{i,2}(1) + 1;
        end
        if tiles{overlaps(i).reg(k),3}(2) >= tiles{i,3}(2)
            j2 = tiles{i,3}(2) - tiles{i,2}(2) + 1;
        elseif tiles{overlaps(i).reg(k),3}(2) < tiles{i,3}(2)
            j2 = tiles{overlaps(i).reg(k),3}(2) - tiles{i,2}(2) + 1;
        end
        for h = 1:length(channels)
            overlaps1(i,h,:,:,k) = imresize(double(tiles{i,1}(i1:i2,j1:j2,h)),[20 20],'bicubic');
        end
    end
end
for i=1:M*N
    for j = 1: length(overlaps(i).reg)
        overlaps2(i,:,:,:,j) = overlaps1(overlaps(i).reg(j),:,:,:,find(overlaps(overlaps(i).reg(j)).reg == i));
    end
end



chan = length(channels);


x0=[ones(M*N,length(channels)) zeros(M*N,length(channels))];
x = fminsearch(@OverlapResiduals,x0,optimset('MaxFunEvals',100),overlaps,overlaps1,overlaps2,chan);

for i = 1:M*N
    for j = 1:length(channels)
        tiles{i,1}(:,:,j) = tiles{i,1}(:,:,j).*x(i,j) + x(i,j + chan);
        if j == 1
            imwrite(tiles{i,1}(:,:,j),[tempDirectory 'Optimized Tile ' num2str(i,'%05d') '.TIF'])
        else
            imwrite(tiles{i,1}(:,:,j),[tempDirectory 'Optimized Tile ' num2str(i,'%05d') '.TIF'],'writemode','append')
        end
    end
end



