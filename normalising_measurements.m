function [atmos] = normalising_measurements(atmos,designated_SZA,theta,measurement_number)
%Normalising measurements to lowest SZA

if designated_SZA
    atmos.N_values(measurement_number).N = interp1(atmos.initial_SZA(measurement_number).SZA,...
        atmos.N_values(measurement_number).N,theta,'linear','extrap');
    atmos.initial_SZA(measurement_number).SZA = theta;
end

for i = 1:length(atmos.N_values);
    
    sz = size(atmos.N_values(i).N);
    [~, SZA_min_location] = min(atmos.initial_SZA(i).SZA,[],2);
    for j = 1:length(SZA_min_location);
        N_min = atmos.N_values(i).N(j,SZA_min_location(j));
        atmos.N_values(i).N(j,:) = atmos.N_values(i).N(j,:) - repmat(N_min,1,sz(2));   
    end
end

end
