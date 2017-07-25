function r=OverlapResiduals(x0,overlaps,overlaps1,overlaps2,chan,M,N,xres,yres)

x0((round(N/2)-1)*M+round(M/2),1:chan)=1;
x0((round(N/2)-1)*M+round(M/2),chan+1:2*chan)=0;

    
    % Optimize overlap array with input parameters
    opoverlaps1=x0(:,1:chan).*overlaps1+x0(:,chan+1:2*chan);
    for j=1:4
        for i = 1:36
            for k = 1:length(overlaps(i).registration)
                x1(i,j,1,1,k)=x0(overlaps(i).registration(k),j);
                x1(i,j+chan,1,1,k)=x0(overlaps(i).registration(k),j+chan);
                
%                 scale2(1:36,j)=mean(mean(opoverlaps1(:,j,:)));
            end
        end
        scale(1:36,j)=mean(mean(opoverlaps1(:,j,:)));
    end
    scale2=repmat(scale(:),xres*yres*9,1);
    opoverlaps2=x1(:,1:chan,:,:,:).*overlaps2+x1(:,chan+1:2*chan,:,:,:);
    % Calculate overlap residuals for input parameters
    r= sum(((opoverlaps1(:)-opoverlaps2(:))./scale2).^2);
