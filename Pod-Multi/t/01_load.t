# t/01_load.t - check module loading and create testing directory
use strict;
use warnings;
use Test::More 
tests => 21;
# qw(no_plan);

BEGIN {
    use_ok( 'Pod::Multi' );
    use_ok( 'Pod::Text' );
    use_ok( 'Pod::Man' );
    use_ok( 'Pod::Html' );
    use_ok( 'File::Temp', qw| tempdir | );
    use_ok( 'File::Copy' );
    use_ok( 'File::Basename' );
    use_ok( 'File::Save::Home', qw|
        get_home_directory
        get_subhome_directory_status
        make_subhome_directory
        restore_subhome_directory_status
    | );
    use_ok( 'Carp' );
    use_ok( 'Cwd' );
    use_ok( 'IO::Capture' );
}


my $realhome;
ok( $realhome = get_home_directory(), 
    "HOME or home-equivalent directory found on system");

my $mmkr_dir_ref = get_subhome_directory_status(".pod2multi");
my $mmkr_dir = make_subhome_directory($mmkr_dir_ref);
ok( $mmkr_dir, "personal defaults directory found on system");

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
    
    ok(pod2multi( source => $testpod ), "pod2multi completed");
    ok(-f "$tempdir/$pred{text}", "pod2text worked");
    ok(-f "$tempdir/$pred{man}", "pod2man worked");
    ok(-f "$tempdir/$pred{html}", "pod2html worked");

    ok(chdir $cwd, "Changed back to original directory");
}

END {
    ok( restore_subhome_directory_status($mmkr_dir_ref),
        "original presence/absence of .pod2multi directory restored");
}

