package Pod::Multi;
#$Id#
require 5.006001;
use strict;
use warnings;
use Exporter ();
our ($VERSION, @ISA, @EXPORT);
$VERSION     = 0.05;
@ISA         = qw( Exporter );
@EXPORT      = qw( pod2multi );
use Pod::Text;
use Pod::Man;
use Pod::Html;
use Carp;
use File::Basename;
use File::Path;
use File::Spec;
use File::Save::Home qw(
    get_home_directory
);
use Data::Dumper;

sub pod2multi {
    croak "Must supply even number of arguments:  list of key-value pairs"
        if @_ % 2;
    my %args = @_;
    croak "Must supply source file with pod"
        unless (exists $args{source} and -f $args{source});

    my $pod = $args{source};
    my @text_and_man = qw(text man);
    my @all_formats_accepted = (@text_and_man, q{html});

    # to pull in any %params defined in .pod2multirc
    our %params;  
    my $homedir = get_home_directory();
    my $personal_defaults_file = "$homedir/.pod2multirc";
    require $personal_defaults_file if -f $personal_defaults_file;

    # At this point, if the personal defaults file exists, %params 
    # should be populated with any values defined in the %params in that 
    # defaults file.  Those values will be overriden with any defined in a 
    # Perl script and passed to pod2multi() as arguments.

    if (defined %params) {
        foreach my $outputformat (keys %params) {
            croak "Value of personal defaults option $outputformat must be a hash ref"
            unless ref($params{$outputformat}) eq 'HASH';
        }
    }

    if (exists $args{options}) {
        croak "Options must be supplied in a hash ref"
            unless ref($args{options}) eq 'HASH';
        my %ao = %{$args{options}};
        for my $outputmode (keys %ao) {
            croak "Value of option $outputmode must be a hash ref"
                unless ref($ao{$outputmode}) eq 'HASH';
            my %attr = %{$ao{$outputmode}};
            for my $attribute (keys %attr) {
                $params{$outputmode}{$attribute} = $attr{$attribute};
            }
        }
    }

    my ($basename, $path, $suffix) 
        = fileparse($pod, ( qr/\.pm/, qr/\.pl/, qr/\.pod/ ) );
    my $manext;
    if ($suffix) {
        if ($suffix =~ /\.pm/) {
            $manext = q{.3};
        } else {
            $manext = q{.1};
        }
    } else {
        $manext = q{.1};
    }
    
    my %options;
    # For text and man, the only things which need special attention are the 
    # directory, file name and extension;
    # everything else in %options is passed directly to the underlying
    # function.
    for my $f (@text_and_man) {
        $options{$f} = exists $params{$f} ? $params{$f} : {};
    }
    
    my %outputpaths;
    for my $f (@text_and_man) {
        if (exists $options{$f}{outputpath}) {
            if (-d $options{$f}{outputpath}) {
                $outputpaths{$f} = $options{$f}{outputpath}; 
            } else {
                warn "$options{$f}{outputpath} is not a valid directory; reverting to $path";
                $outputpaths{$f} = $path;
            }
        } else {
            $outputpaths{$f} = $path;
        }
        $outputpaths{$f} .= q{/} if $outputpaths{$f} !~ m{/$}; 
    }

    # text
    my $tparser = Pod::Text->new(%{$options{text}});
    $tparser->parse_from_file(
        $pod, "$outputpaths{text}$basename.txt"
    );

    # man
    my $mparser = Pod::Man->new(%{$options{man}});
    $mparser->parse_from_file(
        $pod, "$outputpaths{man}$basename$manext"
    );

    # html
    # html works differently.  We first populate %options.
    if (defined $params{html}{infile}) {
        croak "You cannot define a source file for the HTML output different from that of the text and man outputs";
    }
    %{$options{html}} = defined $params{html} ?  %{$params{html}} : ();
    $options{html}{infile} = $pod;
    $options{html}{outfile} = "$path$basename.html" 
        unless defined $params{html}{outfile};
    $options{html}{title} = defined $params{html}{title}
        ? $params{html}{title}
        : $basename;
    # Then we compose the long-options-style string to be passed to the
    # underlying function.
    my @htmlargs;
    foreach my $htmlopt (keys %{$options{html}}) {
        push @htmlargs, "--${htmlopt}=$options{html}{$htmlopt}";
    }
    Pod::Html::pod2html( @htmlargs );

    return 1;
}

