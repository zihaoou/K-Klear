function S = fileName(filename,n1,ext,type)
S1 = int2str(n1);    [~,c] = size(S1);
switch type
    case 1
        if c == 1
            S1 = ['00' S1];
        elseif c == 2
            S1 = ['0' S1];
        end
        S = strcat(filename,'_001_001_001_',S1,ext);
    case 2
        if c == 1
            S1 = ['_' '000' S1];
        elseif c == 2
            S1 = ['_' '00' S1];
        elseif c == 3
            S1 = ['_' '0' S1];
        elseif c == 4
            S1 = ['_' S1];
        end
        S = strcat(filename,S1,ext);
end
end