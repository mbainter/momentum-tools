#!/opt/msys/3rdParty/bin/perl -w

use strict;
use locale;
use Getopt::Long;
use File::Basename qw(basename);
use Storable qw(nstore);

use vars qw( %opts %hours %total $printResults);

# Breakdown of message sizes by hour
for (0 .. 23) {
  $hours{$_} = {
     'small' => 0,
     'medium' => 0,
     'large' => 0,
     'huge' => 0,
     'floor' => 0,
     'ceil' => 0,
     'sum' => 0,
     'count' => 0,
  };
}
my %total = (
     'small' => 0,
     'medium' => 0,
     'large' => 0,
     'huge' => 0,
     'floor' => 0,
     'ceil' => 0,
     'sum' => 0,
     'count' => 0,
  ); # Breakdown of message sizes overall

my $printResults = 0;
my $usage= "momosum.pl [-d] -f <logfile>";

GetOptions(
   "debug" => \$opts{'d'},
   "file=s" => \$opts{'f'},
) || die "$usage\n";

unless( -e $opts{'f'}) { 
  print STDERR "Got: $opts{'f'}\n";
  die "File argument is required.\n$usage\n";
}

sub getSize {
  my $size = shift;

  if($size <= 65536) {
    return "small";
  } elsif($size > 65536 && $size <= 102400) {
    return "medium";
  } elsif($size > 102400 && $size <= 204800) {
    return "large";
  } else {
    return "huge";
  }
}

sub interrupt { 
  print "\nInterrupt received, aborting early!  Results will be incomplete...\n";
  exit(0); 
}
$SIG{'INT'} = 'interrupt';

print STDERR "Processing logfile..." if($opts{'d'});
open(LOG, $opts{'f'}) || die "Couldn't open logfile ($opts{'f'}): $!\n";

while(<LOG>) {
  next unless m/\@R\@/;
  my @line = split(/@/);
  next unless($line[4] eq 'R');
  
  my @tstamp = localtime($line[0]);
  $hours{$tstamp[2]}{'count'}++;
  $total{'count'}++;

  $hours{$tstamp[2]}{'sum'} += $line[10];
  $total{'sum'} += $line[10];

  $hours{$tstamp[2]}{&getSize($line[10])}++;
  $total{&getSize($line[10])}++;
  
  if($hours{$tstamp[2]}{'ceil'} < $line[10]) {
    $hours{$tstamp[2]}{'ceil'} = $line[10];

    # If it's the largest this hour, it might be the largest overall...
    if($total{'ceil'} < $line[10]) {
      $total{'ceil'} = $line[10];
    }
  }

  if(!$hours{$tstamp[2]}{'floor'} || $hours{$tstamp[2]}{'floor'} > $line[10]) {
    $hours{$tstamp[2]}{'floor'} = $line[10];

    # If it's the smallest this hour, it might be the smallest overall...
    if(!$total{'floor'} || $total{'floor'} > $line[10]) {
      $total{'floor'} = $line[10];
    }
  }
  $printResults = 1;
  print STDERR "." if($opts{'d'} && !($total{'count'} % 10000));
}
print STDERR "Done\n\n" if($opts{'d'}); 
close(LOG);

END {
  exit unless($printResults);

#  $opts{'f'} =~ s/^.*?\///;
  my %data = (
    'hours' => \%hours,
    'summary' => \%total
  );
  nstore(\%data, basename($opts{'f'}) . ".dat");

print "Message Size Summary for " . basename($opts{'f'}) . ":\n";
print <<EOH
Hour               0-64k    64k-100k   100k-200k       200k+       floor     average     ceiling
------------------------------------------------------------------------------------------------
EOH
;

for (0 .. 23) {
#                           sm  med lrg hug    flr avg ceil 
  printf("%02d:00-%02d:00 %12d %11d %11d %11d %11d %11d %11d\n", $_, $_ +1, 
        $hours{$_}{'small'},
        $hours{$_}{'medium'},
        $hours{$_}{'large'},
        $hours{$_}{'huge'},
        $hours{$_}{'floor'},
        $hours{$_}{'count'} ? $hours{$_}{'sum'}/$hours{$_}{'count'} : 0,
        $hours{$_}{'ceil'}
  );
}

print "\n";

printf("SUMMARY     %12d %11d %11d %11d %11d %11d %11d\n",
        $total{'small'},
        $total{'medium'},
        $total{'large'},
        $total{'huge'},
        $total{'floor'},
        $total{'count'} ? $total{'sum'}/$total{'count'} : 0,
        $total{'ceil'}
);
}


# vim:ts=2:sw=2:et:
