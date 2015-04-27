function [out,parms] = lte_segmentation( input_buf,B)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    Z = 6144;
    if B <= Z
        L = 0;
        C = 1;
        Bprime = B;
    else
        L = 24;
        C = ceil(B/(Z-L));
        Bprime = B+C*L;
    end
    
    %%find K+,K+ = minimum K in table 5.1.3-3 such that C*K >= B'
    BprimebyC = Bprime/C;
    
    if BprimebyC <= 40
        Kplus = 40;
        Kminus = 0;
    elseif BprimebyC <= 512
        Kplus = floor(BprimebyC/8)*8;
        if Kplus < BprimebyC
            Kplus = Kplus+8;
        end
        Kminus = BprimebyC-8;
    elseif BprimebyC <= 1024
        Kplus = floor(BprimebyC/16)*16;
        if Kplus < BprimebyC
            Kplus = Kplus+16;
        end
        Kminus = BprimebyC -16;
    elseif BprimebyC <= 2048
        Kplus = floor(BprimebyC/32)*32;
        if Kplus < BprimebyC
            Kplus = Kplus+32;
        end
        Kminus = BprimebyC - 32;
    elseif BprimebyC <= 6144
        Kplus = floor(BprimebyC/64)*64;
        if Kplus < BprimebyC
            Kplus = Kplus+64;
        end
        Kminus = BprimebyC - 64;
    end
    
    if C == 1
        Cplus = 1;
        Kminus = 0;
        Cminus = 0;
    else
        Cminus = floor((C*Kplus - Bprime)/(Kplus - Kminus));
        Cplus = C - Cminus;
    end
    
    %%number of filler bits
    F = Cplus*Kplus + Cminus*Kminus - Bprime; 
    out = zeros(C,Kplus);
    for k = 0:F-1
        out(1,k+1) = 0;
    end
    k = F;
    s = 1;
    
    for r = 0:C-1
        if r < Cminus
            Kr = Kminus;
        else
            Kr = Kplus;
        end
        
        while(k < (Kr - L))
            out(r+1,k+1) = input_buf(s);
            k = k+1;
            s = s+1;
        end
        if C>1
            crc = crc24b(out(r+1,:),B);%%TODO
            while(k < Kr)
                out(r+1,k+1) = crc(1+k+L-Kr);
                k = k+1;
            end
        end
        k = 0;
    end
    
    %%返回临时结果
    parms.C = C;
    parms.Cplus = Cplus;
    parms.Cminus = Cminus;
    parms.Kplus = Kplus;
    parms.Kminus = Kminus;
    parms.F = F;
end

