function [AK] = AveragingKernel(S,Sa,Se,extra,K,g,g1,station,measurement_number,seasonal)

AK.AK = S*(K'/Se*K);
%Area of the AK is a measure of the amount of information coming from the
%measurements relative to the a priori information, ideally = 1.0
AK.area=sum(AK.AK,1);

AK.AK1 = g*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';
AK.AK2 = g1*AK.AK(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
AK.AK2(:,1:2) = AK.AK2(:,1:2)/10;
AK.AK2(:,3:7) = AK.AK2(:,3:7)/5;
AK.AK2(:,8) = AK.AK2(:,8)/35;

%g2 = repmat(g1(1,:),10)

S1 = g*S(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g';
%S3 = g1*S(1:length(extra.atmos.Zmid),1:length(extra.atmos.Zmid))*g1';
S2 = (diag(S1^.5)).*(1e5*1.38e-21*1e3*(273.1/10.13));
%How many retrieval points required for each independent piece of
%information (degree of freedom)

date = extra.atmos.date(measurement_number).date;
if strcmp(seasonal, 'constant');
    WLP = 'C_CAP';
else WLP = extra.atmos.N_values(measurement_number).WLP;
end

%Resolution
AK.resolution=1./diag(AK.AK);
res = AK.resolution;
save(strcat('/Users/stonek/work/Dobson/OUTPUT/resolution/',station,'_res_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt'),'res','-ascii');

%Degrees of Freedom for signal
AK.dof=sum(diag(AK.AK));

AK.dof1=g1*diag(AK.AK(1:80,1:80));
dof = vertcat(AK.dof1,AK.dof);
save(strcat('/Users/stonek/work/Dobson/OUTPUT/resolution/',station,'_dof_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt'),'dof','-ascii');

%Information content - 3D reduction in the error covariance volumes - how
%much information from measurements versus a priori
%H;
%This a weird way of doing H
H = -.5*log(det(eye(80)-AK.AK(1:80,1:80)));
% H_norm = ((1./AK.resolution(1:80)))/sum(1./AK.resolution(1:80))*H;
% AK.H = g1*H_norm;
% H_print = AK.H;
% save(strcat('/Users/stonek/work/Dobson/OUTPUT/resolution/',station,'_H_',WLP,'_',...
%     sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
%     sprintf('%02d',date(1)),'.txt'),'H_print','-ascii');

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

% for i = 1:3;
%     if i ==1;
%         eye_size = 20;
%     elseif i == 2
%         eye_size = 10;
%     elseif i == 3
%         eye_size = 50;
%     end
%     H_layer(i) = -.5*log(det(eye(eye_size)-AK.AK(count_start:count_end,count_start:count_end)));
%     if i == 1;
%         count_start = count_start+20;
%         count_end = count_end+10;
%     elseif i == 2
%         count_start = count_start+10;
%         count_end = 80;
%     end
% end

H_print = horzcat(H_layer,H);
save(strcat('/Users/stonek/work/Dobson/OUTPUT/resolution/',station,'_H_',WLP,'_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt'),'H_print','-ascii');

%close all; %needs to be removed when finished diagnostics
AK_to_print = AK.AK1;
date = extra.atmos.date(measurement_number).date;
if strcmp(seasonal,'constant');
    WLP = 'C_CAP';
else WLP = extra.atmos.N_values(measurement_number).WLP;

save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/',...  
    station,'/',WLP,'/AK/',sprintf('%d',date(3)),'/',station,'_',WLP,'_AK_',...
    sprintf('%d',date(3)),'-',sprintf('%02d',date(2)),'-',...
    sprintf('%02d',date(1)),extra.name_ext,'.txt'),'AK_to_print','-ascii');

%Ss - smoothing error component from the a priori error smoothing error
%Sn - noise  error component of the measurements in your retrievals
%Shat - both

%Sfm - propagate the fmp errors through retrieval - i.e. aerosol

end