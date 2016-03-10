function [lambda] = defineLambda(Umkehr)
%This function defines lambda based on what WLP are used and what is
%available.

lambda = zeros(length(Umkehr.data.WLP) * 2,1);
count = 1;
for i = 1:length(Umkehr.data.WLP);
    if strcmp(char(Umkehr.data.WLP(i)),'A')
        lambda(count) = str2double(Umkehr.attributes.WLP.APair_wavelengths(1:5));
        lambda(count + 1) = str2double(Umkehr.attributes.WLP.APair_wavelengths(10:14));
    elseif strcmp(char(Umkehr.data.WLP(i)),'C')
        lambda(count) = str2double(Umkehr.attributes.WLP.CPair_wavelengths(1:5));
        lambda(count + 1) = str2double(Umkehr.attributes.WLP.CPair_wavelengths(10:14));
    elseif strcmp(char(Umkehr.data.WLP(i)), 'D')
        lambda(count) = str2double(Umkehr.attributes.WLP.DPair_wavelengths(1:5));
        lambda(count + 1) = str2double(Umkehr.attributes.WLP.DPair_wavelengths(10:14));
    end   
    count = count + 2;
end

end