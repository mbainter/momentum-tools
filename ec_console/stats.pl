#!/opt/msys/3rdParty/bin/perl

use strict qw( vars subs );
use Ecelerity::Control;
use XML::Simple;
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);
use Getopt::Long;

my $interval = 5;

my $ecc = Ecelerity::Control->new( { Control => '/tmp/2025' } ); 
$ecc->connect();

my @fields = (
  "OutboundConcurrency",
  "InboundConcurrency",
  "ActiveQueueSize",
  "DelayedQueueSize",
  "Receptions",
  "Deliveries",
  "Transients",
  "Failures"
);

my @hfields = (
  "OutCon",
  "InCon",
  "Active Queue",
  "Delayed Queue",
  "Receptions",
  "Deliveries",
  "Transients",
  "Failures",
  "BDC H/R",
  "BDC LRU",
  "ResponseTime (s)"
);

my $counter = 20;
my $header = sprintf("%-7s %-7s %-14s %-14s %-11s %-11s %-11s %-9s %-8s %-8s %-16s\n", @hfields);

my %opt = ();

my %history = (
  'Deliveries' => {
    'last' => 0,
    'data' => []
  },
  'Receptions' => {
    'last' => 0,
    'data' => [],
  }
);

my @rhist = ();
my @dhist = ();

GetOptions(\%opt,
   "log:s"
);

if($opt{log}) {
  open(STDOUT, ">>$opt{log}") || die "Failed to open $opt{log}: $!\n";
}

while(1) {
  my $start = [gettimeofday];
  my $ref = (XMLin($ecc->command('xml summary')));
  my $elapsed = tv_interval($start, [gettimeofday]);
  my @row;
  my @data = ();

  foreach(@fields) {
    push @data, $ref->{$_};
  }

  foreach(('Deliveries', 'Receptions')) {
    if($history{$_}{'last'} == 0) {
      $history{$_}{'last'} = $ref->{$_};
    } elsif($history{$_}{'last'} > $ref->{$_}) {
      $history{$_}{'last'} = $ref->{$_};
      $history{$_}{'data'} = [];
    } else {
      push @{$history{$_}{'data'}}, ($ref->{$_} - $history{$_}{'last'});
      $history{$_}{'last'} = $ref->{$_};

      if(scalar(@{$history{$_}{'data'}}) > 60) {
        shift(@{$history{$_}{'data'}});
      }
    }
  }
 
  if($counter == 20) {
    my $size = scalar(@{$history{'Receptions'}{'data'}});
    if($size >= 12) {
      my $r_rate = 0;
      my $d_rate = 0;
      my $total = 0;
      foreach(@{$history{'Receptions'}{'data'}}) {
        $total += $_;
      }
      my $r_rate = $total/($size*$interval);
      foreach(@{$history{'Deliveries'}{'data'}}) {
        $total += $_;
      }
      my $d_rate = $total/($size*$interval);
      printf("\t*** " . localtime() . "\tReceptions/sec: %.2f\tDeliveries/sec: %.2f (" . ($size*$interval) . "s history) ***\n", $r_rate, $d_rate);
    }
    print $header;
  }

  $ref = (XMLin($ecc->command('xml cache stats')));
  push @data, $ref->{'Cache'}{'adaptive_bd_cache'}{'hit_rate'};
  foreach(@{$ref->{'Cache'}{'adaptive_bd_cache'}{'deletes'}}) {
    push @data, $_->{'content'} if($_->{'type'} eq "lru");
  }

  push @data, $elapsed;
  
  printf("%6d %6d %14d %15d %11d %11d %11d %9d %8d %8d %13f\n", @data);

  $counter--;

  unless($counter >= 0) { $counter = 20; }
 
  sleep $interval;
}
