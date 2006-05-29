# t/02_bad_args.t - check handling of bad arguments
use strict;
use warnings;
use Test::More 
tests => 17;
# qw(no_plan);

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
    
    eval { pod2multi( source => $testpod, q{options}); };
    like($@, qr{^Must supply even number of arguments},
        "pod2multi correctly failed due to odd number of arguments");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    eval { pod2multi( options => {} ); };
    like($@, qr{^Must supply source file with pod},
        "pod2multi correctly failed due to lack of 'source' key-value pair");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    eval { pod2multi( source => 'phonyfile', options => {} ); };
    like($@, qr{^Must supply source file with pod},
        "pod2multi correctly failed due to non-existent source file");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    eval { pod2multi( source => $testpod, options => [] ); };
    like($@, qr{^Options must be supplied in a hash ref},
        "pod2multi correctly failed due to options in wrong ref");
}

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    eval { pod2multi(
        source => $testpod, 
        options => {
            html => [
                title   => q{This is the HTML title},
            ],
        },
    ) };
    like($@, qr{^Value of option html must be a hash ref},
        "pod2multi correctly failed due to options in wrong ref");
}

