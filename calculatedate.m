function [dateforprint] = calculatedate()

    currenttime = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    dateforprint = datenum(currenttime);
end