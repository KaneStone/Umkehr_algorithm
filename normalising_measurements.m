function [atmos] = normalising_measurements(atmos)
%Normalising to lowest SZA

for i = 1:length(atmos.N_values);
    sz = size(atmos.N_values(i).N);
    [~, SZA_min_location] = min(atmos.initial_SZA(i).SZA,[],2);
    for j = 1:length(SZA_min_location);
        N_min = atmos.N_values(i).N(j,SZA_min_location(j));
        atmos.N_values(i).N(j,:) = atmos.N_values(i).N(j,:) - repmat(N_min,1,sz(2));   
    end
end

end
