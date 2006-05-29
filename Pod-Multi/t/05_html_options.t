# t/05_html_options.t - check that html options are working properly
use strict;
use warnings;
use Test::More 
tests => 26;
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

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    my $secondary_dir = "secondary";
    mkdir $secondary_dir or croak "Unable to make $secondary_dir";
    ok(-d $secondary_dir, "secondary testing directory created");
    my $htmlout = "$tempdir/$secondary_dir";
    ok(pod2multi(
        source => $testpod, 
        options => {
            html => {
                outfile => "$htmlout/$pred{html}",
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$htmlout/$pred{html}", "pod2html worked");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    my $secondary_dir = "secondary";
    mkdir $secondary_dir or croak "Unable to make $secondary_dir";
    ok(-d $secondary_dir, "secondary testing directory created");
    my $newtestpod = "$tempdir/$secondary_dir/$stub";
    copy ($testpod, $newtestpod) or croak "Unable to copy $testpod";
    ok(-f $newtestpod, "sample pod copied again for testing");
    ok(pod2multi(
        source => $testpod, 
        options => {
            html => {
                infile => $newtestpod,
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");
}

