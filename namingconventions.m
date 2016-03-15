function [foldersandnames] = namingconventions(inputs,foldersandnames)

%OUTPUT folders are not complete
foldersandnames.retrievals = '../OUTPUT/retrievals/';
foldersandnames.resolution = '../OUTPUT/resolution/';
foldersandnames.diagnostics = '../OUTPUT/diagnostics/';
foldersandnames.logfiles = '../OUTPUT/logfiles/';
%adding paths for support code
addpath('SupportCode/splineFit/')
addpath('SupportCode/exportFig/')
addpath('SupportCode/herrorbar/')

% Defining file names 
foldersandnames.name_ext = [];
ext_start = 1;
if inputs.designated_SZA
    foldersandnames.name_ext(ext_start:ext_start+5) = '_desig';
    ext_start = ext_start+6;
end
if strcmp(inputs.covariance_type,'full_covariance')
    foldersandnames.name_ext(ext_start:ext_start+2) = '_FC';
    ext_start = ext_start+3;
elseif strcmp(inputs.covariance_type,'constant')
    foldersandnames.name_ext(ext_start:ext_start+8) = '_constant';
    ext_start = ext_start+9;
end
if inputs.test_cloud_effect
    foldersandnames.name_ext(ext_start:ext_start+3) = '_TCE';
    ext_start = ext_start+4;
end
if inputs.SZA_limit ~= 94 && ~inputs.designated_SZA;
    foldersandnames.name_ext(ext_start:ext_start+2) = strcat('_',num2str(inputs.SZA_limit));
end

end
