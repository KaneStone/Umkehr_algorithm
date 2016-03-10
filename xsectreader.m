function [ozonexs] = xsectreader(inputs,atmos,lambda)

%Reads in the ozone cross sections for three different cross section
%studies:

%Bass-Paur (Bass et al., 1985) 
%Brion-Daumont-Malicet (Daumont et al. 1992)
%Gorshelev (Gorshelev et al., 2014)
    
if strcmp(inputs.cross_section,'BP');
    %Bass-Paur
    
    BPfolder = '../input/ForwardModelProfiles/ozonexs/BassPaur/';
    BPfiles = dir([BPfolder,'*.dat']);
    xsection.sigma = [];
    for i = 1:length(BPfiles);
        fid = fopen(strcat(BPfolder,BPfiles(i,1).name));
        xsection.temperature(i) = fscanf(fid,'%f',1);
        xs = fscanf(fid,'%f',[2,inf]);
        xsection.sigma = [xsection.sigma; xs(2,:)];
        fclose (fid);
    end
    
    xsection.wavelength = xs(1,:);    
    
elseif strcmp(inputs.cross_section,'BDM');
    %Brion-Daumont-Malicet
    
    BDMfolder = '../input/ForwardModelProfiles/ozonexs/BrionDaumontMalicet/';
    BDMfiles = dir([BDMfolder,'*.dat']);
    xsection.sigma = [];
  
    for i = 1:length(BDMfiles);
        fid = fopen(strcat(BDMfolder,BDMfiles(i,1).name));
        info = fscanf(fid,'%s',[1,12]);
        xsection.temperature(i) = fscanf(fid,'%f',1);
        xs = fscanf(fid,'%f',[2,inf]);
        lowlambda = find(xs(1,:) == 2995);
        highlambda = find(xs(1,:) == 4000);
        xsection.sigma = [xsection.sigma; xs(2, lowlambda:highlambda)];                               
        fclose (fid);
    end

    xsection.wavelength = xs(1,lowlambda:highlambda)/10;    

elseif strcmp(inputs.cross_section,'G');
    %Gorshelev
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

temphold = interp1(xsection.temperature,xsection.sigma,atmos.temperature,'linear','extrap'); 
ozonexs = interp1(xsection.wavelength,temphold',lambda,'linear','extrap');    

end