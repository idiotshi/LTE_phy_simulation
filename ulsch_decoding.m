function ulsch_decoding( PHY_VARS_eNB,subframe )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    frame_parms = PHY_VARS_eNB.LTE_DL_FRAME_PARMS;
    ulsch = PHY_VARS_eNB.LTE_eNB_ULSCH;

    eNB_pusch_vars = PHY_VARS_eNB.LTE_eNB_PUSCH;
    eNB_common_vars = PHY_VARS_eNB.LTE_eNB_COMMON;
    
    c_init = bitshift(ulsch.rnti,14) + bitshift(subframe,9) + frame_parms.Nid_cell;
    harq_pid = subframe2harq_pid(frame_parms,1,subframe);%%1 frame,TODO
    
end

