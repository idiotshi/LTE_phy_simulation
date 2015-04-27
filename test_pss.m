%%%pss detect 
clc
clear all;

%%仿真ZC序列的相关性
root = [25,29,34];
Nzc = 62;
du = zeros(3,Nzc);

for nn = 1:3
    u = root(nn);
    du(nn,:) = Pss_gen(u);
end

 subplot(3,1,1)
 plot(abs(xcorr(du(1,:),du(2,:))))
  subplot(3,1,2)
 plot(abs(xcorr(du(1,:),du(3,:)))) 
 subplot(3,1,3)
 plot(abs(xcorr(du(3,:),du(2,:))))
 figure
  subplot(3,1,1)
 plot(abs(xcorr(du(1,:),du(1,:))))
  subplot(3,1,2)
 plot(abs(xcorr(du(3,:),du(3,:)))) 
 subplot(3,1,3)
 plot(abs(xcorr(du(2,:),du(2,:))))
 
 figure
  subplot(3,1,1)
 plot(abs(du(1,:).*du(1,:)))
  subplot(3,1,2)
 plot(abs(du(2,:).*du(2,:)))
  subplot(3,1,3)
 plot(abs(du(1,:).*du(3,:)))
 stop
