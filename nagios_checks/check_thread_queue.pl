#!/opt/msys/3rdParty/bin/perl

use lib "/usr/lib/perl5/vendor_perl/5.8.8/";
use strict qw( vars subs );
use vars qw( %threadstats );
use Ecelerity::Control;
use Nagios::Plugin;

use Data::Dumper;

my $VERSION = '0.01a';

my $plugin = Nagios::Plugin->new(
   usage => "Usage: %s [-v|--verbose] [-t <timeout>] " .
            "[-c|--critical=<threshold>] [-w|--warning=<threshold>] " .
            "[-p|--pool=<threadpool name>]",
   version => $VERSION
   );

$plugin->add_arg(spec => 'warning|w=s', help => "Warning Threshold (default 250)", default => 250);
$plugin->add_arg(spec => 'critical|c=s', help => "Critical Threshold (default 500)", default => 500);
$plugin->add_arg(spec => 'pool|p=s@', help => "ThreadPool(s) to Check (Case Sensitive)", required => 1);

$plugin->getopts;

# XXX Need to be able to specify this on the command line
my $control = Ecelerity::Control->new( { Control => 'localhost:2025', User => 'ecuser', Pass => '' } );
$control->connect();

local $SIG{ALRM} = sub { nagios_die("threads stats query timed out"); };
alarm $plugin->opts->timeout;
my $response = $control->command('threads', 'stats');
alarm 0;

my @thread_data = split(/\n/, $response);

while (my $tmp = shift(@thread_data)) {
   $tmp =~ m/^(\S*)\s+thread\s+pool:\s+concurrency\s+(\d+)\s*$/;
   my $tpool = $1;
   $threadstats{$tpool}{'concurrency'} = $2;
   my $tstat = shift(@thread_data);
   while($tstat !~ m/^\s*$/) {
      if($tstat =~ m/^\s*([^:]+):\s+(.+)\s*$/) {
        $threadstats{$tpool}{$1} = $2;
      }
      $tstat = shift(@thread_data);
   }
}

foreach(@{$plugin->opts->pool}) {
  unless(exists($threadstats{$_}{'Current queue length'})) {
    $plugin->nagios_die("Couldn't find any of the specified threadpools.");
  }
  $plugin->add_message(
         $plugin->check_threshold(check => $threadstats{$_}{'Current queue length'}), 
         $_
         );
  $plugin->add_perfdata(
      label => "$_ Queue Length",
      value => $threadstats{$_}{'Current queue length'},
      uom => undef
      );
}

$plugin->nagios_exit($plugin->check_messages);
