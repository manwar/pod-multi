# t/05_title.t - check what happens when no title for pod2html
use strict;
use warnings;
use Test::More 
tests => 13;
# qw(no_plan);
use lib( "t/lib" );
use Pod::Multi::Auxiliary qw( stringify );

BEGIN {
    use_ok( 'Pod::Multi' );
    use_ok( 'File::Temp', qw| tempdir | );
    use_ok( 'File::Copy' );
    use_ok( 'File::Basename' );
    use_ok( 'Carp' );
    use_ok( 'Cwd' );
}

my $cwd = cwd();
my $pod = "$cwd/t/lib/s1.pod";
ok(-f $pod, "pod sample file located");
my ($name, $path, $suffix) = fileparse($pod, qr{\.pod});
my $stub = "$name$suffix";
my $htmltitle = q(This is the HTML title);
my %pred = (
    text    => "$name.txt",
    man     => "$name.1",
    html    => "$name.html",
);

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    ok(pod2multi(
        source => $testpod, 
        options => {
            html => {
                title   => $htmltitle,
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

    # test that html title tag was set
    like(stringify("$tempdir/$pred{html}"), 
        qr{<title>This\sis\sthe\sHTML\stitle</title>},
       "HTML title tag located");
}

