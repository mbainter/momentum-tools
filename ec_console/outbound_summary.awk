#!/bin/awk -f

BEGIN {
  FS=" ";
  total = 0;
}

{ 
  split($0, a, "[");
  split(a[3], b, "]");

  if(b[1] == "") {
    state = "unknown"
  } else {
    state = b[1];
  }


  split($0, a, "(");
  split(a[2], b, ")");
  domain = b[1];

  domains[domain]++;
  states[state]++;

  total++;
}

END {
  SUMCONN=0;
  single=0;
  print "Domains: ";
  for(d in domains) {
    if(domains[d] < 5) {
      single++;
      continue;
    }
    printf("%-20s %5d\n", d, domains[d]);
  }
  print single " domains have less than 5 connections.";
  print "************************************\n"

  print "States:"
  for(s in states) {
    printf("%-20s %5d\n", s, states[s]);
  }
  print "************************************\n"

  print "\n\n";
  print "Total connections: " total;
}
