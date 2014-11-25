function bc = altiBassicontatore( data )

found = 0;
finished = 0;
i = -1;
progCount = 0;
prog = 0;
k = 0;
while(finished == 0)
    i = i+1;
    if(i == 0)
        prog = data(end) - data(end-1);
        progCount = 1;
    else
        d1 = data(end-i+1) - data(end-i);
        d2 = data(end-i) - data(end-i-1);
        s = sign(d1*d2);
        if(progCount > 0)
            if(s >=0)
                prog = prog + d1;
                progCount = progCount + 1;
            else
                k = k+1;
                bc(k,:) = [progCount prog];
                prog = 0;
                progCount = 0;
                if(i==length(data)-3)
                    k = k+1;
                    bc(k,:) = [1 d1];
                end
            end
        else
            prog = prog + d1;
            progCount = progCount + 1;
        end
    end
    finished = i == (length(data)-3);
end
if(progCount > 0)
    k = k+1;
    bc(k,:) = [progCount prog];
    prog = 0;
    progCount = 0;
end

end

