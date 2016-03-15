function [lambda] = defineLambda(Umkehr)
%This function defines lambda based on what WLP are used and what is
%available.

lambda = zeros(length(Umkehr.data.WLP) * 2,1);
count = 1;
for i = 1:length(Umkehr.data.WLP);
    switch char(Umkehr.data.WLP(i))
        case 'A'
            lambda(count) = str2double(Umkehr.attributes.WLP.APair_wavelengths(1:5));
            lambda(count + 1) = str2double(Umkehr.attributes.WLP.APair_wavelengths(10:14));
        case 'C'
            lambda(count) = str2double(Umkehr.attributes.WLP.CPair_wavelengths(1:5));
            lambda(count + 1) = str2double(Umkehr.attributes.WLP.CPair_wavelengths(10:14));
        case 'D'
            lambda(count) = str2double(Umkehr.attributes.WLP.DPair_wavelengths(1:5));
            lambda(count + 1) = str2double(Umkehr.attributes.WLP.DPair_wavelengths(10:14));
    end
    count = count + 2;
end

end