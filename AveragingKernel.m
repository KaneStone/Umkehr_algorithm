function [AK] = AveragingKernel(S,Sa,Se,setup,WLP,inputs,foldersandnames,K,g,g1)

if strcmp(inputs.seasonal,'constant')
    WLP = 'C_CAP';
end

WLP = char(WLP');
date = setup.atmos.Umkehrdate;
datetoprint = [num2str(date(1)),sprintf('%02d',date(2)),sprintf('%02d',date(3))];

%output_locations and filenames
output_folder_dof = [foldersandnames.resolution,'DOF/'];
if ~exist(output_folder_dof,'dir')
    mkdir(output_folder_dof)
end

output_folder_information = [foldersandnames.resolution,'information_content/'];
if ~exist(output_folder_information,'dir')
    mkdir(output_folder_information)
end

output_folder_resolution = [foldersandnames.resolution,'resolution/'];
if ~exist(output_folder_resolution,'dir')
    mkdir(output_folder_resolution)
end

output_folder_AK = [foldersandnames.resolution,'AK/'];
if ~exist(output_folder_AK,'dir')
    mkdir(output_folder_AK)
end

file_name_resolution = strcat(inputs.station,'_',WLP,'_resolution',...
    foldersandnames.name_ext,'.txt');
file_name_dof = strcat(inputs.station,'_',WLP,'_DOF',...
    foldersandnames.name_ext,'.txt');
file_name_information = strcat(inputs.station,'_',WLP,'_information',...
    foldersandnames.name_ext,'.txt');
file_name_AK = strcat(inputs.station,'_',datetoprint,'_',WLP,'pair_','AK',...
    foldersandnames.name_ext,'.txt');

file_name_S = strcat(inputs.station,'_',WLP,'_S_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),foldersandnames.name_ext,'.txt');

%retrieval error
Ss_layers = g1*S.Ss(1:length(setup.atmos.Z),1:length(setup.atmos.Z))*g1';
Ss_layers(:,1:2) = Ss_layers(:,1:2)/10;
Ss_layers(:,3:7) = Ss_layers(:,3:7)/5;
Ss_layers(:,8) = Ss_layers(:,8)/35;

S_layers = g1*S.S(1:length(setup.atmos.Z),1:length(setup.atmos.Z))*g1';
S_layers(:,1:2) = S_layers(:,1:2)/10;
S_layers(:,3:7) = S_layers(:,3:7)/5;
S_layers(:,8) = S_layers(:,8)/35;

S_to_print = S_layers;
S_to_print2 = S.S;

AK.AK = S.S*(K'/Se*K);
AK.area=sum(AK.AK,1);
AK.AK1 = g*AK.AK(1:length(setup.atmos.Z),1:length(setup.atmos.Z))*g';
AK.AK2 = g1*AK.AK(1:length(setup.atmos.Z),1:length(setup.atmos.Z))*g1';
AK.AK2(:,1:2) = AK.AK2(:,1:2)/length(find(g1(1,:) == 1));
AK.AK2(:,3:7) = AK.AK2(:,3:7)/length(find(g1(3,:) == 1));
AK.AK2(:,8) = AK.AK2(:,8)/length(find(g1(8,:) == 1));

%Resolution
AK.resolution=1./diag(AK.AK)*(inputs.dz/1000);
res = AK.resolution;

%Degrees of Freedom for signal in Umkehr layers
AK.dof = sum(diag(AK.AK));
AK.dof1 = g1*diag(AK.AK);
AK.dof_all = diag(AK.AK);
dof = [date(1),date(2),date(3),date(4),AK.dof1',AK.dof];

%information content
H = -.5*log(det(eye(setup.atmos.nlayers)-AK.AK(1:setup.atmos.nlayers,1:setup.atmos.nlayers)));

count_start = 1;
count_end = 0;
for i = 1:8
    eye_size = length(find(g1(i,:) == 1));
    if i ~= 8
        count_end = count_end + eye_size;
    else
        count_end = setup.atmos.nlayers;
    end
    H_layer(i) = -.5*log(det(eye(eye_size)-AK.AK(count_start:count_end,count_start:count_end)));
    
    count_start = count_start+eye_size;
end

H_print = [date(1),date(2),date(3),date(4),H_layer,H];
res_print = [date(1),date(2),date(3),date(4),res'];

%backup data before printing
if exist([output_folder_dof,file_name_dof],'file')
    copyfile([output_folder_dof,file_name_dof],[foldersandnames.backup,file_name_dof,'_',...
        foldersandnames.currenttime]);
end

if exist([output_folder_resolution,file_name_resolution],'file')
    copyfile([output_folder_resolution,file_name_resolution],[foldersandnames.backup,...
        file_name_resolution,'_',foldersandnames.currenttime]);
end

if exist([output_folder_information,file_name_information],'file')
    copyfile([output_folder_information,file_name_information],[foldersandnames.backup,...
        file_name_information,'_',foldersandnames.currenttime]);
end

savevectordata([output_folder_dof,file_name_dof],dof,date,'UmkehrLayers');
savevectordata([output_folder_resolution,file_name_resolution],res_print,date,'inputresolution');
savevectordata([output_folder_information,file_name_information],H_print,date,'UmkehrLayers');

% Saving averaging kernel
AK_to_print = AK.AK1;
save(strcat(output_folder_AK, file_name_AK),'AK_to_print','-ascii');

end