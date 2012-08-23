#!/bin/awk -f

BEGIN {
  FS=" ";
  timings = 0;
}

{ 
  split($4, i, ":");
  Injectors[i[1]]++;
  
  
  s = $5;
  for(lf=6; lf<=NF; lf++) {
    s = s " " $lf;
  }

  split(s, a, " (");
  State[a[1]]++;

  split(s, a, "(for ");
  split(a[2], b, ")");
}

END {
  SUMCONN=0
  for(ip in Injectors) {
    printf("%-20s %5d\n", ip, Injectors[ip]);
    SUMCONN += Injectors[ip];
  }
  print "Total Connections: " SUMCONN;

  print "\n";

  for(s in State) {
    printf("%-20s %5d\n", s, State[s]);
  }
}
