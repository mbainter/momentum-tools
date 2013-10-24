#!/opt/msys/3rdParty/bin/perl

use lib "/usr/lib/perl5/vendor_perl/5.8.8/";
use strict qw( vars subs );
use vars qw( %threadstats );
use Ecelerity::Control;
use Nagios::Plugin;
use XML::Simple;

my $VERSION = '0.02';

my $plugin = Nagios::Plugin->new(
   usage => "Usage: %s [-v|--verbose] [-t <timeout>] " .
            "[-c|--critical=<threshold>] [-w|--warning=<threshold>] " .
            "[-p|--pool=<threadpool name>]",
   version => $VERSION
   );

$plugin->add_arg(spec => 'warning|w=s', help => "Warning Threshold (default 250)", default => 250);
$plugin->add_arg(spec => 'critical|c=s', help => "Critical Threshold (default 500)", default => 500);
$plugin->add_arg(spec => 'queue|q=s', help => "Which queue to check (active|delayed)", required => 1);
$plugin->add_arg(spec => 'console', help => "Which IP address and port to connect to the console on", default => 'localhost:2025');
$plugin->add_arg(spec => 'user|u=s', help => "Username for console authentication", default => 'ecuser');
$plugin->add_arg(spec => 'password|p=s', help => "Password for console authentication", default => '');

$plugin->getopts;

my $queue = '';
if($plugin->opts->queue =~ m/^active$/i) {
    $queue = 'ActiveQueueSize';
} elsif($plugin->opts->queue =~ m/^delayed$/i) {
    $queue = 'DelayedQueueSize';
} else {
    $plugin->nagios_die("Invalid Queue Specified.");
}
    

# XXX Need to be able to specify this on the command line
my $control = Ecelerity::Control->new( { Control => $plugin->opts->console, 
                                            User => $plugin->opts->user, 
                                            Pass => $plugin->opts->password } );
$control->connect();

local $SIG{ALRM} = sub { nagios_die("ec_console summary query timed out"); };
alarm $plugin->opts->timeout;
my $response = (XMLin($control->command('xml','summary'))) ;
alarm 0;

$plugin->add_message(
    $plugin->check_threshold($response->{'ActiveQueueSize'}), 
    $queue);

$plugin->add_perfdata(
      label => $queue,
      value => $response->{'ActiveQueueSize'},
      uom => undef
      );

$plugin->nagios_exit($plugin->check_messages);
