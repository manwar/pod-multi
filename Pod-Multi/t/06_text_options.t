# t/06_text_options.t - check handling of options for text
use strict;
use warnings;
use Test::More 
# tests => 63;
qw(no_plan);
use lib( "t/lib" );
use Pod::Multi::Auxiliary qw( stringify );

BEGIN {
    use_ok( 'Pod::Multi' );
    use_ok( 'File::Temp', qw| tempdir | );
    use_ok( 'File::Copy' );
    use_ok( 'File::Basename' );
    use_ok( 'Carp' );
    use_ok( 'Cwd' );
    use_ok( 'IO::Capture::Stderr');
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
    
    my $maxwidth = 72;
    ok(pod2multi(
        source => $testpod, 
        options => {
            text => {
                width   => $maxwidth,
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

#    open my $FH, "$tempdir/$pred{text}" or croak "Unable to open output";
#    my $overcount = 0;
#    while (<$FH>) {
#        chomp;
#        if (length($_) > $maxwidth) {
#            $overcount++;
#            last;
#        }
#    }
#    close $FH or croak "Unable to close handle";
#    ok(! $overcount, "no line exceeded maximum requested");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    my $margin = 2;
    ok(pod2multi(
        source => $testpod, 
        options => {
            text => {
                margin  => $margin,
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

#    open my $FH, "$tempdir/$pred{text}" or croak "Unable to open output";
#    my $overcount = 0;
#    while (<$FH>) {
#        chomp;
#        if ($_ !~ /^\s{2}/ and $_ !~ /^$/) {
#            $overcount++;
#            last;
#        }
#    }
#    close $FH or croak "Unable to close handle";
#    ok(! $overcount, "each line had left margin requested");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    ok(pod2multi(
        source => $testpod, 
        options => {
            text => {
                alt => 1,
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

#    open my $FH, "$tempdir/$pred{text}" or croak "Unable to open output";
#    my $seen = 0;
#    while (<$FH>) {
#        chomp;
#        if (/^:\s+\* Bullet Point One/) {
#            $seen++;
#            last;
#        }
#    }
#    close $FH or croak "Unable to close handle";
#    ok($seen, "alternate format detected via different regex");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    ok(pod2multi(
        source => $testpod, 
        options => {
            text => {
                alt => 1,
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

#    open my $FH, "$tempdir/$pred{text}" or croak "Unable to open output";
#    my $seen = 0;
#    while (<$FH>) {
#        chomp;
#        if (/^:   \* Bullet Point One/) {
#            $seen++;
#            last;
#        }
#    }
#    close $FH or croak "Unable to close handle";
#    ok($seen, "alternate format detected");
}

# Activating this block caused 2 later blocks ("code")
# to fail
{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    my $secondary_dir = "secondary";
    mkdir $secondary_dir or croak "Unable to make $secondary_dir";
    ok(-d $secondary_dir, "secondary testing directory created");
    ok(pod2multi(
        source => $testpod, 
        options => {
            text => {
                outputpath => "$tempdir/$secondary_dir",
            },
        },
    ), "pod2multi completed");
    ok(-f "$tempdir/$secondary_dir/$pred{text}", 
        "pod2text created in specified alternate directory");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");
}

#{
#    # Call for secondary directory but fail to create it
#    my $tempdir = tempdir( CLEANUP => 1 );
#    chdir $tempdir or croak "Unable to change to $tempdir";
#    my $testpod = "$tempdir/$stub";
#    copy ($pod, $testpod) or croak "Unable to copy $pod";
#    ok(-f $testpod, "sample pod copied for testing");
#    
#    my $secondary_dir = "secondary/";
#    my $capture = IO::Capture::Stderr->new();
#    $capture->start();
#    my $rv = pod2multi(
#        source => $testpod, 
#        options => {
#            text => {
#                outputpath => "$tempdir/$secondary_dir",
#            },
#        },
#    );
#    $capture->stop();
#    ok($rv, "pod2multi completed");
#### FIX ME FIRST
#    like($capture->read(), 
#        qr{^$tempdir/$secondary_dir is not a valid directory; reverting to $tempdir},
#        "warning of absence of directory requested correctly emitted");
#    ok(-f "$tempdir/$pred{text}", 
#        "pod2text created in default directory");
#    ok(-f "$tempdir/$pred{man}", "pod2man worked");
#    ok(-f "$tempdir/$pred{html}", "pod2html worked");
#}
#
#{
#    my $tempdir = tempdir( CLEANUP => 1 );
#    chdir $tempdir or croak "Unable to change to $tempdir";
#    my $testpod = "$tempdir/$stub";
#    copy ($pod, $testpod) or croak "Unable to copy $pod";
#    ok(-f $testpod, "sample pod copied for testing");
#    
#    my $secondary_dir = "secondary/";
#    mkdir $secondary_dir or croak "Unable to make $secondary_dir";
#    ok(-d $secondary_dir, "secondary testing directory created");
#    ok(pod2multi(
#        source => $testpod, 
#        options => {
#            text => {
#                outputpath => "$tempdir/$secondary_dir",
#            },
#        },
#    ), "pod2multi completed");
#    ok(-f "$tempdir/$secondary_dir/$pred{text}", 
#        "pod2text created in specified alternate directory");
#    ok(-f "$tempdir/$pred{man}", "pod2man worked");
#    ok(-f "$tempdir/$pred{html}", "pod2html worked");
#}

$pod = "$cwd/t/lib/s2.pod";
ok(-f $pod, "pod sample file located");
($name, $path, $suffix) = fileparse($pod, qr{\.pod});
$stub = "$name$suffix";
$htmltitle = q(This is the HTML title);
%pred = (
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
            text => {
                code  => 0,
            },
        },
    ), "pod2multi completed");
#####
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

#    open my $FH, "$tempdir/$pred{text}" or croak "Unable to open output";
#    my $seen = 0;
#    while (<$FH>) {
#        chomp;
#        if (m{^#!/usr/bin/perl}) {
#            $seen++;
#            last;
#        }
#    }
#    close $FH or croak "Unable to close handle";
#    ok(! $seen, "code option worked as intended");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    ok(pod2multi(
        source => $testpod, 
        options => {
            text => {
                code  => 1,
            },
        },
    ), "pod2multi completed");
#####
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

#    open my $FH, "$tempdir/$pred{text}" or croak "Unable to open output";
#    my $seen = 0;
#    while (<$FH>) {
#        chomp;
#        if (m{^#!/usr/bin/perl}) {
#            $seen++;
#            last;
#        }
#    }
#    close $FH or croak "Unable to close handle";
#    ok($seen, "code option worked as intended:  code printed");

    ok(chdir $cwd, "Changed back to original directory");
}

