function l = limitOfBinary(ff,data)
    d = abs(ff-data);
    found = 0;
    iter = 1;
    while found == 0
        iter = iter+1;
        D = iterativeMax(d,iter);
        s = sum(d <= D);
        r = s/length(d);
        if r <.88
            found = 1;
            l = D;
        end
    end
end