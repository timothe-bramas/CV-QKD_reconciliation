 function H=generateRA(n,k, wv)
  %%This function generates a RA LDPC matrix
  %n is the code length, k is the number of information bits per message
  %wv is the degree of the variable nodes (the number of check nodes each one will be connected to).
  m=n-k;

  H=sparse(m,n);
  %Creating the right part : the identity matrix
  H(:,k+1:end)=eye(m) + diag(ones(1,m-1),-1);

  %Creating the left part : randomly putting wv non-zero values in each column

  for col = 1:k
    links=randperm(m,wv);
    H(links, col) = 1;
  endfor



endfunction

