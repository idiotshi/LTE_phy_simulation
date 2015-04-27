function e = rate_matching_turbo( RTC,G,w,C,Nsoft,Mdlharq,Kmimo,rvidx,Qm,Nl,r,nb_rb,m)
    %%36.212 5.1.4.1.2
    %%输入的bit序列w包含了字块交织后的3路bit
%     Nsoft = 1827072;
    %%上下行计算Ncb的方式不同
    Kw = 3*RTC*32;
    Nir = floor(Nsoft/(Kmimo*min(Mdlharq,8)));
    %%DL LINK
    Ncb = min(floor(Nir/C),Kw);
    %%UPLINK
    Ncb = Kw;
    
    Gprime = G/(Nl*Qm);
    
    gama = mod(Gprime,C);
    if r <= C - gama -1
        E = Nl*Qm*floor(Gprime/C);
    else
        E = Nl*Qm*ceil(Gprime/C);
    end
    
    k0 = RTC*(2*ceil(Ncb/(8*RTC))*rvidx+2);
    k = 0;
    j = 0;
    
    e = zeros(1,E);
    while k < E
        if w(mod(k0+j,Ncb)) ~= -1
            e(k+1) = w(mod(k0+j,Ncb));
            k = k+1;
        end
        j = j+1;
    end
end

