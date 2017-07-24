function r=OverlapResiduals(x0,overlaps,overlaps1,overlaps2,chan)




opoverlaps1=x0(:,1:chan).*overlaps1+x0(:,chan+1:2*chan);
for i=1:36
    for j = 1:4
        for k = 1:length(overlaps(i).reg)
        x1(i,j,1,1,k)=x0(overlaps(i).reg(k),j);
        x1(i,j+chan,1,1,k)=x0(overlaps(i).reg(k),j+chan);
        end
    end
end
opoverlaps2=x1(:,1:chan,:,:,:).*overlaps2+x1(:,chan+1:2*chan,:,:,:);
r= sum((opoverlaps1(:)-opoverlaps2(:)).^2);
