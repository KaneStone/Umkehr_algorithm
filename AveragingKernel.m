function [AK] = AveragingKernel(S,Sa,Se,extra,K,g,g1,station,measurement_number,seasonal)

if strcmp(seasonal,'constant');
    WLP = 'C_CAP';
else WLP = extra.atmos.N_values(measurement_number).WLP;
end
date = extra.atmos.date(measurement_number).date;

%output_locations and filenames
output_folder_res = extra.output_resolution;
output_folder_AK = strcat(extra.output_retrievals,station,'/',WLP,'/AK/',...
    sprintf('%d',date(3)),'/');
if ~exist(output_folder_res,'dir')
    mkdir(output_folder_res)
end
if ~exist(output_folder_AK,'dir')
    mkdir(output_folder_AK)
end
file_name_res = strcat(station,'_res_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt');
file_name_dof = strcat(station,'_dof_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt');
file_name_H = strcat(station,'_H_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt');
file_name_AK = strcat(station,'_',WLP,'_AK_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt');
file_name_S = strcat(station,'_',WLP,'_S_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt');

Ss_layers = g1*S.Ss(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
Ss_layers(:,1:2) = Ss_layers(:,1:2)/10;
Ss_layers(:,3:7) = Ss_layers(:,3:7)/5;
Ss_layers(:,8) = Ss_layers(:,8)/35;

S_layers = g1*S.S(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
S_layers(:,1:2) = S_layers(:,1:2)/10;
S_layers(:,3:7) = S_layers(:,3:7)/5;
S_layers(:,8) = S_layers(:,8)/35;

S_to_print = S_layers;
S_to_print2 = S.S;
save(strcat(output_folder_res, file_name_S),'S_to_print','-ascii');
save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/AK_for_testing_dof/S/',file_name_S),'S_to_print2','-ascii');
% %diagnostic code - remove after
% figure;
% fig = gcf;
% set(fig,'color','white','position',[100 100 1000 700]);
% ag = plot(Ss_layers,1:8,'LineWidth',2);
% title('Ss','fontsize',22);
% set(gca,'yticklabel',{'0+1';'2+3';'4';'5';'6';'7';'8';'9+'},'fontsize',18);
% ylabel('Umkehr layer','fontsize', 20);
% xlabel('Ss','fontsize', 20);
% hj = legend(ag,'0+1','2+3','4','5','6','7','8','9+');
% export_fig(fig,'-eps','-nocrop');

AK.AK = S.S*(K'/Se*K);
%Area of the AK is a measure of the amount of information coming from the
%measurements relative to the a priori information, ideally = 1.0
AK.area=sum(AK.AK,1);

AK.AK1 = g*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';
AK.AK2 = g1*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
AK.AK2(:,1:2) = AK.AK2(:,1:2)/10;
AK.AK2(:,3:7) = AK.AK2(:,3:7)/5;
AK.AK2(:,8) = AK.AK2(:,8)/35;

%Resolution
AK.resolution=1./diag(AK.AK);
res = AK.resolution;
save(strcat(output_folder_res,file_name_res),'res','-ascii');

%Degrees of Freedom for signal in Umkehr layers
AK.dof = sum(diag(AK.AK));
AK.dof1 = g1*diag(AK.AK(1:80,1:80));
AK.dof_all = diag(AK.AK(1:80,1:80));

dof = vertcat(AK.dof1,AK.dof);
%dof = vertcat(AK.dof_all,AK.dof);
save(strcat(output_folder_res, file_name_dof),'dof','-ascii');

%Information content - 3D reduction in the error covariance volumes - how
%much information from measurements versus a priori
%H;
H = -.5*log(det(eye(80)-AK.AK(1:80,1:80)));

count_start = 1;
count_end = 10;
for i = 1:8;
    if i == 1 || i == 2
        eye_size = 10;
    elseif i == 8;
        eye_size = 35;
    else eye_size = 5;
    end
    H_layer(i) = -.5*log(det(eye(eye_size)-AK.AK(count_start:count_end,count_start:count_end)));
    
    if i == 1
        count_start = count_start+10;
        count_end = count_end+10; 
    elseif i == 2
        count_start = count_start+10;
        count_end = count_end+5; 
    elseif i == 7;
        count_start = count_start+5;
        count_end = 80;
    else count_start = count_start+5;
        count_end = count_end+5;        
    end
end

H_print = horzcat(H_layer,H);
save(strcat(output_folder_res, file_name_H),'H_print','-ascii');

%AK_to_print = AK.AK1; Outputting full AK as all information can be
%obtained from it directly.
AK_to_print = AK.AK1;
save(strcat(output_folder_AK, file_name_AK),'AK_to_print','-ascii');

AK_to_print2 = AK.AK;
save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals', file_name_AK),'AK_to_print2','-ascii');


end