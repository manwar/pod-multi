# t/09_bad_personal_defaults.t - check what happens with defective personal
# defaults file
use strict;
use warnings;
use Test::More 
# tests => 30;
qw(no_plan);

BEGIN {
    use_ok( 'Pod::Multi' );
    use_ok( 'File::Temp', qw| tempdir | );
    use_ok( 'File::Copy' );
    use_ok( 'File::Basename' );
    use_ok( 'Carp' );
    use_ok( 'Cwd' );
}
use lib( "./t/lib" );
use_ok( 'Pod::Multi::Auxiliary', qw(
        _subclass_preparatory_tests
        _subclass_cleanup_tests
    )
);

#        stringify
#        _save_pretesting_status
#        _restore_pretesting_status

my $cwd = cwd();
my $prepref = _subclass_preparatory_tests($cwd);
my $persref         = $prepref->{persref};
my $pers_def_ref    = $prepref->{pers_def_ref};
my %els1            = %{ $prepref->{initial_els_ref} };
my $eumm_dir        = $prepref->{eumm_dir};
my $mmkr_dir_ref    = $prepref->{mmkr_dir_ref};

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

#{
#
#    my $alt    = 'Alt_block_new_method.pm';
#    copy( "$prepref->{sourcedir}/$alt", "$eumm_dir/$alt")
#        or die "Unable to copy $alt for testing: $!";
#    ok(-f "$eumm_dir/$alt", "file copied for testing");


END {
    _subclass_cleanup_tests( {
        persref         => $persref,
        pers_def_ref    => $pers_def_ref,
        eumm_dir        => $eumm_dir,
        initial_els_ref => \%els1,
        odir            => $cwd,
        mmkr_dir_ref    => $mmkr_dir_ref,
    } );
}


__END__

{
TODO: {
  local $TODO = "Test will need alternate (defective) personal defaults file during testing";

    ok(chdir $cwd, "Changed back to original directory");
  }
}
{
    my $tempdir = tempdir( CLEANUP => 1 );
    chdir $tempdir or croak "Unable to change to $tempdir";
    my $testpod = "$tempdir/$stub";
    copy ($pod, $testpod) or croak "Unable to copy $pod";
    ok(-f $testpod, "sample pod copied for testing");

    eval { 
        system(
            qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/pod2multi" $testpod }
        );
    };
    like($@, qr{^Value of personal defaults option},
        "pod2multi correctly failed due bad format in personal defaults file");

    ok(chdir $cwd, "Changed back to original directory");
}

