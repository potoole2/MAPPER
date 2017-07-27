function r=OverlapResiduals(x0,overlaps,overlaps1,overlaps2,numchannels,numtiles,M,N,xres,yres,channelmeans)

x0((round(N/2)-1)*M+round(M/2),1:numchannels)=channelmeans;
x0((round(N/2)-1)*M+round(M/2),numchannels+1:2*numchannels)=0;

numoverlaps=size(overlaps1,5);
x1=zeros(numtiles,2*numchannels,1,1,numoverlaps);
scale = zeros(numtiles,numchannels);

    % Optimize overlap array with input parameters
    opoverlaps1=x0(:,1:numchannels).*overlaps1+x0(:,numchannels+1:2*numchannels);
    for j=1:numchannels
        for i = 1:numtiles
            for k = 1:length(overlaps(i).registration)
                x1(i,j,1,1,k)=x0(overlaps(i).registration(k),j);
                x1(i,j+numchannels,1,1,k)=x0(overlaps(i).registration(k),j+numchannels);
                

            end
        end
        scale(1:numtiles,j)=mean(mean(opoverlaps1(:,j,:)));
    end
    scale2=repmat(scale(:),xres*yres*numoverlaps,1);
    opoverlaps2=x1(:,1:numchannels,:,:,:).*overlaps2+x1(:,numchannels+1:2*numchannels,:,:,:);
    % Calculate overlap residuals for input parameters
    r= sum(((opoverlaps1(:)-opoverlaps2(:))./scale2).^2);
