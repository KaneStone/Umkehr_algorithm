function [] = savevectordata(filename,result,date,type)
% Save vector data

if strcmp(type,'UmkehrLayers')
    format_header = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n';    
    format = '%04d\t%02d\t%02d\t%02d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';
    format_append = '\n%04d\t%02d\t%02d\t%02d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';
elseif strcmp(type,'inputresolution')
    headeralts = 1:length(result)-4;
    indstart = 1;
    indend = 5;
    for i = 1:length(headeralts)       
        headeraltsstr(:,indstart:indend) = ['L',sprintf('%02d',headeralts(i)),'\t'];
        if i < 98
            indstart = indstart+5;
            indend = indend+5;
        elseif i == 99
            indstart = indstart+5;
            indend = indend+6;
        else
            indstart = indstart+6;
            indend = indend+6;
        end
    end    
    format_header = ['%s\t%s\t%s\t%s\t',repmat('%s\t',1,length(result)-4),'\n'];
    format = ['%04d\t%02d\t%02d\t%02d\t',repmat('%f\t',1,length(result)-4)];
    format_append = ['\n%04d\t%02d\t%02d\t%02d\t',repmat('%f\t',1,length(result)-4)];
end

if exist(filename,'file') == 2
    linelocation = 0;
    linehandle = 0;        
    data = importdata(filename,'\t',1);
    while linehandle == 0 && linelocation ~= size(data.data,1)         
        linelocation = linelocation + 1;
        linehandle = find(data.data(linelocation,1) == date(1) & data.data(linelocation,2) ...
            == date(2) & data.data(linelocation,3) == date(3) & data.data(linelocation,4) ...
            == date(4));  
        if isempty(linehandle)
            linehandle = 0;
        end
    end
        
    if linehandle ~= 0
        % overwrite existing data for specific date
        fid = fopen(filename,'r+');        
        for k=1:linelocation
            fgetl(fid);
        end
        fseek(fid,0,'cof');
        fprintf(fid,format,result);
        fclose(fid);    
    else
        %find appropriate place to put new data
        currentdatenumber = datenum([date(1),date(2),date(3),date(4),0,0]);  
        for i = 1:size(data.data,1)
            existingdatenumbers(i) = datenum([data.data(i,1),data.data(i,2),...
                data.data(i,3),data.data(i,4),0,0]);      
        end
        datediff = existingdatenumbers-currentdatenumber;
        if datediff(end) < 0            
            %append to end of file
            fid = fopen(filename,'a');                 
            fprintf(fid,format_append,result);     
            fclose(fid);
        else
            % insert into appropriate place (writes over existing file);
            linelocation = find(datediff > 0, 1);
            fid = fopen(filename,'r+');            
            fgetl(fid);            
            databeforeinsert = data.data(1:linelocation-1,:);            
            dataafterinsert = data.data(linelocation:end,:);
            fclose(fid);
            fid = fopen(filename,'w');
            if strcmp(type,'UmkehrLayers')
                fprintf(fid,format_header,'YYYY','MM','DD','HH','L0+1','L2+3','L4',...
                    'L5','L6','L7','L8','L9+','TOC');
            elseif strcmp(type,'inputresolution')               
                fprintf(fid,['YYYY\t','MM\t','DD\t','HH\t',headeraltsstr,'\n']);
            end
            newdata = [databeforeinsert;result;dataafterinsert];                       
            for i = 1:size(newdata,1)
                if i == 1
                    fprintf(fid,format,newdata(i,:));
                else
                    fprintf(fid,format_append,newdata(i,:));
                end
            end
            fclose(fid);    
        end        
    end
else
    % create new file
    fid = fopen(filename,'w');   
    if strcmp(type,'UmkehrLayers')
        fprintf(fid,format_header,'YYYY','MM','DD','HH','L0+1','L2+3','L4',...
            'L5','L6','L7','L8','L9+','TOC');
    elseif strcmp(type,'inputresolution')
        fprintf(fid,['YYYY\t','MM\t','DD\t','HH\t',headeraltsstr,'\n']);
    end
    fprintf(fid,format,result);
    fclose(fid);
end

end