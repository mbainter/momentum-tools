#!/opt/msys/3rdParty/bin/perl

use strict qw( vars subs );
use Ecelerity::Control;
use XML::Simple;
use Data::Dumper qw(Dumper);
use DateTime;
use Getopt::Long;
use vars qw( %opt );

my %summary;

my $ecc = Ecelerity::Control->new( { Control => '/tmp/2025' } ); 
$ecc->connect();

GetOptions(\%opt,
   "log:s",
   "debug"
);

if($opt{log}) {
  open(STDOUT, ">>$opt{log}") || die "Failed to open $opt{log}: $!\n";
}

my $domains = (XMLin($ecc->command('xml active 100')));

foreach my $domdata (@{$domains->{'DomainSummary'}}) {
  my $domain = $domdata->{'Name'};
  print STDERR "Processing $domain" if($opt{'debug'});  
  my @queue = split('\n', ($ecc->command("showqueue binding all $domain active")));
  foreach(@queue) {
    next if(m/^Nothing in active/);
    my @binding = split(' ', $_);
#    $_->{'CreationTS'} =~ m/^(\d+-\d+-\d+)\s+.*$/;
    my $date = DateTime->from_epoch( epoch => $binding[3] );
    unless(exists($summary{$date->strftime("%F")})) { $summary{$date->strftime("%F")} = 0; }
    $summary{$date->strftime("%F")}++;
    print STDERR "." if($opt{'debug'});
  }
  print STDERR "Done\n" if($opt{'debug'});
  sleep 0.5;
}

print("Date      \tCount\n");
foreach(sort keys %summary) { 
  printf("%s\t%d\n", $_, $summary{$_});
}
