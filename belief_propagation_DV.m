function [estimate,success]=belief_propagation_DV(A, M, H, p, maxIter)

  %This function returns the estimate of Bob's messages by Alice using the DV reconciliation protocol, based on the following parameters :

  %A : Alice's binary message : the error less bits
  %M : Bob's sent binary message, depending on his reception of the quadratures
  %H : the LDPC matrix
  %p : the bit-flipping probability
  %maxIter : the maximum number of iterations for the BP algorithm

  %It is adapted to a DV-QKD protocol or to a CV-QKD protocol in which you perform the reconciliation on bits.
  %The algorithm is described by M.Milicevic in his PhD Thesis.

  [m,n]=size(H);
  if length(M)~=n
    printf("Wrong message length\n");
    estimate=-1;
    success=0;
    return;
  end


  %This function is used for transmitting the messages of check nodes
  function ret = phi(x)
    if x==0
      ret=0;
    else
      ret=-log(tanh(x/2));
    end
  end

  %This function will be used by the variable nodes to estimate their value.
  estimateV=@(j,llrV,r) llrV(j)+sum(r(find(H(:, j) ~= 0),j));


  %This function will calculate the message sent by the variable node j to the check node i.
  function message=messageVtoC(j,i,llrV,r)
    neighbours=variableNodeNeighbours{j};  %Gather the neighbours of the node j
    recieved=r(neighbours(neighbours~=i), j); %messages recieved from nodes other than i from the neighbours
    message=llrV(j)+sum(recieved);
  end

  %This function will calculate the message sent by the check node i to the variable node j.
  function message=messageCtoV(i,j,q)
    indexes=1:n;
    neighbours=checkNodeNeighbours{i};
    tmp=q(i,neighbours(neighbours~=j));
    tmp(abs(tmp)<1e-8) = 1e-8;
    message=prod(sign(tmp))*phi(sum(phi(abs(tmp)))); %sum-product version

    %Other versions of the algorithm :
    %message=2*atanh(prod(tanh(tmp/2)));
    %message = prod(sign(tmp)) * log(prod(exp(abs(tmp))));
    %message=prod(sign(tmp))*min(abs(tmp));  %min-sum version

    message(abs(message) > 1000) = sign(message > 1000)*1000;
  end

  %This function will return the line of the messages recieved by the check node i from its neighbours
  function recieved=updateQ(i,n,r,llrV)

    neighbours=checkNodeNeighbours{i};
    recieved=zeros(1,n);
    for jj=1:length(neighbours)
      j=neighbours(jj);
      recieved(j)=messageVtoC(j,i,llrV,r);
    end
  end

  %This function will return the line of the messages recieved by the variable node j from its neighbours
  function recieved=updateR(j,q,m)
    neighbours=variableNodeNeighbours{j};
    recieved=zeros(1,m);
    for ii=1:length(neighbours)
      i=neighbours(ii);
      recieved(i)=messageCtoV(i,j,q);
    end
  end

  %Converting messages into int arrays
  %X=s2tab(X);

  %precomputing neighbours
  printf("Precomputing neighbours...\n");
  checkNodeNeighbours = cell(m, 1);
  for i = 1:m
    checkNodeNeighbours{i} = find(H(i, :) ~= 0);
  end

  variableNodeNeighbours = cell(n, 1);
  for j = 1:n
    variableNodeNeighbours{j} = find(H(:, j) ~= 0);
  end

  printf("Precomputing done\n")
  q=sparse(m,n); %Messages recieved by check nodes
  r=sparse(m,n); %Messages recieved by variable nodes


  R=mod(M+A,2);   %Ri is then of the form C+E, with E defined such as M=A + E
  llrV=zeros(1,n);  %Taking in account the modelisation of the channel
  llrV(R==1)=log(p/(1-p));
  llrV(R==0)=log((1-p)/p);
  llr=zeros(1,n);


  %%Beginning the algorithm

  estimate=zeros(1,n);
  %First reception of messages (only depends on Alice's message)

  for i=1:m
    q(i,:)=updateQ(i,n,r,llrV);
  end
  %Looping
  for k=1:maxIter
    if k>1
      printf("The algorithm has not converged, iteration %d\n",k);

    else
      printf("Starting the algorithm...\n");
    end


    %check nodes to variable nodes
    for j=1:n
      r(:,j)=updateR(j,q,m);
    end
    %variable nodes to check nodes
    for i=1:m
      q(i,:)=updateQ(i,n,r,llrV);
    end

    %Estimation
    for j=1:n
      llr(j)=estimateV(j,llrV,r);
    end
    estimate=llr<0;
    %Verification
    syndromeA=mod(H*estimate',2);
    if ~any(syndromeA)
      printf("The algorithm converged\n");
      estimate=num2str(estimate);
      estimate = estimate(find(~isspace(estimate)));
      success=1;
      break;
    else
      success=0;
    end

end
  %estimate=num2str(estimate);
  %estimate = estimate(find(~isspace(estimate)));
  estimate = num2str(estimate, '%d');
  estimate = strrep(estimate, ' ', '');
  end;
