function H=LDPC_expender(B,q)
  %This function returns a random quasi-cyclic LDPC matrix

  %if B(i,j)=0, the (i,j) block in H will be zeros, else it will be the identity matrix shifted by B(i,j)

  %q is the expension factor
  %n=block length
  %n-k = redondancy
  %R=k/n the code rate
  %B : the prototype matrix that will be expensed to give H

  %Matrix B will give the offset of each matrix
  %B=round(unifrnd(-q-0.49,q+0.49,[(n-k)/q n/q]));
  %B(find(B<0))=0;

  [J,L]=size(B);
  n=q*L;  %Calculating the block length
  R=(L-J)/L; %Calculating the code rate
  k=n*R; %Calculating k


  H=sparse(n-k,n);

  for i=1:(((n-k)/q))
    for j=1:((n/q))
      shift=B(i,j);
      if shift~=0;
        H((i-1)*q+1:(i*q),(j-1)*q+1:(j*q))=diag(ones(q-shift+1,1),shift-1)+diag(ones(shift-1,1),-q+shift-1);
      endif
    endfor
  endfor


