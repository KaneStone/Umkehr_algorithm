function [netcdf_fileinfo, netcdf_data, netcdf_attributes] = readnetcdf(filename)

%reads in all netcdf variables and variable attributes

netcdf_fileinfo = ncinfo(filename);
ncsz = size(netcdf_fileinfo.Variables);
ncid = netcdf.open(filename); 

for j = 1:ncsz(1,2);
    %aquiring variables
    varnames{j,1} = netcdf.inqVar(ncid,j-1);
    varid(j) = netcdf.inqVarID(ncid,varnames{j});
    datatype{j,1} = netcdf_fileinfo.Variables(1,j).Datatype; 
    netcdf_data.(varnames{j,1}) = netcdf.getVar(ncid,varid(j),datatype{j,1});
    
    %aquiring variable attributes
    for l = 1:length(netcdf_fileinfo.Variables(j).Attributes);
        attname = netcdf.inqAttName(ncid,varid(j),l-1);
        attname_for_naming = attname;
        attname_for_naming (attname_for_naming(1) == '_') = [];
        attname_for_naming (attname_for_naming == '-') = [];
        netcdf_attributes.(varnames{j,1}).(attname_for_naming) = ...
            netcdf.getAtt(ncid,varid(j),attname);
    end        
end  

if ~exist('netcdf_attributes','var')
    netcdf_attributes = 'does not exist';
end

netcdf.close(ncid);
end