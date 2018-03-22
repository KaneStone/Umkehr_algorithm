function [lambda,bandpass] = definelambda(Umkehr)
%This function defines lambda based on what WLP are used and what is
%available.

lambda = zeros(length(Umkehr.data.WaveLengthPair) * 2,1);
count = 1;
for i = 1:length(Umkehr.data.WaveLengthPair);
    switch char(Umkehr.data.WaveLengthPair(i))
        case 'A'
            lambda(count) = str2double(Umkehr.attributes.WaveLengthPair.APair_wavelengths(1:5));
            lambda(count + 1) = str2double(Umkehr.attributes.WaveLengthPair.APair_wavelengths(10:14));
            bandpass(count) = 1.4;
            bandpass(count+1) = 3.2;            
        case 'C'
            lambda(count) = str2double(Umkehr.attributes.WaveLengthPair.CPair_wavelengths(1:5));
            lambda(count + 1) = str2double(Umkehr.attributes.WaveLengthPair.CPair_wavelengths(10:14));
            bandpass(count) = 1.4;
            bandpass(count+1) = 3.2;            
        case 'D'
            lambda(count) = str2double(Umkehr.attributes.WaveLengthPair.DPair_wavelengths(1:5));
            lambda(count + 1) = str2double(Umkehr.attributes.WaveLengthPair.DPair_wavelengths(10:14));
            bandpass(count) = 1.4;
            bandpass(count+1) = 3.2;            
    end
    count = count + 2;
end

end