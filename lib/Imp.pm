package Imp;

require Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(include);

use strict;
use warnings;

use Imp::Portage;
use Imp::System;
use Imp::Template;

our $VERSION = '0.0.1';
our $HOME    = '/var/lib/imp/current';

sub include {
    my $include = shift;
    eval { system("./bin/$include") == 0 or die $!; };
    print $@ if $@;
}

1;
