function count=findDifferences(M1,M2)
  %M1 : first binary string
  %M2 : second binary string
  %count : the number of differences between the two strings
  %Prints the number of errors

  n1=length(M1);
  n2=length(M2);
  if n1==n2;
    differences=find(M1~=M2);
    count=length(differences);
    if count==0;
      %printf("Les chaines sont identiques\n");
    else
      if count==1;
        %printf("Une erreur � l'indice %s\n", num2str(differences))
      else
        %printf("%d erreurs aux indices : [%s]\n",count, num2str(differences))
        %printf("%d erreurs entre les chaines \n",count);
      end
    end
  else
    count=-1;
    printf("The strings has different lengths\n");
  end
