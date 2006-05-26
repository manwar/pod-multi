# t/01_load.t - check module loading and create testing directory
use strict;
use warnings;
use Test::More 
# tests => 1;
qw(no_plan);

BEGIN { use_ok( 'Pod::Multi' ); }

my $pod = "./t/lib/sample.pod";
ok(pod2multi($pod), "pod2multi completed");
ok(pod2multi($pod, 'Title', 'for', 'HTML'), 
    "pod2multi completed with title supplied for HTML");


