function [g] = Umkehr_layers(extra,xhat,station,measurement_number,L_ozone,S)

%Irina's layering system.
%This could get quite complicated
Lower_limits = [1;6;11;16;21;26;31;36;41;46;51;56;61;66;71;76];
Upper_limits = [5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80];
DU_coeff = 1e5*1.38e-21*1e3*(273.1/10.13);

layers = 5;

g(1,1:length(extra.atmos.Zmid)) = horzcat(ones(1,layers),zeros(1,length(extra.atmos.Zmid)-layers));
for k = 1:length(extra.atmos.Zmid)/layers-1;
    g(k+1,:) = circshift(g(1,:),[0 layers*(k)]);
end

Scol = g*S(1:end-1,1:end-1)*g';
Scolerrors = diag((Scol).^.5);
Scolerrors1 = Scolerrors.*DU_coeff;
xhat_layer = DU_coeff.*xhat(1:end-1);
xhat_layer1 = g*xhat_layer';

Total_Ozone = sum(xhat_layer1);

Total_column_errors = (sum(diag(S))).^.5*DU_coeff;

Result_retrieval = vertcat(xhat_layer1,Total_Ozone);
Error_Result = vertcat(Scolerrors1,Total_column_errors);
Result = horzcat(Result_retrieval,Error_Result);


% lth = length(Upper_limits);
% Ozone = ones(lth,5);
% Layer_amount = ones(lth,1);
% 
% for i = 1:length(Upper_limits);
%     Ozone(i,:) = xhat(Lower_limits(i):Upper_limits(i));
%     if L_ozone
%         Layer_amount(i,1) = DU_coeff.*sum(Ozone(i,:));
%     else Layer_amount(i,1) = sum(Ozone(i,:));
%     end
% end

% Total_Ozone = sum(Layer_amount);

% Result = vertcat(Layer_amount,Total_Ozone);

date = extra.atmos.date(measurement_number).date;
WLP = extra.atmos.N_values(measurement_number).WLP;

if L_ozone
    save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/',...  
    station,'/',WLP,'/',station,'_',WLP,'_',num2str(date(3)),'-',num2str(date(2))...
    ,'-',num2str(date(1)),'.txt'),'Result','-ascii');
else save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/aerosols/',...  
    station,'/',num2str(date(1)),'-',num2str(date(2)),'-',num2str(date(3)),...
    '_',station,'_',WLP,'.txt'),'Result','-ascii');
end

end
