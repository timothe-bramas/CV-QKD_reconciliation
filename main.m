pkg load statistics;
close all;
clear;

%Code made by Timothé BRAMAS, student at ENSTA Paris, during an internship at Télécom Paris
%This code's aim is to help Guillaume RICARD to adress the subject of the reconciliation in his PhD thesis.
%This emulates the reverse reconciliation part in the GG02 protocol (proposed by Grosshans and Grangier)

%It uses the DV-QKD reconciliation explained by M. Milicevic in his PhD thesis (DV-QKD's scheme is usable in our CV-QKD thanks to the discrete modulation)
%The LDPC matrix used is an altered version of the Repeat-Accumulate Low Density Parity Check matrixes of the DVB-S2 standard, it was engineered by S.J. Johnsson et al. (https://arxiv.org/abs/1510.03510)


%%Creating Alice's bits
%The bloc length of the RA-LDPC matrix used is 64800, so we generate that many bits
n=64800;
k=n/10;
A=tab2s(randi([0 1], 1, n));;

%Writing the results in a file in order to have datas and to estimate the Frame-Error Rate (the proportion of reconciliations that failed)
fID=fopen('res.txt','a+');


%%Convertion to phase quadratures (using a QPSK discrete modulation)
[P,Q,colors]=bits2quad(A);


%%The signal-to-noise ratio of the quantum channel in dB (  SNR_dB=10log10(SNR_ratio) , SNR_ratio=10^(SNR_dB/10)  ), -5.5dB seems to be the limit for this matrix, maybe -5.7
SNR=-5.5;

%%Modeling the channel
[PBob, QBob]=addNoise(P,Q,SNR);


%%Bob decodes the noisy bits string
B=quad2bits(PBob,QBob);


%%Parameters estimation (we use the whole string but in a realistic protocol this would only be a fraction of it)
diffs=findDifferences(B,A);

error_rate=diffs/n;
fprintf("%d Errors after the quantum channel\n Error percentage : %d\n",diffs,error_rate*100);
%Writing it in the results file
fprintf(fID,"%d Errors after the quantum channel\n Error percentage : %d\n",diffs,error_rate*100);


%%Reconciliation :

%I've tried to used Quasi-Cyclic LDPC, not a great success, this can be a thing to try

%Proto=generatePrototype(n,k,q,weight);
%Proto=cell2mat(struct2cell(load("CoolProto.mat")));
%H=LDPC_expender(Proto,q);
%H=generateRA(n,k,weight);

%Loading the LDPC Matrix
H=cell2mat(struct2cell(load("DVB_S2_110.mat")));


%Generating Bob's message

%S will be the key used by Alice and Bob at the end of the protocol to perform privacy amplification
S=randi([0 1],1,k);

C=RA_encode(H,S);   %Encoding the message using the RA form of the matrix H
MB= mod(C + B, 2);  %Using the DV-QKD reconciliation explained by M. Milicevic
S=tab2s(S);

%Alice uses belief propagation to estimate S (very long)

MAX_ITER=400;
tic
%The belief propagation, you have the possibility to add C (Bob's code word) in input in order to print the number of errors at each iteration as it's long
[CAlice,success]=belief_propagation_DV(A,MB,H,error_rate,MAX_ITER);
time=toc;

printf("BP's time : %mins\n",time/60);
fprintf(fID,"BP's time : %dmins\n",time/60);

if success
  fprintf(fID,"Reconciliation successful\n");
else
  fprintf(fID,"Reconciliation failed\n");
end


SAlice=CAlice(1:k);
diffsReconciliated=findDifferences(S,SAlice);

printf("%d differences between the two final keys : %d\nPercentage : %d\n", diffsReconciliated, diffsReconciliated/k*100);
fprintf(fID,"%d differences between the two final keys : %d\nPercentage : %d\n\n\n", diffsReconciliated, diffsReconciliated/k*100);

fclose(fID)


%%Tracing the quadratures
%[rVal,yVal,gVal,bVal]=assignColors(P,Q);
%Pval=[min(P) min(P) max(P) max(P)];
%Qval=[min(Q) max(Q) min(Q) max(Q)];
%colval=[0.2 1 0.3;1 0 0.2;0.3 0.6 1;.97 .75 0];
%
%PMean=[mean(PBob(gVal)), mean(PBob(rVal)), mean(PBob(bVal)), mean(PBob(yVal))];
%QMean=[mean(QBob(gVal)), mean(QBob(rVal)), mean(QBob(bVal)), mean(QBob(yVal))];
%
%hold on;
%scatter(PBob, QBob,15, colors, 'filled');
%
%scatter(Pval,Qval,25, colval,'filled', 'MarkerEdgeColor', [0 0 0]);
%
%box on;
%
%xlim([-10 10])
%ylim([-10 10])
%xlabel("P");
%ylabel("Q");
%scatter(Pval(2),Qval(2),35, colval(2,:),'filled', 'MarkerEdgeColor', [0 0 0]);
%scatter(Pval(1),Qval(1),35, colval(1,:),'filled', 'MarkerEdgeColor', [0 0 0]);
%scatter(Pval(4),Qval(4),35, colval(4,:),'filled', 'MarkerEdgeColor', [0 0 0]);
%scatter(Pval(3),Qval(3),35, colval(3,:),'filled', 'MarkerEdgeColor', [0 0 0]);
%%
%%plotCircle(0,0,1);
%legend('[0 0]','[0 1]','[1 0]','[1 1]');
%
%title("Quadratures envoyées par Alice");
%
%figure;
%scatter(PMean,QMean,60,colval,'filled', 'MarkerEdgeColor', [0 0 0])
%hold on;
%plotCircle(0,0,sqrt(2));
