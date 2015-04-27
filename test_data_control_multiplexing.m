clc
clear all
%%
G = 100;
Q_CQI = 10;
Qprime_RI = 6;
Qprime_ACK = 2;
N_pusch_symb = 14;

Qm = 2;
q = zeros(1,Q_CQI);
q(1:end) = 2;

f = zeros(1,G);
f(1:end) = 1;

q_ri = zeros(1,Qm*Qprime_RI);
q_ri(1:end) = 3;

q_ack = zeros(1,Qm*Qprime_ACK);
q_ack(1:end) = 4;


h = data_control_multiplexing( q,f,q_ri,q_ack,Qm,Q_CQI,G,Qprime_RI,Qprime_ACK,N_pusch_symb );
stop