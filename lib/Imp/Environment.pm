package Imp::Environment;

use strict;
use warnings;

use Moo;
use JSON;

## Portage Env Variables for make_conf
has CFLAGS          => ( is => 'rw' );
has CXXFLAGS        => ( is => 'rw' );
has ADD_USE         => ( is => 'rw' );
has USE_FLAGS       => ( is => 'rw' );
has MAKEOPTS        => ( is => 'rw' );
has PORTDIR_OVERLAY => ( is => 'rw' );
has FEATURES        => ( is => 'rw' );
has PORTAGE_BINHOST => ( is => 'rw' );

##
has data         => ( is => 'rw' );
has host         => ( is => 'rw', required => 1 );
has config_dir   => ( is => 'ro', required => 1 );
has template_dir => ( is => 'ro', required => 1 );

sub BUILD {
    my $self = shift;
    $self->_load_host_config;
    $self->CFLAGS('-O2 -pipe')   unless $self->CFLAGS;
    $self->CXXFLAGS('${CFLAGS}') unless $self->CXXFLAGS;
    $self->_set_use_flags;
    $self->_set_makeopts;
    $self->_set_features;
}

sub env {
    my $self = shift;
    my $data = {
        CFLAGS          => $self->CFLAGS,
        CXXFLAGS        => $self->CXXFLAGS,
        USE_FLAGS       => $self->USE_FLAGS,
        MAKEOPTS        => $self->MAKEOPTS,
        PORTDIR_OVERLAY => $self->PORTDIR_OVERLAY,
        FEATURES        => $self->FEATURES,
        PORTAGE_BINHOST => $self->PORTAGE_BINHOST,
    };
    return $data;
}

sub _load_host_config {
    my $self = shift;
    return unless $self->host;
    if ( !-f "$self->{config_dir}/$self->{host}.json" ) {
        print "WARNING: could not load env for $self->{host}\n";
        return;
    }
    my $data = {};
    local $/;
    open( my $fh, '<', "$self->{config_dir}/$self->{host}.json" );
    my $json_config = <$fh>;
    close($fh);
    my $config = decode_json($json_config);

    foreach my $key ( keys %$config ) {
        $$data{$key} = $config->{$key};
    }
    $self->data($data);
}

sub _set_use_flags {
    my $self        = shift;
    my $default_use = [
        '-X', '-alsa', '-cups', '-gnome', '-qt3', '-qt4', 'bzip2',
        'git', 'iproute2', 'ipv6', 'mmx', 'nls', 'perl', 'python', 'sse',
        'sse2', 'unicode', 'vim-syntax',
    ];
    push( @$default_use, @$self->ADD_USE ) if $self->ADD_USE;
    $self->USE_FLAGS($default_use);
}

sub _set_makeopts {
    my $self      = shift;
    my $cpu_count = `nproc`;
    chomp $cpu_count;
    $self->MAKEOPTS("-j$cpu_count");
    $self->MAKEOPTS('-j2') unless $self->MAKEOPTS;
}

sub _set_features {
    my $self = shift;
    my $default = [ 'buildpkg', 'parallel-fetch', 'sandbox', 'sfperms', 'strict' ];
    $self->FEATURES($default);
}

1;