1;

#################### DOCUMENTATION #################### 

=head1 NAME

Pod::Multi - pod2man, pod2text, pod2html simultaneously

=head1 SYNOPSIS

From the command-line:

  pod2multi file_with_pod

or:

  pod2multi file_with_pod Title for HTML Version

Inside a Perl program:

  use Pod::Multi;

  pod2multi("/path/to/file_with_pod");

or:

  pod2multi(
    source  => "/path/to/file_with_pod",
    options => {
        text     => {
            sentence    =>  0,
            width       => 78,
            outputpath  => "/outputpath/for/text/",
            ...
        },
        man     => {
            manoption1  => 'manvalue1',
            manoption2  => 'manvalue2',
            outputpath  => "/outputpath/for/man/",
            ...
        },
        html     => {
            infile       => "/path/to/infile",
            outfile      => "/path/to/outfile",
            title        => "Title for HTML",
            ...
        },
    },
  );

=head1 DESCRIPTION

When you install a Perl module from CPAN, documentation gets installed which
is readable with F<perldoc> and (at least on *nix-like systems) with F<man> as
well.  You can convert that documentation to text and HTML formats with two
utilities that come along with Perl:  F<pod2text> and F<pod2html>.

In production environments documentation of Perl I<programs> tends to be less
rigorous than that of CPAN modules.  If you want to convince your co-workers
of the value of writing documentation for such programs, you may want a
painless way to create that documentation in a variety of formats.  If you
already know how to write documentation in Perl's Plain Old Documentation
(POD) format, Pod::Multi will save you keystrokes by simultaneously generating
documentation in manpage, plain-text and HTML formats from a source file
containing POD.

In its current version, Pod::Multi creates those documentary files in the same
directory as the source file.  It does not attempt to install those files
anywhere else.  In particular, it does not attempt to install the manpage
version in a MANPATH directory.  This may change in a future version, but for
the time being, we're keeping it simple.

Pod::Multi is intended to be used primarily via its associated command-line
utility, F<pod2multi>.  F<pod2multi> requires only one argument:  the path to
a file containing documentation in POD format.  In the interest of simplicity,
any other arguments provided on the command-line are concatenated into a
wordspace-separated string which will serve as the title tag of the HTML
version of the documentation.  No other options are offered because, in the
author's opinion, if you want more options you'll probably use as many
keystrokes as you would if you ran F<pod2man>, F<pod2text> or F<pod2html>
individually. 

The functional interface may be used inside Perl
programs and, if you have personal preferences for the options you would
normally provide to F<pod2man>, F<pod2text> or F<pod2html>, you can specify
them in the functional interface.  (In a future version, you'll have the
option of saving those preferences to a personal defaults file stored
underneath your home directory.)

=head1 USAGE

=head2 Functional Interface

When called into a Perl program via C<use>, C<require> or C<do>, Pod::Multi
automatically exports a single function:  C<pod2multi>.

=head3 Default Case:  Single Argument

  pod2multi("/path/to/file_with_pod");

This is analogous to the default case in the command-line interface (above).
If pod2multi is supplied with just one argument, it assumes that that argument
is the path to a file containing documentation in POD format and proceeds to
create files called F<file_with_pod.man>, F<file_with_pod.txt> and
F<file_with_pod.html> in directory F</path/to/> (assuming that directory is
writable).  The title tag for the HTML version will be C<file_with_pod>.

=head3 Alternative Case:  Multiple Arguments in List of Key-Value Pairs

This is how Pod::Multi works internally; otherwise it's only recommended for
people who have strong preferences.  Arguments can be provided to
F<pod2multi()> in a list of key-value pairs subject to the following
requirements:

