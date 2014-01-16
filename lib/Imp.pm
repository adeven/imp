package Imp;

require Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(include run);

use strict;
use warnings;

use Imp::Portage;
use Imp::System;
use Imp::Template;

our $VERSION = '0.0.1';

sub include {
    my $include = shift;
    eval { system("./bin/$include") == 0 or die $!; };
    print $@ if $@;
}

sub run {
    my $cmd = shift;
    system($cmd ) == 0 or die $!;
}

1;
