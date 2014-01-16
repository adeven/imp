package Imp::System::Useradd;

use strict;
use warnings;

use Moo;
use File::Basename;
use autodie;

has uid     => ( is => 'rw' );
has gid     => ( is => 'rw' );
has pkg     => ( is => 'rw' );
has url     => ( is => 'rw' );
has user    => ( is => 'rw' );
has homedir => ( is => 'rw' );

sub BUILD {
    my $self = shift;
}

sub create {
    my $self = shift;
    $self->user(shift);
    return unless $self->user();
    $self->homedir("/home/$self->{user}") unless $self->homedir;
    $self->_check_user;
    $self->_create_user unless $self->uid;
    my $info = {
        uid => $self->{uid},
        gid => $self->{gid},
    };
    return $info;
}

sub exist {
    my $self = shift;
    $self->user(shift);
    $self->_check_user;
    if ( $self->uid ) {
        return 1;
    }
    return 0;
}

sub _check_user {
    my $self = shift;
    my ( $name, $pw, $uid ) = getpwnam( $self->user );
    $self->uid($uid);
    my ( $gname, $gpw, $gid ) = getpwnam( $self->user );
    $self->gid($gid);
}

sub _create_user {
    my $self = shift;
    system("useradd -s /bin/bash -m $self->{user} -d $self->{homedir}");
    $self->_check_user;
}

1;
