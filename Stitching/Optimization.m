function Optimization(M,N,tempDirectory,channels,embnum)



% Find tile coordinates
registration = importdata([tempDirectory 'TileConfiguration' num2str(embnum) '.registered.txt']);
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

% Generate cell array with raw tiles, coordinates of top left tile corner,
% and coordinates of bottom right tile corner
files = dir(tempDirectory);
for i = 1:M*N
    for j = 1:length(channels)
        tiles{i,1}(:,:,j) = imread([tempDirectory 'Tile ' num2str(i+M*N*(embnum-1),'%05d'),'.TIF'],j);
    end
    tiles{i,2} = tileCoordinates(i,:);
    tiles{i,3} = tiles{i,2} + size(tiles{i,1}(:,:,1)) - 1;
end

% Generate struct that contains information about which tiles overlap
overlapsize=0;
for i = 1:M*N
    for j = 1:M*N
        if i == j
            overlaps(i).registration(j) = 0;
        elseif ((tiles{j,2}(1) >= tiles{i,2}(1)) && ((tiles{j,2}(1) <= tiles{i,3}(1))) || ((tiles{j,3}(1) >= tiles{i,2}(1)) && ((tiles{j,3}(1) <= tiles{i,3}(1)))))...
                && ((tiles{j,2}(2) >= tiles{i,2}(2)) && ((tiles{j,2}(2) <= tiles{i,3}(2))) || ((tiles{j,3}(2) >= tiles{i,2}(2)) && ((tiles{j,3}(2) <= tiles{i,3}(2)))))
            overlaps(i).registration(j) = 1;
        else
            overlaps(i).registration(j) = 0;
        end
    end
    overlaps(i).registration = find(overlaps(i).registration);
    if length(overlaps(i).registration) > overlapsize
        overlapsize = length(overlaps(i).registration);
    end
end


% Generate arrays of overlaps
res=20;
xres=res;
yres=res;
overlaps1 = zeros(M*N,length(channels),xres,yres,overlapsize);
overlaps2 = zeros(M*N,length(channels),xres,yres,overlapsize);
for i= 1:M*N
    for k = 1:length(overlaps(i).registration)
        if tiles{overlaps(i).registration(k),2}(1) <= tiles{i,2}(1)
            i1 = 1;
        elseif tiles{overlaps(i).registration(k),2}(1) > tiles{i,2}(1)
            i1 = tiles{overlaps(i).registration(k),2}(1) - tiles{i,2}(1) + 1;
        end
        if tiles{overlaps(i).registration(k),2}(2) <= tiles{i,2}(2)
            j1 = 1;
        elseif tiles{overlaps(i).registration(k),2}(2) > tiles{i,2}(2)
            j1 = tiles{overlaps(i).registration(k),2}(2) - tiles{i,2}(2) + 1;
        end
        if tiles{overlaps(i).registration(k),3}(1) >= tiles{i,3}(1)
            i2 = tiles{i,3}(1) - tiles{i,2}(1) + 1;
        elseif tiles{overlaps(i).registration(k),3}(1) < tiles{i,3}(1)
            i2 = tiles{overlaps(i).registration(k),3}(1) - tiles{i,2}(1) + 1;
        end
        if tiles{overlaps(i).registration(k),3}(2) >= tiles{i,3}(2)
            j2 = tiles{i,3}(2) - tiles{i,2}(2) + 1;
        elseif tiles{overlaps(i).registration(k),3}(2) < tiles{i,3}(2)
            j2 = tiles{overlaps(i).registration(k),3}(2) - tiles{i,2}(2) + 1;
        end
        for h = 1:length(channels)
            overlaps1(i,h,:,:,k) = imresize(double(tiles{i,1}(i1:i2,j1:j2,h)),[xres yres],'bicubic');
        end
    end
end
for i=1:M*N
    for j = 1: length(overlaps(i).registration)
        overlaps2(i,:,:,:,j) = overlaps1(overlaps(i).registration(j),:,:,:,find(overlaps(overlaps(i).registration(j)).registration == i));
    end
end
% Find a and b parameters for optimization by minimizing overlap residuals

for j=1:length(channels)
    for i = 1:M*N
         means(i,j)=  mean(mean(tiles{i,1}(:,:,j)));
    end
    means(:,j) = mean(means(:,j))./means(:,j);
end

numchannels = length(channels);
numtiles =length(tiles);
x0=[ones(M*N,length(channels)).*means zeros(M*N,length(channels))];



channelmeans = means((round(N/2)-1)*M+round(M/2),1:numchannels);

x = fminsearch(@OverlapResiduals_mex,x0,optimset('MaxFunEvals',100000),overlaps,overlaps1,overlaps2,numchannels,numtiles,M,N,xres,yres,channelmeans);
x((round(N/2)-1)*M+round(M/2),1:numchannels)=means((round(N/2)-1)*M+round(M/2),1:numchannels);
x((round(N/2)-1)*M+round(M/2),numchannels+1:2*numchannels)=0;

% Apply and b parameters to raw tiles and save optimized tiles
for i = 1:M*N
    for j = 1:numchannels
        tiles{i,1}(:,:,j) = tiles{i,1}(:,:,j).*x(i,j) + x(i,j + numchannels);
        if j == 1
            imwrite(tiles{i,1}(:,:,j),[tempDirectory 'Optimized Tile ' num2str(i+M*N*(embnum-1),'%05d') '.TIF'])
        else
            imwrite(tiles{i,1}(:,:,j),[tempDirectory 'Optimized Tile ' num2str(i+M*N*(embnum-1),'%05d') '.TIF'],'writemode','append')
        end
    end
end



