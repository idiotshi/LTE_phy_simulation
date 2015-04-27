function rx_ulsch( PHY_VARS_eNB,sched_subframe)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    eNB_pusch_vars = PHY_VARS_eNB.LTE_eNB_PUSCH;
    eNB_common_vars = PHY_VARS_eNB.LTE_eNB_COMMON;
    frame_parms = PHY_VARS_eNB.LTE_DL_FRAME_PARMS;
    ulsch = PHY_VARS_eNB.LTE_eNB_ULSCH;
    
    subframe = sched_subframe;%% 真实系统中会有差别，TODO
    radio_frame = 1;%%真实系统中根据sched_subframe去查找
    
    harq_pid = subframe2harq_pid(frame_parms,radio_frame,subframe);%%TODO
    Qm = get_Qm_ul(ulsch.harq_process(harq_pid).mcs);%%TODO
    
    %%harq_process TODO 
%     first_rb = ulsch.harq_process[harq_pid].firsr_rb;
%     nb_rb = ulsch.harq_process[harq_pid].nb_rb;

    for l = 0:(frame_parms.symbols_per_tti - ulsch.harq_process(harq_pid).srs_active)
        %% dont know why ? 处理完的数据放在rxdataF_ext中
%         ulsch_extract_rbs_single(LTE_eNB_COMMON.txdataF,eNB_pusch_vars.rxdataF_ext, ...
%                                    first_rb, ...
%                                    nb_rb, ...
%                                    mod(l,frame_parms.sysbols_per_tti/2), ...
%                                    l/(frame_parms.sysbols_per_tti/2), ...
%                                    frame_parms);
    

    %channel estimation
    lte_ul_channel_estimation(PHY_VARS_eNB,...
                                0,...%%eNB_id
                                0,...%%UE_id
                                sched_subframe,...
                                mod(l,frame_parms.sysbols_per_tti/2), ...
                                l/(frame_parms.sysbols_per_tti/2), ...
                                0);
    end
    

end

