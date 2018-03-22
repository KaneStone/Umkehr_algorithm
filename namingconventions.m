function [foldersandnames] = namingconventions(inputs)

%output folders are not complete
foldersandnames.retrievals = '../output/retrievals/';
if ~exist(foldersandnames.retrievals,'dir')
    mkdir('../output/retrievals/')
end

foldersandnames.resolution = '../output/resolution/';
if ~exist(foldersandnames.retrievals,'dir')
    mkdir('../output/resolution/');
end

foldersandnames.diagnostics = '../output/diagnostics/';
if ~exist(foldersandnames.retrievals,'dir')
    mkdir('../output/diagnostics/');
end

foldersandnames.logfiles = '../output/logfiles/';
if ~exist(foldersandnames.retrievals,'dir')
    mkdir('../output/logfiles/');
end

foldersandnames.backup = '../output/backup/';
if ~exist(foldersandnames.backup,'dir')
    mkdir('../output/backup/');
end

%adding paths for support code
addpath('SupportCode/splineFit/')
addpath('SupportCode/exportFig/')
addpath('SupportCode/herrorbar/')

% Defining file names 
foldersandnames.name_ext = [];
ext_start = 1;

% designated solar zenith angle
if inputs.designated_SZA
    foldersandnames.name_ext(ext_start:ext_start+5) = '_desig';
    ext_start = ext_start+6;    
end

% A priori
ap = {'full_covariance_constant','_FCC';'full_covariance','_FC';'full_covarianceSD','_FCSD';...
    'diagonal_constant','_DC';'diagonal','_D';'diagonal_SD','_DSD'};
for i = 1:size(ap,1)
    if strcmp(inputs.covariance_type,ap{i,1}) 
        namelength = length(ap{i,2});
        foldersandnames.name_ext(ext_start:ext_start+namelength-1) = ap{i,2};        
        ext_start = ext_start+namelength;
    end
end

%morning or evening
moe = {'Morning','_M';'Evening','_E';'Both','_B'};
for i = 1:size(moe,1)
    if strcmp(inputs.morn_or_even,moe{i,1});
        namelength = length(moe{i,2});
        foldersandnames.name_ext(ext_start:ext_start+namelength-1) = moe{i,2};        
        ext_start = ext_start+namelength;
    end
end

% upper limit of solar zenith angle
if ~inputs.designated_SZA;
    foldersandnames.name_ext(ext_start:ext_start+2) = strcat('_',num2str(inputs.SZA_limit));
    ext_start = ext_start+length(num2str(inputs.SZA_limit))+1;
end

% Altitude limit and dz
namelength = length(strcat('_',num2str(inputs.maximum_altitude/1000),...
    num2str(inputs.dz/1000)));
foldersandnames.name_ext(ext_start:ext_start+namelength-1) = strcat('_',num2str(inputs.maximum_altitude/1000),...
    num2str(inputs.dz/1000));
ext_start = ext_start+namelength;

foldersandnames.name_ext = char(foldersandnames.name_ext);

end
