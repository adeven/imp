package Imp::System::Path;

use strict;
use warnings;

use Moo;
use File::Path;

has user  => ( is => 'rw' );
has group => ( is => 'rw' );
has mode  => ( is => 'rw' );
has dir   => ( is => 'rw' );
has fh    => ( is => 'rw' );

sub BUILD {
    my $self = shift;
}

sub create {
    my $self = shift;
    $self->_set_default;
    $self->_create_dir;
    $self->_set_owner;
    $self->_unset_default;
}

sub create_file {
    my $self = shift;
    open my $fh, '>', $self->{fh};
    close($fh);
    $self->_set_owner;
}

sub modify {
    my $self = shift;
    my $fh;
    $fh = $self->{dir} if defined( $self->dir );
    $fh = $self->{fh}  if defined( $self->fh );

    my $_uid = ( stat $fh )[4];
    my $_gid = ( stat $fh )[5];
    if ( $self->user ) {
        my ( $login, $pass, $uid, $ugid ) = getpwnam( $self->{user} );
        $_uid = $uid;
    }
    if ( $self->group ) {
        my ( $group, $sep, $gid ) = getgrnam( $self->{group} );
        $_gid = $gid;
    }
    chown $_uid, $_gid, $fh;
    if ( $self->mode ) {
        chmod oct( $self->{mode} ), $fh;
    }
}

sub delete {

    #TODO: implement
}

sub _set_default {
    my $self = shift;
    $self->user('root')  unless $self->user;
    $self->group('root') unless $self->group;
    $self->mode('0600')  unless $self->mode;
}

sub _unset_default {
    my $self = shift;
    $self->user(undef)  if $self->{user} eq 'root';
    $self->group(undef) if $self->{group} eq 'root';
    $self->mode(undef)  if $self->{mode} eq '0600';
}

sub _create_dir {
    my $self = shift;
    mkpath( $self->{dir}, { user => $self->{user}, group => $self->{group} } );
}

sub _set_owner {
    my $self = shift;
    my $fh;
    $fh = $self->{dir} if defined( $self->dir );
    $fh = $self->{fh}  if defined( $self->fh );
    my ( $login, $pass, $uid, $ugid ) = getpwnam( $self->{user} );
    my ( $group, $sep, $gid ) = getgrnam( $self->{group} );
    chown $uid, $gid, $fh;
    chmod oct( $self->{mode} ), $fh;
}

1;
