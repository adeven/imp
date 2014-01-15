package Imp::System;

use strict;
use warnings;

use Moo;
use Imp::System::Useradd;
use Imp::System::Cron;
use Imp::System::Path;

sub BUILD {
    my $self = shift;
}

sub rc_start {
    my $self    = shift;
    my $service = shift;
    $self->_action( $service, 'start' );
}

sub rc_stop {
    my $self    = shift;
    my $service = shift;
    $self->_action( $service, 'stop' );
}

sub rc_restart {
    my $self    = shift;
    my $service = shift;
    $self->_action( $service, 'restart' );
}

sub rc_add_default {
    my $self    = shift;
    my $service = shift;
    symlink "/etc/init.d/$service", "/etc/runlevels/default/$service";
}

sub rc_del_default {
    my $self    = shift;
    my $service = shift;
    unlink "/etc/runlevels/default/$service";
}

sub _action {
    my $self    = shift;
    my $service = shift;
    my $action  = shift;
    say "going to $action $service...";
    my $cmd = "/etc/init.d/$service $action";
    if ( system($cmd ) != 0 ) {
        say "while ${action}ing $service: " . $?;
        exit(1);
    }
    say "${action}ed $service...";
}

1;
