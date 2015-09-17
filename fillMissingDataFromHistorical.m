function []=fillMissingDataFromHistorical(input_file_name)

fid = fopen(input_file_name);
data = textscan(fid,'%s %s %f %f %f %f %f','Delimiter',',','HeaderLines',0);
hisdata = cell2mat(data(3:end));
str = strcat(data{:,1},{' '},data{:,2});
numdate = datenum(str, 'yyyy.mm.dd HH:MM');

length_storico = length(numdate);

undicidisera = datenum('23:00');
mezzanotte = datenum('00:00');

maxdatepoints = int8( ( numdate(end) - numdate(1) ) * 1440 ) +1;

corrected_hist = NaN(maxdatepoints, 5);
corrected_dates = NaN(maxdatepoints, 1);
dati_out = NaN(maxdatepoints, 6);
date_out = cell(maxdatepoints, 1);

corrected_hist(1,:) = hisdata(1,:);
corrected_dates(1) = numdate(1);

i=2;
j=2;

for i=2:length_storico
    
    N =  round( ( numdate(i) - numdate(i-1) ) *1440 ) ;
    
    if ( N == 1 )  % se lo storico è corretto
        
        corrected_hist(j,:) = hisdata(i,:);
        corrected_dates(j) = numdate(i);
        
        j=j+1;
        
    elseif ( N <= 5 ) % se il buco è minore di 5 punti temporali
        
        for k=0:(N-2)
            
            randomnoise = 2*rand -1;
            
            corrected_dates(j+k,1) = corrected_dates(j-1) + (k+1)/1440;
         
            corrected_hist(j+k,1) = corrected_hist(j-1,1) + ( ( hisdata(i,1) -  corrected_hist(j-1,1) ) * (2*k + N*randomnoise) ) / 2*N;
            corrected_hist(j+k,2) = corrected_hist(j-1,2) + ( hisdata(i,2) -  corrected_hist(j-1,2) ) * (2*k + N*randomnoise) / 2*N;
            corrected_hist(j+k,3) = corrected_hist(j-1,3) + ( hisdata(i,3) -  corrected_hist(j-1,3) ) * (2*k + N*randomnoise) / 2*N;
            corrected_hist(j+k,4) = corrected_hist(j-1,4) + ( hisdata(i,4) -  corrected_hist(j-1,4) ) * (2*k + N*randomnoise) / 2*N;
            corrected_hist(j+k,5) = floor( rand* max( [hisdata(i,5) corrected_hist(j-1,5) ] ) );
     
        end
        
        corrected_hist(j+N-1,:) = hisdata(i,:);
        corrected_dates(j+N-1) = numdate(i);
        
        j=j+N;
            
    elseif ( N > 1440 ) % se il buco è più grande di un gg, è festa o venerdì
        
        oraVenerdi = datestr(corrected_dates(j-1,1),'HH:MM');
        oraLunedi =  datestr(numdate(i),'HH:MM');
        
        datenum_Venerdi = datenum(oraVenerdi);
        datenum_Lunedi = datenum(oraLunedi);
        
        N_venerdi = round( ( undicidisera - datenum_Venerdi ) *1440 );
        N_lunedi = round( ( datenum_Lunedi - mezzanotte) *1440 );
        
        if ( N_venerdi > 0 ) % tappa il buco con NaN fino alle 23:00 del venerdi
            
            for d=0:(N_venerdi-1)
                corrected_dates(j+d) = corrected_dates(j-1) +(d+1)/1440;
            end
            
            j=j+N_venerdi;
            
            if ( N_lunedi == 0 ) % se il lune parte da 00:00 scrivici il valore, se no aspetta
                corrected_hist(j,:) = hisdata(i,:);
                corrected_dates(j) = numdate(i);
                j=j+1;
            end
            
            
        end
        
        if ( N_lunedi > 0 ) % tappa il buco con NaN dalle 00:00 del lunedi

            for d=0:(N_lunedi-1) 
                corrected_dates(j+d) = numdate(i) - (N_lunedi - d)/1440;
            end
            
            j=j+N_lunedi;
            corrected_hist(j,:) = hisdata(i,:);
            corrected_dates(j) = numdate(i);
            j=j+1;
            
        end
        
        
    else  % se c'è un buco troppo grosso intraday, lascia NaN
        
        for d=0:(N-2) 
            corrected_dates(j+d) = corrected_dates(j-1) +(d+1)/1440;
        end
        
        j=j+N-1;
        corrected_hist(j,:) = hisdata(i,:);
        corrected_dates(j) = numdate(i);
        j=j+1;
    
    end
    
end

fclose(fid);

date_out= cellstr(datestr(corrected_dates,'mm/dd/yyyy HH:MM'));

nomefile =regexp(input_file_name,'[.]','split');
nome=char(nomefile(1));
estensione=char(nomefile(2));
outfile=strcat(nome,'_corretto.',estensione);

fout = fopen(outfile,'w');
formatSpec = '%1.4f,%1.4f,%1.4f,%1.4f,%d,%s\n';
for i=1:length(corrected_hist)
    fprintf(fout, formatSpec,corrected_hist(i,1),corrected_hist(i,2),corrected_hist(i,3),corrected_hist(i,4),corrected_hist(i,5),date_out{i});
end
fclose(fout);
%dlmwrite(outfile, dati_out);

end

