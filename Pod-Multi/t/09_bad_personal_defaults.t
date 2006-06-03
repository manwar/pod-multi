# t/09_bad_personal_defaults.t - check what happens with defective personal
# defaults file
use strict;
use warnings;
use Test::More 
tests => 19;
# qw(no_plan);

BEGIN {
    use_ok( 'Pod::Multi' );
    use_ok( 'File::Temp', qw| tempdir | );
    use_ok( 'File::Copy' );
    use_ok( 'File::Basename' );
    use_ok( 'Carp' );
    use_ok( 'Cwd' );
    use_ok( 'File::Save::Home', qw|
        get_home_directory
        conceal_target_file
        reveal_target_file
    | );
}

my $realhome;
ok( $realhome = get_home_directory(), 
    "HOME or home-equivalent directory found on system");
my $target_ref = conceal_target_file( {
    dir     => $realhome,
    file    => '.pod2multirc',
    test    => 1,
} );

my $cwd = cwd();

#my $prepref = _subclass_preparatory_tests($cwd);
#my $persref         = $prepref->{persref};
#my $pers_def_ref    = $prepref->{pers_def_ref};
#my %els1            = %{ $prepref->{initial_els_ref} };
#my $eumm_dir        = $prepref->{eumm_dir};
#my $mmkr_dir_ref    = $prepref->{mmkr_dir_ref};

my $pod = "$cwd/t/lib/s1.pod";
ok(-f $pod, "pod sample file located");
my ($name, $path, $suffix) = fileparse($pod, qr{\.pod});
my $stub = "$name$suffix";
my %pred = (
    text    => "$name.txt",
    man     => "$name.1",
    html    => "$name.html",
);


########################################################################

#my $altdir = "$cwd/t/lib/Pod/Multi/Personal";
#ok(-d $altdir, "path to bad defaults file exists");
#my $alt = "Defaults.pm";
#ok(-f "$altdir/$alt", "bad defaults file exists");
#copy("$altdir/$alt", "$eumm_dir/Personal/$alt")
#    or croak "Unable to copy bad defaults file for testing";
#ok(-f "$eumm_dir/Personal/$alt", 
#    "bad defaults file is now underneath home directory");
#my $tdir = cwd();
#my $testpod = "$tdir/$stub";
#copy ($pod, $testpod) or croak "Unable to copy $pod";
#ok(-f $testpod, "sample pod copied for testing");
#
#eval { pod2multi( source => $testpod ); };
#like($@, qr{^Value of personal defaults option},
#    "pod2multi correctly failed due bad format in personal defaults file");
#
#unlink("$eumm_dir/Personal/$alt") 
#    or croak "Unable to unlink bad defaults file after testing";
#ok(! -f "$eumm_dir/$alt", "bad defaults file removed after testing");

{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");
    
    copy ("$cwd/t/lib/.pod2multirc.bad", "$realhome/.pod2multirc")
        or croak "Unable to copy bad rc file for testing";
    ok(-f "$realhome/.pod2multirc", "bad rc file in place for testing");

    eval {
        pod2multi( source => $testpod );
    };
    like($@, qr{^Value of personal defaults option},
        "pod2multi correctly failed due bad format in personal defaults file");

    unlink "$realhome/.pod2multirc" 
        or croak "Unable to remove bad rc file after testing";
    ok(! -f "$realhome/.pod2multirc", "bad rc file deleted after testing");

    ok(chdir $cwd, "Changed back to original directory");
}

END { reveal_target_file($target_ref); }

