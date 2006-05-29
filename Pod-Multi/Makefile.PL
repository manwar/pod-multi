

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Pod::Multi',
    VERSION_FROM => 'lib/Pod/Multi.pm', # finds \$VERSION
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'pod2man, pod2text, pod2html simultaneously',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'IO::Capture' => 0.05,
                    },
);
