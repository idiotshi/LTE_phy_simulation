clc
clear all
%%接收端
LTE_DL_FRAME_PARMS.N_RB_DL = 100;
LTE_DL_FRAME_PARMS.N_RB_UL = 100;
LTE_DL_FRAME_PARMS.Ncp = 0;
LTE_DL_FRAME_PARMS.Ncp_UL = 0;
LTE_DL_FRAME_PARMS.frame_type = 1;%%0 FDD,1 TDD
LTE_DL_FRAME_PARMS.tdd_config = 3;%%0-7,default 3
LTE_DL_FRAME_PARMS.tdd_config_s = 0;%%special subframe config 0-9

LTE_DL_FRAME_PARMS.ofdm_symbol_size = 2048;%% default 2048
LTE_DL_FRAME_PARMS.log2_symbol_size = 11;%% default 2048

LTE_DL_FRAME_PARMS.samples_per_tti = 30720;%%一个子帧内的复数点个数
LTE_DL_FRAME_PARMS.symbols_per_tti = 14;%%normal cp

LTE_DL_FRAME_PARMS.nb_antennas_tx = 1;
LTE_DL_FRAME_PARMS.nb_antennas_rx = 1;

LTE_DL_FRAME_PARMS.Nid_cell = 0;

% LTE_DL_FRAME_PARMS.pusch_config_common;%%36.331

LTE_DL_FRAME_PARMS.nb_prefix_samples0 = 160;
LTE_DL_FRAME_PARMS.nb_prefix_samples = 144;


%%eNB 参数配置
%% hoslds transmit data in time domain,30720个复数点:a+j*b
LTE_eNB_COMMON.txdata = zeros(LTE_DL_FRAME_PARMS.nb_antennas_tx,LTE_DL_FRAME_PARMS.samples_per_tti);
%% hoslds transmit data in frequency domain,size:15*2048 个复数点
LTE_eNB_COMMON.txdataF = zeros(LTE_DL_FRAME_PARMS.nb_antennas_tx,LTE_DL_FRAME_PARMS.ofdm_symbol_size*LTE_DL_FRAME_PARMS.symbols_per_tti);
%% hoslds received data in time domain
LTE_eNB_COMMON.rxdata = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.samples_per_tti);
%% hoslds received data in frequency domain
LTE_eNB_COMMON.rxdataF = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.ofdm_symbol_size*LTE_DL_FRAME_PARMS.symbols_per_tti);


%%eNB参数配置
% PHY_VARS_eNB.LTE.eNB_ULSCH.harq_process;
LTE.eNB_ULSCH.harq_process = 1;%%TODO
LTE_eNB_ULSCH.cyclicShift = 0;%%cyclicShift for DMRS 
LTE_eNB_ULSCH.rnti = 0;%%rnti attributed for this ULSCH

%%eNB参数配置
% LTE_eNB_PUSCH.rxdataF_ext = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.symbols_per_tti*LTE_DL_FRAME_PARMS.N_RB_UL*12);%%确认空间大小，TODO
% LTE_eNB_PUSCH.rxdataF_ext2;
LTE_eNB_PUSCH.drs_ch_estimates_time = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,2*2*LTE_DL_FRAME_PARMS.ofdm_symbol_size);
LTE_eNB_PUSCH.drs_ch_estimates = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.symbols_per_tti*LTE_DL_FRAME_PARMS.N_RB_UL*12);
% LTE_eNB_PUSCH.rxdataF_comp;
% LTE_eNB_PUSCH.ulsch_power;

%%
PHY_VARS_eNB.LTE_eNB_PUSCH = LTE_eNB_PUSCH;
PHY_VARS_eNB.LTE_eNB_ULSCH = LTE_eNB_ULSCH;
PHY_VARS_eNB.LTE_eNB_COMMON = LTE_eNB_COMMON;
PHY_VARS_eNB.LTE_DL_FRAME_PARMS = LTE_DL_FRAME_PARMS;


%%参数配置
subframe = 3;
subframe = subframe+1;%%#1~#10对应协议中的#0~#9


%%生成发送的数据或者从文件中导入数据


%%以一个子帧为单位接收数据
%%去除CP,ofdm符号 FFT
% for l = subframe*LTE_DL_FRAME_PARMS.symbols_per_tti:(1+subframe)*LTE_DL_FRAME_PARMS.symbols_per_tti
for l = 0:LTE_DL_FRAME_PARMS.symbols_per_tti-1
    slot_fep_ul(LTE_DL_FRAME_PARMS,LTE_eNB_COMMON,mod(l,LTE_DL_FRAME_PARMS.symbols_per_tti/2),floor(l/(floor(LTE_DL_FRAME_PARMS.symbols_per_tti/2))), 0,0);
end

%%处理上行pusch信道（信道均衡、信道估计、频偏估计、解调等）
rx_ulsch(PHY_VARS_eNB,subframe);%%,0,0,0);

%%ulsch decoding，解码PUSCH信道承载的bit信息
ulsch_decoding(PHY_VARS_eNB,subframe);%%,0,control_only_flag,1,11r8_flag);

