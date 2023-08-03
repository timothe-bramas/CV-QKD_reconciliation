function c=RA_encode(H,message)

  %This function applies an LDPC encoding to the message m, using the base matrix B
  %The LDPC Matrix in RA form
  %message : the word, length = #cols(B)-#lines(b)*q
  %c : the code word corresponding to m, length = #cols(B)*q

  [m,n]=size(H);
  k=n-m;
  c=zeros(1,n);
  c(1:k)=message;
  A=H(1:m,1:k);
  c(k+1)=mod(A(1,:)*message',2);
  for kk=2:m

    c(k+kk)=mod(((c(k+kk-1))+ mod(A(kk,:)*message',2)),2);
  end

