function [] = Umkehr_layers(extra,xhat,station,measurement_number)

%Irina's layering system.
%This could get quite complicated
Lower_limits = [1;6;11;16;21;26;31;36;41;46;51;56;61;66;71;76];
Upper_limits = [5;10;15;20;25;30;35;40;45;50;55;60;65;70;75;80];
DU_coeff = 1e5*1.38e-21*1e3*(273.1/10.13);
lth = length(Upper_limits);
Ozone = ones(lth,5);
Layer_amount = ones(lth,1);

for i = 1:length(Upper_limits);
    Ozone(i,:) = xhat(Lower_limits(i):Upper_limits(i));
    Layer_amount(i,1) = DU_coeff.*sum(Ozone(i,:));
end

Total_Ozone = sum(Layer_amount);

Result = vertcat(Layer_amount,Total_Ozone);

date = extra.atmos.date(measurement_number).date;
WLP = extra.atmos.N_values(measurement_number).WLP;

save(strcat('/Users/stonek/work/Dobson/OUTPUT/retrievals/',...
station,'/',station,'_',WLP,'_',num2str(date(1)),'-',num2str(date(2))...
,'-',num2str(date(3)),'.txt'),'Result','-ascii');

end
