#!/opt/msys/3rdParty/bin/perl

use lib qw(/usr/lib/perl5);
use JLog::Reader;
use Switch;
use DBI;

# This script assumes a custom_logger configuration like this:
#
# custom_logger "custom_logger1"
# {
#   reception_format = "%t@%i@R@%g@%b@%vctx_mess{jobid}@%r@%R"
#   delivery_format = "%t@%i@D@%g@%b@%vctx_mess{jobid}@%r@%R@%N@%T"
#   transient_failure_format = "%t@%i@T@%g@%b@%vctx_mess{jobid}@%r@%R@%N@%T"
#   permanent_failure_format = "%t@%i@P@%g@%b@%vctx_mess{jobid}@%r@%R@%N@%T"
#   mainlog = "jlog://var/log/ecelerity/jobstatus_log=>master"
# }
# 
# As well as a sqlite database with this schema:
# CREATE TABLE job_status(jobid varchar(10) UNIQUE, received bigint, delivered bigint, tempfail bigint, failed bigint, last_seen TIMESTAMP);
#

my $dbh = DBI->connect("dbi:SQLite:dbname=/var/db/jobstatus.db", 
          "", "", { RaiseError => 1 }, ) or die $DBI::errstr;

my $reader = JLog::Reader->new("/var/log/ecelerity/jobstatus_log");
my %idcache = ();
my %cmap = (
  'R' => 'received',
  'D' => 'delivered',
  'T' => 'tempfail',
  'P' => 'failed'
);

$reader->open("master") || die "Cannot open jlog: $!\n";

my $ins_sth = $dbh->prepare("INSERT INTO job_status VALUES(?, ?, ?, ?, ?, ?)");

while (my $line = $reader->read) {
  my %data = (
     'R' => 0,
     'D' => 0,
     'T' => 0,
     'P' => 0
   );
  chomp;
  my @fields = split('@', $line);

  next if($fields[5] =~ /^\s*$/);
  if(scalar(@fields) < 8) {
    warn "Corrupt log line: $line\n";
    next;
  }

  my $type = $fields[2];
  next if($type eq "T" && $fields[8] > 1);
  $data{$type} = 1;
  $col = $cmap{$type};
  $jobid = $fields[5];
  $ts = $fields[0];

  if(!defined($idcache{$jobid})) { 
    my @row = $dbh->selectrow_array(
              "SELECT jobid FROM job_status WHERE jobid=" . 
               $dbh->quote($jobid));
    if(scalar(@row) && $row[0] == $jobid) { 
      $idcache{$jobid} = 1;
    } else {
      $ins_sth->execute($jobid,$data{R},$data{D},$data{T},$data{P},$ts);
      $reader->checkpoint();
      next;
    }
  }

  $dbh->do(sprintf("UPDATE job_status SET %s=(%s + %d), last_seen=%d WHERE jobid=%s",
                   $col, $col, $data{$type}, $ts, $dbh->quote($jobid)));
  $reader->checkpoint();
}
$reader->close();

my $table = qx!sqlite3 -header -nullvalue NULL -html /var/db/jobstatus.db "select * from job_status;"!;
open(HTML, ">/var/www/lighttpd/status.html") || die "Couldn't open status.html for writing: $!\n";

print HTML <<EOH
<html>
  <body>
    <table border="1">
    $table
    </table>
  </body>
</html>
EOH
;
close(HTML);

