clc
clear

files = dir('C:\Users\Rental\Downloads\RawData\RawData\t075\');

filename = 'CycE dpERK PH3';
chan = [405 488 561 640];

zstacks = 71;
tiles = 468;
channels = 4;
for filenum = 1:length(files)
    names{filenum} = files(filenum).name;
end


mkdir('C:\Users\Rental\Documents\10.21.14\CycE dpERK PH3\','Data')

for tilenum = 1:tiles
    for channum = 1:channels
        movefile(['C:\Users\Rental\Documents\10.21.14\CycE dpERK PH3\' files(find(~cellfun(@isempty,strfind(names,[filename ' ' num2str((tilenum),'%04d') '_w' num2str(channum) 'Confocal ' num2str(chan(channum)) '.TIF'])))).name ],...
            ['C:\Users\Rental\Documents\10.21.14\CycE dpERK PH3\Data\' filename ' ' num2str((tilenum),'%04d') '_w' num2str(channum) 'Confocal ' num2str(chan(channum)) '.TIF' ]);
    end
end




