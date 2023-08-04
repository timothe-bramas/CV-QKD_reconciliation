# CV-QKD_reconciliation

This repository regroups the codes I wrote during my internship at Télécom Paris, as a student from ENSTA Paris. I worked with Guillaume RICARD who is working on his PhD Thesis under the supervision of Romain ALLEAUME.
The codes are written with Octave, compatibility with MATLAB is possible with some changes in the printf (replace by fprintf) and by removing the included package statistics. One could benefit from rewriting the codes in C/C++ (or any other low level language) in order to speed up the algorithm, as it takes a few hours to run on MATLAB. Parallel programming should also speed up the process a lot.

This work represents the reverse reconciliation part of a GG02 protocol for Continuous Variables Quantum Key Distribution using Low-Density Parity Check codes, using a QPSK modulation (the bits are paired up by two and modulated in 4 different symbols, represented by their quadratures P and Q).
Context : Alice sent quadratures to Bob through a very noisy quantum channel, and the two partites use the discrete modulation (here QPSK) in order to have two correlated (but non equal) bit chains A and B. Bob will then generate a random binary key and send it using his bits B through a classical channel, and Alice will use the Belief Propagation Algorithm to deduce Bob's key.
This key will then be used to perform privacy amplification (which has not been treated here) to end up with a secret key.


The file to use and to read first after this readme should be main.m

main_DV_split is the same protocol, splitting a long string in a few shorter in order to make the protocol faster.
main_CV_recon is the protocol one should use with a gaussian modulation


The other  files are utilitary functions called in the mains :

-generateRA generates a matrix in the Repeat-Accumulate form (the right part is a double diagonal matrix) and the left part is composed of random ones, with a fixed amount per column.
-generateRA_NonRandom generates the RA matrix stored in DVB_S2_110.mat
-DVB_S2_110.mat is the 1/10 rate RA matrix used in https://arxiv.org/pdf/1510.03510.pdf to perform the reconciliation, and it is the best one I have used.
-RA_n6000_R150.mat is a 1/50 rate RA matrix that I generated randomly, it is highly inefficient but is used in the main_DV_split.m. The rate 1/50 is the rate that might be used with a SNR under -10dB (The shannon capacity of a BSC channnel with more than 40% errors is around 0.025 and the code rate has to be lower than that)
-LDPC_expender is a function that takes the base matrix of a Quasi-Cyclic LDPC (https://arxiv.org/abs/1702.07740) and returns the corresponding QC LDPC matrix. These LDPC matrices seem interesting to use for CV-QKD, but I did not design an effective one.
-generatePrototype generates a random base matrix for a QC LDPC, in systematic form (the right part is just the identity matrix)
-addNoise adds the gaussian noise that emulates the quantum channel
-belief_propagation_CV/DV is the belief propagation algorithm used by Alice to guess Bob's key, one is for Discrete Variable (or a discrete modulation such as QPSK) and the other for the gaussian modulation, both algorithms were described by Mario Milicevic in his PhD thesis.
-bits2quad and quad2bits computes the QPSK modulation, from bits to quadratures and from quadratures to bits.
-findDifferences just gives the number of differences between two character strings
-s2tab and tab2s convert 0 and 1 strings to arrays of 0 and 1, I just made it to be able print the keys as strings, which is prettier. Working all the way with arrays is perfectly fine.
