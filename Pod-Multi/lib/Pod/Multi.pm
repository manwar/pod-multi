package Pod::Multi;
#$Id#
use strict;
use warnings;
use Exporter ();
use vars qw($VERSION @ISA @EXPORT);
$VERSION     = '0.01';
@ISA         = qw(Exporter);
@EXPORT      = qw( pod2multi );
use Pod::Text;
use Pod::Man;
use Pod::HTML;
use Carp;
use File::Basename;

sub pod2multi {
    croak "Must supply name of file containing POD" unless @_;
    my @args = @_;
    my $pod = $args[0];
    # use File::Basename here to construct output names
    my $htmltitle;
    if (@args > 1) {
        $htmltitle = join q{ }, @args[1..$#args];
    }
    my %options;
    $options{text} = $options{man} = $options{html} = {};
    my @textoptions = %{$options{text}};
    my $tparser = Pod::Text->new(@textoptions);
#    $tparser->parse_from_file($pod, $name);
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
        man     =>  {
            manoption1  => 'manvalue1',
            manoption2  => 'manvalue2',
            ...
        },
        text     =>  {
            textoption1  => 'textvalue1',
            textoption2  => 'textvalue2',
            ...
        },
        html     =>  {
            htmloption1  => 'htmlvalue1',
            htmloption2  => 'htmlvalue2',
            title        => q{Title for HTML Version},
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

  pod2multi(
    source  => "/path/to/file_with_pod",
    options => {
        man     =>  {
            manoption1  => 'manvalue1',
            manoption2  => 'manvalue2',
            ...
        },
        text     =>  {
            textoption1  => 'textvalue1',
            textoption2  => 'textvalue2',
            ...
        },
        html     =>  {
            htmloption1  => 'htmlvalue1',
            htmloption2  => 'htmlvalue2',
            title        => q{Title for HTML Version},
            ...
        },
    },
  );

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
the C<options> key must be a reference to a hash (named or anonymous) whose
keys name various output formats.  Currently, the only output formats
supported are manpage, text and html, and you always get all three.  However,
if, for instance, you are satisfied with the default options for F<pod2man>
and F<pod2html> but want your plain-text versions to have a width of 72
characters instead of F<pod2text>'s default 76 versions.  Then you could call
F<pod2multi()> as follows:

  pod2multi(
    source  => "/path/to/file_with_pod",
    options => {
        text     =>  { '-w' => 72 },
    },
  );

or like this:

  pod2multi(
    source  => "/path/to/file_with_pod",
    options => {
        text     =>  { '--width' => 72 },
    },
  );

In this instance, since F<pod2text> supports either a short option (C<-w>) or
a long option (C<--width>), F<pod2multi()> does so as well.  Consult the
documentation for any of the three currently supported output formats with
F<perldoc> or F<man>.

=head1 BUGS

None reported yet.

=head1 SUPPORT

Contact author at his cpan [dot] org address below.

=head1 AUTHOR

    James E Keenan
    CPAN ID: JKEENAN
    jkeenan@cpan.org
    http://search.cpan.org/~jkeenan/

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

