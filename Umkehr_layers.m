function [g, g1, result, errorresult] = Umkehr_layers(setup,WLP,inputs,xhat,S,date,foldersandnames)

WLP = char(WLP');

DU_coeff = 1e5*1.38e-21*1e3*(273.1/10.13);
layers = 5;

g(1,1:length(setup.atmos.Z)) = horzcat(ones(1,layers),...
    zeros(1,length(setup.atmos.Z)-layers));
for k = 1:length(setup.atmos.Z)/layers-1
    g(k+1,:) = circshift(g(1,:),[0 layers*(k)]);
end

%creating layering system
g1 = zeros(8,(setup.atmos.nlayers));
Umkehrlayerend = [10,20,25,30,35,40,45];
for i = 1:length(Umkehrlayerend-1)
    layerindex(i) = find(setup.atmos.Z == Umkehrlayerend(i)*1000);
    %layerindex(i) = find(setup.atmos.Z <= Umkehrlayerend(i)*1000 & setup.atmos.Z <= Umkehrlayerend(i)*1000);
    if i == 1
        g1(i,1:layerindex(i)-1) = 1;
    else
        g1(i,layerindex(i-1):layerindex(i)-1) = 1;
    end
end
g1(8,layerindex(i):end) = 1;

%putting retrieval and errors into layering system
Scol = g1*S.S(1:end,1:end)*g1';
Scolerrors = diag((Scol).^.5);
Scolerrors1 = Scolerrors.*DU_coeff*(inputs.dz/1000);
xhat_layer = DU_coeff.*xhat(1:end)*(inputs.dz/1000);
xhat_layer1 = g1*xhat_layer';
totalozone = sum(xhat_layer1);

%extracting errors for input resolution
Scolall = diag(S.S).^.5;

%extracting total column errors
Total_column_errors = (sum(diag(S.S))).^.5*DU_coeff*(inputs.dz/1000);

%putting into arrays for writing
result = [date(1),date(2),date(3),date(4),xhat_layer1',totalozone];
errorresult = [date(1),date(2),date(3),date(4),Scolerrors1',Total_column_errors];
resultall = [date(1),date(2),date(3),date(4),xhat];
errorresultall = [date(1),date(2),date(3),date(4),Scolall'];

%Saving retrieval
outputfolder = strcat(foldersandnames.retrievals,inputs.station,'/',WLP,'/');

filenameUmkehrlayers = [inputs.station,'_',WLP,foldersandnames.name_ext,'_Umkehrlayers.txt'];
filenameUmkehrerror = [inputs.station,'_',WLP,foldersandnames.name_ext,'_Umkehrlayers_error.txt'];
filename = [inputs.station,'_',WLP,foldersandnames.name_ext,'.txt'];
filenameerror = [inputs.station,'_',WLP,foldersandnames.name_ext,'_error.txt'];

if ~exist(strcat(outputfolder),'dir')
    mkdir(outputfolder);
end

%backing up date
if exist([outputfolder,filenameUmkehrlayers],'file')
    copyfile([outputfolder,filenameUmkehrlayers],[foldersandnames.backup,filenameUmkehrlayers,'_',...
        foldersandnames.currenttime]);
end

if exist([outputfolder,filenameUmkehrerror],'file')
    copyfile([outputfolder,filenameUmkehrerror],[foldersandnames.backup,filenameUmkehrerror,'_',...
        foldersandnames.currenttime]);
end

if exist([outputfolder,filename],'file')
    copyfile([outputfolder,filename],[foldersandnames.backup,filename,'_',...
        foldersandnames.currenttime]);
end

if exist([outputfolder,filenameerror],'file')
    copyfile([outputfolder,filenameerror],[foldersandnames.backup,filenameerror,'_',...
        foldersandnames.currenttime]);
end

savevectordata([outputfolder,filenameUmkehrlayers],result,date,'UmkehrLayers');
savevectordata([outputfolder,filenameUmkehrerror],errorresult,date,'UmkehrLayers');
savevectordata([outputfolder,filename],resultall,date,'inputresolution');
savevectordata([outputfolder,filenameerror],errorresultall,date,'inputresolution');

end
