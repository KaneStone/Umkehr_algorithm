function [xs] = xsectreader(folder)

%Reads in the ozone cross sections for three different cross section
%studies:

%Bass-Paur (Bass et al., 1985) 
%Brion-Daumont-Malicet (Daumont et al. 1992)
%Serdyuchenko Gorshelev et al., 2014)
    
%Bass-Paur
BPfiles = dir(strcat(folder,'Bass-Paur/','*.dat'));
BPtemp = zeros(1,length(BPfiles));
s(1,length(BPfiles)).s = zeros(1,1956);

for i = 1:length(BPfiles);
    fid = fopen(strcat(folder,'Bass-Paur/',BPfiles(i,1).name));
    BPtemp(i) = fscanf(fid,'%f',1);
    BPsect = fscanf(fid,'%f',[2,inf]);
    s(i).s = BPsect(2,:);
    fclose (fid);
end

xs.BPsigma = vertcat(s.s);
xs.BPwl = BPsect(1,:);
xs.BPtemp = BPtemp;

%Brion-Daumont-Malicet
BDMfiles = dir(strcat(folder,'Brion-Daumont-Malicet/','*.dat'));
BDMtemp = zeros(1,length(BDMfiles));
r(1,length(BDMfiles)).r = zeros(1,45553);
f = zeros(1,length(BDMfiles));
l = zeros(1,length(BDMfiles));

for i = 1:length(BDMfiles);
    fid = fopen(strcat(folder,'Brion-Daumont-Malicet/',BDMfiles(i,1).name));
    info = fscanf(fid,'%s',[1,12]);
    BDMtemp(i) = fscanf(fid,'%f',1);
    BDMsect = fscanf(fid,'%f',[2,inf]);
    f(i) = find(BDMsect(1,:) == 2995);
    l(i) = find(BDMsect(1,:) == 4000); %3427.8);
    r(i).r = BDMsect(2,f(1,i):l(1,i));
    fclose (fid);
end

xs.BDMsigma = vertcat(r.r);
xs.BDMwl = BDMsect(1,f(1,i):l(1,i))/10; %putting into nm
xs.BDMtemp = BDMtemp;

%Serdyuchenko
Sfiles = dir(strcat(folder,'Serdyuchenko/','*.dat'));
Stemp = zeros(1,11);

fid = fopen(strcat(folder,'Serdyuchenko/',Sfiles(1,1).name));
info = fgetl(fid);
tic
a = 1;
b = 1;
while a <= 44;
    info = fgetl(fid);
    if a >= 28 && a <= 38
        Stemp(1,b) = str2double(info(50:52));
        b = b+1;
    end
    a = a+1;
end
Ssect = fscanf(fid,'%f',[12,inf]);
fclose (fid);

xs.Ssigma = Ssect(2:12,:);
xs.Swl = Ssect(1,:);
xs.Stemp = Stemp;

end