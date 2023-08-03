function estimate=belief_propagation_CV(X,M, H, SNR, maxIter)

  %%This function returns the estimation of Bob's codeword from Alice, based on the following parameters :
  %X : Alice's message : the error less quadratures
  %M : Bob's sent message, depending on his reception of the raw key
  %H : the LDPC matrix
  %SNR : the Signal Noise Ratio of the quantum channel (in dB)
  %maxIter : the maximum number of iterations for the BP algorithm


  %This function is adapted for a Gaussian modulated CV-QKD protocol, the algorithm was described by M. Milicevic in his PhD thesis


  [m,n]=size(H);
  if length(M)~=n
    printf("Wrong message size\n");
    return;
  endif


  %This function is used for transmitting the messages of check nodes
  function ret = phi(x)
    if x==0
      ret=0;
    else
      ret=-log(tanh(x/2));
    endif
  endfunction

  %This function will be used by the variable nodes to estimate their value.
  estimateV=@(j,llrV,r) llrV(j)+sum(r(find(H(:, j) ~= 0),j));


  %This function will calculate the message sent by the variable node j to the check node i.
  function message=messageVtoC(j,i,llrV,r)
    neighbours=variableNodeNeighbours{j};  %Gather the neighbours of the node j
    recieved=r(neighbours(neighbours~=i), j); %messages recieved from nodes other than i from the neighbours
    message=llrV(j)+sum(recieved);
  endfunction

  %This function will calculate the message sent by the check node i to the variable node j.
  function message=messageCtoV(i,j,q)
    indexes=1:n;
    neighbours=checkNodeNeighbours{i};
    tmp=q(i,neighbours(neighbours~=j));
    tmp(abs(tmp)<1e-8) = 1e-8;
    message=prod(sign(tmp))*phi(sum(phi(abs(tmp))));
    %message=2*atanh(prod(tanh(tmp/2)));
    %message = prod(sign(tmp)) * log(prod(exp(abs(tmp))));

    message(abs(message) > 1000) = sign(message > 1000)*1000;
    %message=prod(sign(tmp))*min(abs(tmp));  %min-sum algorithm version
  endfunction

  %This function will return the line of the messages recieved by the check node i from its neighbours
  function recieved=updateQ(i,n,r,llrV)

    neighbours=checkNodeNeighbours{i};
    recieved=zeros(1,n);
    for jj=1:length(neighbours)
      j=neighbours(jj);
      recieved(j)=messageVtoC(j,i,llrV,r);
    endfor
  endfunction

  %This function will return the line of the messages recieved by the variable node j from its neighbours
  function recieved=updateR(j,q,m)
    neighbours=variableNodeNeighbours{j};
    recieved=zeros(1,m);
    for ii=1:length(neighbours)
      i=neighbours(ii);
      recieved(i)=messageCtoV(i,j,q);
    endfor
  endfunction

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


  R=M./X;   %Ri is then of the form (-1)^Ci + (-1)^Ci * Zi/Xi, with Zi the noise
  SNR=10^(SNR/10); %Converting the SNR from dB to a ratio
  varZ=1/SNR;     %the variance of the BIAWGNC
  var=varZ./(X.*X);
  llrV=2*R./var;  %Taking in account the modelisation of the channel
  llr=zeros(1,n);


  %%Beginning the algorithm

  estimate=zeros(1,n);
  %First reception of messages (only depends on Alice's message)

  for i=1:m
    q(i,:)=updateQ(i,n,r,llrV);
  endfor
  %Looping
  for k=1:maxIter
    if k>1
      printf("The algorithm has not converged, iteration %d\n",k);

    else
      printf("Starting the algorithm...\n");
    endif


    %check nodes to variable nodes
    for j=1:n
      r(:,j)=updateR(j,q,m);
    endfor
    %variable nodes to check nodes
    for i=1:m
      q(i,:)=updateQ(i,n,r,llrV);
    endfor

    %Estimation
    for j=1:n
      llr(j)=estimateV(j,llrV,r);
    endfor
    estimate=llr<0;
    %Verification

    syndromeA=mod(H*estimate',2);
    if ~any(syndromeA)
      printf("The algorithm converged\n");
      estimate=num2str(estimate);
      estimate = estimate(find(~isspace(estimate)));
      break;
    endif

  endfor
  %estimate=num2str(estimate);
  %estimate = estimate(find(~isspace(estimate)));
  estimate = num2str(estimate, '%d');
  estimate = strrep(estimate, ' ', '');
  end;
