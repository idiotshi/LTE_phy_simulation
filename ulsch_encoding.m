function ulsch_encoding( ulsch_input_buf,phy_vars_ue,harq_pid,tmode,control_only_flag,Nbundled )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    frame_parms = phy_vars_ue.LTE_DL_FRAME_PARMS;
    ulsch = phy_vars_ue.ulsch_ue;
%     dlsch = phy_vars_ue.dlsch_ue;%%TODO

    %%CQI TODO
    %%
    if control_only_flag == 0
        %%既有data也有UCI需要传输
        A = ulsch.harq_processes(harq_pid).TBS;
        Q_m = get_Qm_ul(ulsch.harq_processes(harq_pid).mcs);
        
        if ulsch.harq_processes(harq_pid).round == 0
            crc = crc24a(ulsch_input_buf,A);%%crc的结果是24bit的校验信息
            ulsch_input_buf = [ulsch_input_buf,crc];%%将crc校验信息添加到数据末尾
            
            ulsch.harq_processes(harq_pid).B = A+24;
            ulsch.harq_processes(harq_pid).b = ulsch_input_buf;
            
            [out,parms] = lte_segmentation( ulsch_input_buf,(A+24));

            %%中间结果有必要存储吗？
            ulsch.harq_processes(harq_pid).C = parms.C;
            ulsch.harq_processes(harq_pid).Cplus = parms.Cplus;
            ulsch.harq_processes(harq_pid).Cminus = parms.Cminus;
            ulsch.harq_processes(harq_pid).Kplus = parms.Kplus;
            ulsch.harq_processes(harq_pid).Kminus = parms.Kminus;
            ulsch.harq_processes(harq_pid).F = parms.F;
            
            
            %%turbo编码和交织
            offset = 0;
            for r = 0:ulsch.harq_processes(harq_pid).C-1
                if r < ulsch.harq_processes(harq_pid).Cminus
                    Kr = ulsch.harq_processes(harq_pid).Kminus;
                else
                    Kr = ulsch.harq_processes(harq_pid).Kplus;
                end
                
                %%trubo TODO
                tmp = floor(2*rand(1,3*4));
                bit_after_turbo = [out(r+1,:) out(r+1,:) out(r+1,:) tmp];
                
                %%subblock interleaving for turbo coding
                [w,RTC] = subblock_interleaving_trubo(4+Kr,bit_after_turbo);
                ulsch.harq_processes(harq_pid).w(r+1,1:length(w)) = w;
            end
        end
        
        %%计算sumKr，计算Q_RI和Q_ACK时需要，36.212 5.2.2.6
        sumKr = 0;
        for r = 0:ulsch.harq_processes(harq_pid).C-1
            if r < ulsch.harq_processes(harq_pid).Cminus
                Kr = ulsch.harq_processes(harq_pid).Kminus;
            else
                Kr = ulsch.harq_processes(harq_pid).Kplus;
            end
            sumKr = sumKr+Kr;
        end
    else
        %%TODO
        sumKr = ulsch.Q_CQI_MIN;
    end

    ulsch.harq_processes(harq_pid).sumKr = sumKr;
    
    %%Q_RI 和Q_ACK的计算不论是否只有控制信息都需要计算
    %%Q_CQI 和PUSCH G只有在有数据传输时需要计算
    %%计算Q_RI,Q_ACK，后面计算PUSCH G时需要
    Qprime = ceil((ulsch.O_RI * ulsch.harq_processes(harq_pid).Msc_initial * ulsch.harq_processes(harq_pid).Nsymb_initial * ulsch.beta_offset_ri)/sumKr);
    Qprime = min(Qprime,4*ulsch.harq_processes(harq_pid).nb_rb * 12); 
    Q_RI = Q_m*Qprime;
    Qprime_RI = Qprime;
    
    Qprime = ceil((ulsch.harq_processes(harq_pid).O_ACK * ulsch.harq_processes(harq_pid).Msc_initial * ulsch.harq_processes(harq_pid).Nsymb_initial * ulsch.beta_offset_harqack)/sumKr);
    Qprime = min(Qprime,4*ulsch.harq_processes(harq_pid).nb_rb * 12); 
    Q_ACK = Q_m*Qprime;
    Qprime_ACK = Qprime;
    
    
    if control_only_flag == 0
        %%计算CQI的长度
        %%TODO
        Qprime = 0;%%TODO
        Q_CQI = Q_m*Qprime;
        Qprime_CQI = Qprime;
        
        %%计算速率匹配的参数,对于所有C个码块，参数都是一样?
        Nsoft = 1827072;
        Qm = get_Qm_ul(ulsch.harq_processes(harq_pid).mcs);
        G = ulsch.harq_processes(harq_pid).nb_rb * (12 * Qm) * ulsch.Nsymb_pusch;
        G = G - Q_CQI - Q_RI;%%需要考虑UCI，减去Q_RI和Q_CQI
        C = ulsch.harq_processes(harq_pid).C;
        Mdlharq = ulsch.Mdlharq;
        Kmimo = 1;
        rvidx = ulsch.harq_processes(harq_pid).rvidx;
        Nl = 1;
        nb_rb = ulsch.harq_processes(harq_pid).nb_rb;
        m = ulsch.harq_processes(harq_pid).mcs;
        

        
       %%
        H = G + Q_CQI;
        Hprime = H/Q_m;
        
        %%如果数据不是第一次传输，不需要做turbo编码和字块交织，只需要从循环buf中选取合适的bit块传输
        for r = 0:ulsch.harq_processes(harq_pid).C-1
            e = rate_matching_turbo(RTC,G,ulsch.harq_processes(harq_pid).w(r+1,:),C,Nsoft,Mdlharq,Kmimo,rvidx,Qm,Nl,r,nb_rb,m);  
            %%码块级联
            ulsch.e(1+offset:offset+length(e)) = e;
            offset = offset + length(e);
        end
    else
        %%只有UCI
        Q_CQI = (ulsch.harq_processes(harq_pid).nb_rb * 12 * Q_m * ulsch.Nsymb_pusch) - Q_RI;
        H = Q_CQI;
        Hprime = H/Q_m;
        G = 0;
    end
    
    Qm = get_Qm_ul(ulsch.harq_processes(harq_pid).mcs);

    %%CQI 编码，TODO
    
    %%RI编码，TODO
    
    %%ACK/NACK编码TODO
    if ulsch.harq_processes(harq_pid).O_ACK == 1
        ulsch.o_ACK(1) = 1;%%for test where is ack
        switch Qm
            case 2
                ulsch.q_ACK(1) = ulsch.o_ACK(1);
                ulsch.q_ACK(2) = 3;%%pusch y 3;pusch x 2
            case 4
                ulsch.q_ACK(1) = ulsch.o_ACK(1);
                ulsch.q_ACK(2) = 3;%%pusch y 3;pusch x 2
                ulsch.q_ACK(3) = 2;%%pusch y 3;pusch x 2
                ulsch.q_ACK(4) = 2;%%pusch y 3;pusch x 2
            case 6
                ulsch.q_ACK(1) = ulsch.o_ACK(1);
                ulsch.q_ACK(2) = 3;%%pusch y 3;pusch x 2
                ulsch.q_ACK(3) = 2;%%pusch y 3;pusch x 2
                ulsch.q_ACK(4) = 2;%%pusch y 3;pusch x 2
                ulsch.q_ACK(5) = 2;%%pusch y 3;pusch x 2
                ulsch.q_ACK(6) = 2;%%pusch y 3;pusch x 2
        end 
        if ulsch.bundling == 1
            i = 0;
            k = 0;
            while i < Q_ACK %%not O_ACK
                %%TODO 按照协议36.212 5.2.2.6节的描述，多个编码后的HARQ block需要级联
                %%不明白为什么会有多个HARQ block
                %%此处输入的O_ACK指的是对应一个下行子帧的ACK/NACK还是多个下行子帧bundling或者multiplexing后的bit长度？
                %%o_ack中包含的内容指的又是什么？
            end
        end
    elseif ulsch.harq_processes(harq_pid).O_ACK == 2
        %%TODO
    elseif ulsch.harq_processes(harq_pid).O_ACK > 2
        %%TODO
    end
    
    
    %%信道复用与交织
    Qprime_ACK = Q_ACK/Qm;
    q_ack = ulsch.q_ACK;
    
    %%TODO
    Qprime_RI = Q_RI/Qm;
    q_ri = ulsch.q_RI;
    
    Q_CQI = 0;%%TODO
    q = ulsch.q;
    f = ulsch.e;
    
    ulsch.h = data_control_multiplexing( q,f,q_ri,q_ack,Qm,Q_CQI,G,Qprime_RI,Qprime_ACK,ulsch.Nsymb_pusch );
    
    
end

