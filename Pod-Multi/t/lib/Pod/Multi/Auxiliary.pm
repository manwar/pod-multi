package Pod::Multi::Auxiliary;
#$Id#
require 5.006001;
use strict;
use warnings;
use Exporter ();
our ($VERSION, @ISA, @EXPORT_OK);
$VERSION     = 0.03;
@ISA         = qw( Exporter );
@EXPORT_OK   = qw(
    stringify
    _process_personal_defaults_file 
    _reprocess_personal_defaults_file 
    _save_pretesting_status
); 
use Carp;
*ok = *Test::More::ok;

sub stringify {
    my $output = shift;
    local $/;
    open my $FH, $output or croak "Unable to open $output";
    my $str = <$FH>;
    close $FH or croak "Unable to close $output";
    return $str;
}

sub _save_pretesting_status {
    my $mmkr_dir_ref = get_subhome_directory_status(".pod2multi");
    my $mmkr_dir = make_subhome_directory($mmkr_dir_ref);
    ok( $mmkr_dir, "personal defaults directory now present on system");
    my $pers_file = "Pod/Multi/Personal/Defaults.pm";
    my $pers_def_ref = _process_personal_defaults_file(
        $mmkr_dir, 
        $pers_file,
    );
    return {
        cwd             => cwd(),
        mmkr_dir_ref    => $mmkr_dir_ref,
        pers_def_ref    => $pers_def_ref,
        mmkr_dir        => $mmkr_dir,   # needed in make_selections_defaults
        pers_file       => $pers_file,  # needed in make_selections_defaults
    }
}

sub _restore_pretesting_status {
    my $statusref = shift;
    _reprocess_personal_defaults_file($statusref->{pers_def_ref});
    ok(chdir $statusref->{cwd},
        "changed back to original directory after testing");
    ok( restore_subhome_directory_status($statusref->{mmkr_dir_ref}),
        "original presence/absence of .pod2multi directory restored");
}

sub _process_personal_defaults_file {
    my ($mmkr_dir, $pers_file) = @_;
    my $pers_file_hidden = $pers_file . '.hidden';
    my %pers;
    $pers{full} = File::Spec->catfile( $mmkr_dir, $pers_file );
    $pers{hidden} = File::Spec->catfile( $mmkr_dir, $pers_file_hidden );
    if (-f $pers{full}) {
        $pers{atime}   = (stat($pers{full}))[8];
        $pers{modtime} = (stat($pers{full}))[9];
        rename $pers{full},
               $pers{hidden}
            or croak "Unable to rename $pers{full}: $!";
        ok(! -f $pers{full}, 
            "personal defaults file temporarily suppressed");
        ok(-f $pers{hidden}, 
            "personal defaults file now hidden");
    } else {
        ok(! -f $pers{full}, 
            "personal defaults file not found");
        ok(1, "personal defaults file not found");
    }
    return { %pers };
}

sub _reprocess_personal_defaults_file {
    my $pers_def_ref = shift;;
    if(-f $pers_def_ref->{hidden} ) {
        rename $pers_def_ref->{hidden},
               $pers_def_ref->{full},
            or croak "Unable to rename $pers_def_ref->{hidden}: $!";
        ok(-f $pers_def_ref->{full}, 
            "personal defaults file re-established");
        ok(! -f $pers_def_ref->{hidden}, 
            "hidden personal defaults now gone");
        ok( (utime $pers_def_ref->{atime}, 
                   $pers_def_ref->{modtime}, 
                  ($pers_def_ref->{full})
            ), "atime and modtime of personal defaults file restored");
    } else {
        ok(1, "test not relevant");
        ok(1, "test not relevant");
        ok(1, "test not relevant");
    }
}

1;
