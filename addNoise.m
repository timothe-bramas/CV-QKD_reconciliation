function [Pnoised, Qnoised]=addNoise(P,Q,SNRdB)
  n=length(P);
  mu=0;
  SNR=10^(SNRdB/10);
  sigma=sqrt(1/SNR);
  noise=normrnd(mu,sigma,2,n);
  Pnoised=P+noise(1,:);
  Qnoised=Q+noise(2,:);
