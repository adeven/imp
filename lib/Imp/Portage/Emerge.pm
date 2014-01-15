package Imp::Portage::Emerge;

use strict;
use warnings;

use Moo;

sub BUILD {
    my $self = shift;
}

sub install {
    my $self = shift;
    my $pkg  = shift;
    say "installing $pkg...";
    system("emerge -qg $pkg") == 0
      or say "while emerging $pkg: $!";
    say "installed $pkg";
}

sub update {
    my $self = shift;
    $self->_sync;
    $self->_world_update;
    $self->_depclean;
    $self->_python_updater;
}

sub _sync {
    my $self = shift;
    my $cmd  = 'emerge --sync --quiet';
    say 'starting sync...';
    system($cmd) == 0
      or say 'sync failed: ' . $?;
    say 'finished sync...';
}

sub _depclean {
    my $self = shift;
    my $cmd  = 'emerge --depclean --quiet';
    say 'starting depclean...';
    system($cmd) == 0
      or say "depclean failed: " . $?;
    say 'finished depclean...';
}

sub _python_updater {
    my $self = shift;
    my $cmd  = 'python-updater';
    say 'starting python-updater...';
    system($cmd) == 0
      or say "python-updater failed: " . $?;
    say 'finished python-updater...';
}

sub _world_update {
    my $self = shift;
    my $cmd  = 'emerge -qguND world > /dev/null 2>&1';
    say 'starting compile phase...';
    system($cmd ) == 0
      or say 'compile failed: ' . $?;
    say 'finished compile phase';
}

1;
