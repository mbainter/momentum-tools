#!/usr/bin/awk -f

BEGIN {
  FS="@"
  printf("%-40s%-20s%-10s%-10s\n", "Domain", "Binding Group", "Binding", "Status");
};

$5 ~ /^R$/ {
  printf("%-40s%-20s%-10s%-15s\n", $9"/"$7, "G:"$13, "B:"$14, "RCV");
}

$5 ~ /^D$/ {
  printf("%-40s%-20s%-10s%-5s%-10s%-15s\n", $6, "G:"$8, "B:"$9, "DLV", "Tries:"$10, "Time:"$11);
}

$5 ~ /^T$/ {
  printf("%-40s%-20s%-10s%-5s%-10s%-15s%s\n", $6, "G:"$8, "B:"$9, "TF", "Tries:"$11, "Time:"$12, "Err:"$14);
}
