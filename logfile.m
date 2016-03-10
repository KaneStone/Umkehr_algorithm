function [] = logfile(Umkehr)

% %checking whether vector lengths are the same
% for i = 1:length(Umkehr.data)
%     no_zeros = nonzeros(Umkehr.data(i).SolarZenithAngle);
%     sz_SZA = size(Umkehr.data(i).SolarZenithAngle);
% end
% 
% if length(no_zeros) ~= length(reshape(atmos.initial_SZA(measurement_number).SZA,1,sz_SZA(1)*sz_SZA(2)))
%     disp(strcat('Inconsistent vector lengths of different wavelength pairs for date:',...
%         num2str(atmos.date(measurement_number).date(1)),'-',num2str(atmos.date(measurement_number).date(2))...
%         ,'-',num2str(atmos.date(measurement_number).date(3))));
% end
end