=over 4

=item * C<source>

The C<source> key is mandatory; its value must be the path to the source file
containing documentation in the POD format.

=item * C<options>

The C<options> key is, of course, optional.  (But why would you use the
multiple argument version unless you wanted to specify options?)  The value of
the C<options> key must be a reference to an hash (named or anonymous) which
holds a list of key-value pairs.

=over 4

=item * C<$options{text}>

With one exception, the key-value pairs are those you would normally supply to 
C<Pod::Text::new()>.

    text => {
        sentence    =>  0,
        width       => 78,
        ...
    },

The exception is that if you wish to specify a directory
for the creation of the output file, you may do so with the C<outputpath>
option.

    text => {
        outputpath  => /path/to/textoutput/,
        ...
    },
    
Internally, C<pod2multi()> prepends this to the basename of the
source file and provides the result as the second argument to
C<Pod::Text::parse_from_file()>.  Note that this is a directory where the
output file will reside -- I<not> the full path to that file.

=item * C<$options{man}>

With one exception, the key-value pairs are those you would normally supply to 
C<Pod::Man::new()>.

    man => {
        release     => $VERSION,
        section     => 8,
        ...
    },

The exception is that if you wish to specify a directory
for the creation of the output file, you may do so with the C<outputpath>
option.

    man => {
        outputpath  => /path/to/manoutput/,
        ...
    },
    
Internally, C<pod2multi()> prepends this to the basename of the
source file and provides the result as the second argument to
C<Pod::Man::parse_from_file()>.  Note that this is a directory where the
output file will reside -- I<not> the full path to that file.

=item * C<$options{html}>

The C<html> option works in the same way as <text> and <man>, except that
there is no <outputpath> sub-option.  That's because the key-value pairs which
should be supplied via hash reference to C<$options{html} are the contents of
the ''long options'' normally supplied to C<Pod::Html::pod2html>.  That
function, which <pod2multi()> calls internally, expects arguments in the long
option format:

    --infile=/path/to/source,
    --outfile=/path/to/htmloutput,
    --title="Title for HTML",

... rather than in list-of-key-value-pairs format.  For consistency,
C<pod2multi()> expects arguments to C<$options{html}> in the same format as to
C<$options{text}> and C<$options{man}>, then converts them internally to the
long options needed by C<Pod::Html::pod2html()>.

    html    => {
        infile   => "/path/to/source",
        outfile  => "/path/to/htmloutput",
        title    => "Title for HTML",
        ...
    },
        
=back

=back

=head2 Command-Line Interface

=head3 Default Case

  pod2multi file_with_pod

Will create files called F<file_with_pod.man>, F<file_with_pod.txt> and
F<file_with_pod.html> in the same directory where F<file_with_pod> is located.
You must have write permissions to that directory.  The name F<file_with_pod>
cannot contain wordspaces.  These files will be created with the default
options you would get by calling F<pod2man>, F<pod2text> and F<pod2html>
individually.  The title tag in the HTML version will be C<file_with_pod>.

=head3 Provide Title Tag for HTML Version

  pod2multi file_with_pod Title for HTML Version

Exactly the same as the default case, with one exception:  the title tag in
the HTML version will be C<Title for HTML Version>.

=head1 BUGS

None reported yet.

=head1 SUPPORT

Contact author at his cpan [dot] org address below.

=head1 AUTHOR

    James E Keenan
    CPAN ID: JKEENAN
    jkeenan@cpan.org
    http://search.cpan.org/~jkeenan/

=head1 ACKNOWLEDGEMENTS

Steven Lembark made the suggestion about submitting all modules needed to a
C<use_ok> at the start of the very first test.

David H Adler assisted with debugging.

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

perl(1).  perldoc(1).  man(1).
pod2man(1).  pod2text(1).  pod2html(1).
Pod::Man(3pm).  Pod::Text(3pm).  Pod::Html(3pm).

=cut
