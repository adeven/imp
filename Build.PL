#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Module::Build;
use Getopt::Long;

my $v = '0.0.1';

my $builder = Module::Build->new(
    module_name        => 'Imp',
    dist_abstract      => 'Imp',
    build_requires     => { 'Test::More' => 0, },
    configure_requires => { 'Module::Build' => 0.38, },
    requires           => {
        'perl'          => 5.010,
        'Moo'           => 0,
        'Template'      => 0,
        'JSON'          => 0,
        'File::HomeDir' => 0,
    },
    add_to_cleanup     => ['Build _build MYMETA.* log/*.log'],
    create_makefile_pl => 'traditional',

    meta_add => {
        no_index => { directory => ['t'], },
        version => $v,
        release_status => 'unstable',
    },
    script_files => [],
    meta_merge   => {
        provides => {
            'Imp' => {
                file    => 'lib/Imp.pm',
                version => $v,
            },
        },
    },

);

$builder->create_build_script();
