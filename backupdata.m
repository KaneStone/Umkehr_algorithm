function [] = backupdata(inputs,foldersandnames)

    files = dir([foldersandnames.backup,inputs.station,'_',inputs.WLP_to_retrieve,'*']);
        
    if isempty(files)
        return
    end
    
    for i = 1:length(files)
        dates(i) = str2double(files(i).name(end-10:end));
    end
    
    %finding number of unique dates
    numofbackups = length(unique(dates));
    
    if numofbackups >= inputs.numofbackups
        mindates = min(dates);
        minind = find(dates == mindates);
        
        %removing earliest backup
        for i = 1:length(minind)
            delete([foldersandnames.backup,files(minind(i)).name]);
        end        
    end
        
end
