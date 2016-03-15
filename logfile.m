function [] = logfile(foldersandnames,to_append)

%creating log file
output_folder = strcat(foldersandnames.retrievals,inputs.station,'/',WLP,'/',...
    sprintf('%d',date(3)),'/');
filename = strcat(inputs.station,'_',WLP,'_',sprintf('%d',date(3)),'-',...
        sprintf('%02d',date(2)),'-',sprintf('%02d',date(1)),...
        foldersandnames.name_ext,'.txt');
if ~exist(strcat(output_folder,filename),'file')
    mkdir(output_folder);        
    save(strcat(output_folder,filename),'to_append','-ascii');
end
save(strcat(output_folder,filename),'to_append','-ascii','-append');
save(strcat(output_folder,filename),'/n','-ascii','-append');

end