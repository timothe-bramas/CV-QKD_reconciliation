function res=s2tab(S)
  res=strrep(S,"0","0,");
  res=strrep(res,"1","1,");
  res=str2num(res(1:end-1));
end

