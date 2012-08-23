#!/bin/awk -f 

BEGIN { 
  FS="@";
  SUM=0; 
  COUNT=0; 
  FLOOR=0;
  CEIL=0;
} 

$5 == "D" { 
  if(FLOOR == 0) {
    FLOOR = $7;
  }

  if(FLOOR > $7) {
    FLOOR = $7;
  }

  if(CEIL < $7) {
    CEIL = $7;
  }

  if($7 >= 90000 && $7 < 95000)
    Sizes[90k]++;
  else if($7 >= 95000 && $7 < 100000)
    Sizes[95k]++;
  else if($7 >= 100000 && $7 < 105000)
    Sizes[100k]++;
  else if($7 >= 105000 && $7 < 110000)
    Sizes[105k]++;
  else if($7 >= 110000 && $7 < 115000)
    Sizes[110k]++;
  else if($7 >= 150000 && $7 < 155000)
    Sizes[155k]++;
  else if($7 >= 155000 && $7 < 160000)
    Sizes[160k]++;
  else if($7 >= 160000 && $7 < 165000)
    Sizes[165k]++;
  else if($7 >= 165000 && $7 < 170000)
    Sizes[170k]++;

  if($7 > 153600)
    largemsg++;
  else
    normalmsg++;

  SUM += $7; 
  COUNT += 1;
} 

END { 
  print "SUM:", SUM, "COUNT: ", COUNT; 
  print "Avg: ", SUM/COUNT;
  print "Floor: ", FLOOR;
  print "Ceiling: ", CEIL;

  print "";
  print "LargeMsgs: ", largemsg;
  print "normalmsg: ", normalmsg;

  printf("%-10s %10s\n", "Size", "Count");
  for (sz in Sizes) {
    printf("%-10d %10d\n", sz, Sizes[sz]);
#    print Sizes[sz], sz;
  }
}
