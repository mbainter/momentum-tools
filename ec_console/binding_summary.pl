#!/opt/msys/3rdParty/bin/perl

use strict qw( vars subs );
use Ecelerity::Control;
use XML::Simple;
use Data::Dumper;
use Time::HiRes qw(gettimeofday tv_interval);
use Getopt::Long;
use vars qw( %opt );

my $interval = 15;

my $ecc = Ecelerity::Control->new( { Control => '/tmp/2025' } ); 
$ecc->connect();

my %bindingdata;

GetOptions(\%opt,
   "log:s"
);

if($opt{log}) {
  open(STDOUT, ">>$opt{log}") || die "Failed to open $opt{log}: $!\n";
}

while(1) {
  my $start = [gettimeofday];
  my $ref = (XMLin($ecc->command('xml binding summary')));
  my $elapsed = tv_interval($start, [gettimeofday]);
  my $active_bindings = 0;
  my $outbound = 0;

  foreach(@{$ref->{'ServerSummary'}}) {
    if($bindingdata{$_->{'BindingName'}} < $_->{'Receptions'}) {
      $bindingdata{$_->{'BindingName'}} = $_->{'Receptions'};
      $active_bindings++;
    } 

    if($_->{'OutboundConcurrency'} > 0) {
      $outbound++;
    }

    print localtime() . " - Active Bindings: $active_bindings - Active Outbound: $outbound - Elapsed: $elapsed\n";

    sleep $interval;
  }
    
}
