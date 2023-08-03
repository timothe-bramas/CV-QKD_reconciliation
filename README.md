# CV-QKD_reconciliation
 Work on the reverse reconciliation part of a GG02 protocol for CV QKD using LDPC codes, using a QPSK modulation (the bits are paired up by two and modulated in 4 different symbols, represented by their quadratures P and Q)

The file to use and to read first should be main.m
This is a reverse reconciliation protocol using LDPC codes written with Octave, compatibility with MATLAB is possible with a few changes in the printf (replace by fprintf) and by removing the included package statistics.

main_DV_split is the same protocol, splitting a long string in a few shorter in order to make the protocol faster.
main_CV_recon is the protocol one should use with a gaussian modulation

The other  files are utilitary functions called in the mains.
