package Pod::Multi::Auxiliary;
#$Id#
require 5.006001;
use strict;
use warnings;
use Exporter ();
our ($VERSION, @ISA, @EXPORT_OK);
$VERSION     = '0.01';
@ISA         = qw( Exporter );
@EXPORT_OK   = qw( stringify );
use Carp;

sub stringify {
    my $output = shift;
    local $/;
    open my $FH, $output or croak "Unable to open $output";
    my $str = <$FH>;
    close $FH or croak "Unable to close $output";
    return $str;
}

1;
