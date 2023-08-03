function M=quad2bits(P,Q)

  %P and Q are the 2 quadratures
  %Conversion :
  %   00  ==> 3/4*pi  ==> -1+1*1i
  %   01  ==> 5/4*pi  ==> -1-1*1i
  %   10  ==> 1/4*pi  ==> 1+1*1i
  %   11  ==> 7/4*pi  ==> 1-1*1i

  n=length(P);
  M="";
  for i=1:n
    if P(i)>=0;
      if Q(i)>=0;
        M=strcat(M,"10");
      else
        M=strcat(M,"11");
      end
    else
      if Q(i)>=0;
        M=strcat(M,"00");
      else
        M=strcat(M,"01");
      end
    end
  end

