function [g g1] = Umkehr_layers(extra,xhat,station,measurement_number,L_ozone,S,seasonal)

%Irina's layering system.
%This could get quite complicated
Lower_limits = [1;6;11;16;21;26;31;36;41;46;51;56;61;66;71;76];
Upper_limits = [5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80];
DU_coeff = 1e5*1.38e-21*1e3*(273.1/10.13);

layers = 5;

g(1,1:length(extra.atmos.Zmid)) = horzcat(ones(1,layers),...
    zeros(1,length(extra.atmos.Zmid)-layers));
for k = 1:length(extra.atmos.Zmid)/layers-1;
    g(k+1,:) = circshift(g(1,:),[0 layers*(k)]);
end
g1 = zeros(8,80);
g1(1,1:10) = 1;
g1(2,11:20) = 1;
g1(3,21:25) = 1;
g1(4,26:30) = 1;
g1(5,31:35) = 1;
g1(6,36:40) = 1;
g1(7,41:45) = 1;
g1(8,46:end) = 1;

Scol = g*S.S(1:end-1,1:end-1)*g';
Scolerrors = diag((Scol).^.5);
Scolerrors1 = Scolerrors.*DU_coeff;
xhat_layer = DU_coeff.*xhat(1:end-1);
xhat_layer1 = g*xhat_layer';

Total_Ozone = sum(xhat_layer1);

Total_column_errors = (sum(diag(S.S))).^.5*DU_coeff;

Result_retrieval = vertcat(xhat_layer1,Total_Ozone);
Error_Result = vertcat(Scolerrors1,Total_column_errors);
Result = horzcat(Result_retrieval,Error_Result);

date = extra.atmos.date(measurement_number).date;
if strcmp(seasonal, 'constant');
    WLP = 'C_CAP';
else WLP = extra.atmos.N_values(measurement_number).WLP;
end

%Saving retrieval
if L_ozone
    output_folder = strcat(extra.output_retrievals,station,'/',WLP,'/',...
        sprintf('%d',date(3)),'/');

    file_name = strcat(station,'_',WLP,'_',sprintf('%d',date(3)),'-',...
        sprintf('%02d',date(2)),'-',sprintf('%02d',date(1)),...
        extra.name_ext,'.txt');

    if ~exist(strcat(output_folder),'dir')
        mkdir(output_folder);
    end
    save(strcat(output_folder,file_name),'Result','-ascii');
    
else save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/aerosols/',...  
    station,'/',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),...
    '_',station,'_',WLP,'.txt'),'Result','-ascii');
end

end
