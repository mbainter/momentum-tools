#!/opt/msys/3rdParty/bin/perl

use strict qw( vars subs );
#use Ecelerity::Control;
use XML::Simple;
use Data::Dumper;
use Getopt::Long;
use vars qw( %opt );


# TODO:
# * Support -n or -i arguments to search for the Name or IP of a binding,
#   respectively. This should dump a detailed table of the views of that one
#   binding.
# * Detailed summary view, showing each binding/ip pair in turn, with a list of
#   hosts matching, and a list that do not match
# * Defaults to simple summary view, showing a table of bindings with their IP,
#   with two columns to show the number that match, and the number that do not
# * Nagios check mode, that returns warning or critical depending on how long
#   it has been sinc ethe last update (flagged) Details for this check should
#   be a list of binding names that are out of sync.

my %duravipdata;

GetOptions(\%opt,
    "file:s"
);

my $xml;

if($opt{file}) { 
    #FIXME - This needs to be done by reading it into a string, as a single root node wrapper needs to be created around it!
    $xml = (XMLin($opt{'file'}));
} else {
    my $ecc = Ecelerity::Control->new( { Control => '/tmp/2025' } );
    $ecc->connect();
    $xml = (XMLin('<MSYSECC>' . $ecc->command('cluster duravip show tables') . '</MSYSECC>'));
    $ecc->close();
}

my @by_name = @{$xml->{'VIPStateTable'}->{'group_vips_by_name'}->{'VIPs'}->{'VIP'}};

foreach my $vip (@by_name) {
  my $binding = $vip->{'Name'};
  my $ip = $vip->{IP};
  my $change = $vip->{'Last_View_Change'};
  my $state = $vip->{'State'};

  print("State Table Summary for $binding [$ip] (View Stable ${change}s):\n");
  my @right = ();
  my @wrong = ();

  foreach my $view (@{$vip->{'ViewsForParticipants'}->{ParticipantView}}) {
    $view->{'Private_Name'}[0] =~ m/^#[^#]+#(.*)$/;
    my $node = $1;
    my $vip_ip = $view->{'IP'};
    my $vip_name = $view->{'Name'};
    my $vip_state = $view->{'State'};

    if($vip_ip eq $ip && $vip_name eq $binding) {
       push @right, $node;
    } else {
       push @wrong, $node;
    }
  }

  print("\tMatching Nodes: " . join(', ', sort @right) . "\n");
  print("\tOutdated Nodes: " . join(', ', sort @wrong) . "\n\n");
}

