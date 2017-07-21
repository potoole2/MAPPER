function r=testfunctionnew(x0,overlaps,overlaps1,chan)




opoverlaps1=x0(:,1:chan).*overlaps1+x0(:,chan+1:2*chan);
for i=1:36
    for j = 1: length(overlaps(i).reg)
        opoverlaps2(i,:,:,:,j) = opoverlaps1(overlaps(i).reg(j),:,:,:,find(overlaps(overlaps(i).reg(j)).reg == i));
    end
end
r=sumsqr(opoverlaps1-opoverlaps2)
% r = 0;
% for i = 1:length(overlaps)
%     for j =1:length(overlaps(i).reg(overlaps(i).reg > i))
%         a = overlaps(i).op(:,overlaps(i).reg > i);
%         b = overlaps(i).reg(overlaps(i).reg > i);
%         c = overlaps(b(j)).op(:,overlaps(b(j)).reg ==i);
%         for k = 1:length(channels)
%             r = r + sumsqr(c{k}-a{k,j});
%         end
%     end
% end
% r
%
%


% for i = 1:N
%     for j = 1:M
%         if j == 1
%             overlaps((i-1)*N+j).left = [];
%         elseif i ~= 1
%             overlaps((i-1)*N+j).left =
%         end
%         if j == M
%             overlaps((i-1)*N+j).right = [];
%         elseif i ~= M
%             overlaps((i-1)*N+j).right =
%         end
%         if j == 1
%             overlaps((i-1)*N+j).up = [];
%         elseif i ~= 1
%             overlaps((i-1)*N+j).up =
%         end
%         if j == M
%             overlaps((i-1)*N+j).down = [];
%         elseif i ~= M
%             overlaps((i-1)*N+j).down =
%         end
%     end
% end

% a1=x0(1);
% a2=x0(2);
% a3=x0(3);
% b1=x0(4);
% b2=x0(5);
% b3=x0(6);
% tile1 = importdata('C:\Users\Owner\Downloads\premosa_dataset-master\premosa_dataset-master\RawData\t075\zproj\Premosa 0001_w1Confocal 1_MIP.tif');
% tile2 = importdata('C:\Users\Owner\Downloads\premosa_dataset-master\premosa_dataset-master\RawData\t075\zproj\Premosa 0002_w1Confocal 1_MIP.tif');
% tile3 = importdata('C:\Users\Owner\Downloads\premosa_dataset-master\premosa_dataset-master\RawData\t075\zproj\Premosa 0003_w1Confocal 1_MIP.tif');
%
% overlap1=double(tile1(4:520,642:692));
% overlap2=double(tile2(1:517,1:51));
% overlap3=double(tile2(4:520,647:692));
% overlap4=double(tile3(1:517,1:46));
%
% I1 = overlap1.*a1 - b1;
% I2 = overlap2.*a2 - b2;
% I3 = overlap3.*a2 - b2;
% I4 = overlap4.*a3 - b3;
%
% scale = double(max(max([tile1 tile2 tile3]))/max(max([I1 I2 I3 I4])));
%
% I1 = I1*scale;
% I2 = I2*scale;
% I3 = I3*scale;
% I4 = I4*scale;
%
% r = norm((I1-I2).^2) + norm((I3-I4).^2);


