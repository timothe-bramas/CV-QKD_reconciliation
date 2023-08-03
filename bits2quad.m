function [P,Q,colors] = bits2quad(M)
  %M : the binary string representing the message to encode
  %P : the P quadrature obtained from M
  %Q : the other quadrature
  %Modulation :
  %   00  ==> 3/4*pi
  %   01  ==> 5/4*pi
  %   10  ==> 1/4*pi
  %   11  ==> 7/4*pi

  n=length(M);
  theta=zeros(1,n/2);
  colors=zeros(3,n/2)';
  for i=1:(n/2)
    switch ([M(2*i-1) M(2*i)])
      case "00"
        theta(i)= 3*pi/4;
        colors(i,:)=[1 0 0.2];
      case "01"
        theta(i)= -3*pi/4;
        colors(i,:)=[0.2 1 0.3];
      case "10"
        theta(i)= pi/4;
        colors(i,:)=[.97 .75 0];
      case "11"
        theta(i)= -pi/4;
        colors(i,:)=[0.3 0.6 1];
    end
  end
  P=cos(theta)*sqrt(2);
  Q=sin(theta)*sqrt(2);
