 function B=generatePrototype(n,k,q, wv)
  %%This function generates a simple prototype matrix for a LDPC matrix, in systematic form
  %n is the code length, k is the number of information bits per message and q will be the expension factor
  %wv is the degree of the variable nodes (the number of check nodes each one will be connected to).
  m=n-k;

  I=(n-k)/q;
  J=n/q;
  K=k/q;
  B=zeros(I,J);
  %Creating the right part : the identity matrix
  B(:,K+1:end)=eye(I);

  %Creating the left part : randomly putting wv non-zero values in each column
  links=randi([1 I], wv, K);

  values = randi([1 q], size(links));
  for col = 1:K
    B(links(:, col), col) = values(:, col);
  endfor



endfunction

