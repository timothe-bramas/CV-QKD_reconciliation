p_err=0.298256;
q=1-p_err;
H=p_err*log2(1/p_err)+q*log2(1/q);
C=1-H
beta=0.1/C
