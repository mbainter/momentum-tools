

# ! #/bin/env awk

BEGIN { 
  FS="@";
  OFS=",";
  $rcv_time=0;
  $send_time=0;

#  printf("Which Message ID: ");
#  getline mid < "-";
#  print("\n\n"); 
  print("Searching for " $mid "\n");
  printf("%s,%s,%s\n", "Timestamp", "Type", "Time in Queue", "Count");
} 


$5 == "R" && $2 == $mid { 
   $rcv_time = strftime("%H:%M:%S", $1);
   printf("%s,%s,%d\n", $rcv_time, "Received");
} 
$5 == "T" && $2 == $mid { 
   $send_time = strftime("%H:%M:%S", $1);
   printf("%s,%s,%d\n", $rcv_time, "Transfailed", $12, $11);
} 
$5 == "D" && $2 == $mid { 
   $send_time = strftime("%H:%M:%S", $1);
   printf("%s,%s,%d\n", $rcv_time, "Received", $11, $10);
} 

