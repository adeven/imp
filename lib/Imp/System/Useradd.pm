package Imp::System::Useradd;

use strict;
use warnings;

use Moo;
use POSIX qw(setuid setgid);
use File::Basename;
use autodie;

use Imp::Cpan;

has uid     => ( is => 'rw' );
has gid     => ( is => 'rw' );
has pkg     => ( is => 'rw' );
has url     => ( is => 'rw' );
has user    => ( is => 'rw' );
has homedir => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_set_pkg;
}

sub create {
    my $self = shift;
    $self->user(shift);
    return unless $self->user();
    $self->homedir("/home/$self->{user}") unless $self->homedir;
    $self->_check_user;
    $self->_create_user unless $self->uid;
    my $pid = fork();
    if ( $pid == 0 ) {
        setgid( $self->{gid} ) or die $!;
        setuid( $self->{uid} ) or die $!;
        $self->_bootstrap_locallib;
        exit(0);
    }
    else {
        waitpid( $pid, 0 );
    }
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

sub _set_pkg {
    my $self     = shift;
    my $base_url = "http://search.cpan.org/CPAN/authors/id/E/ET/ETHER/";
    my $pkg      = 'local-lib-1.008011.tar.gz';

    # TODO return latest pkg
    $self->pkg($pkg);
    $self->url( $base_url . $pkg );
}

sub _bootstrap_locallib {
    my $self = shift;
    my $cpan = Imp::Cpan->new(
        user    => $self->user,
        homedir => $self->homedir,
    );
    chdir( $ENV{'HOME'} );
    system("wget $self->{url}") == 0   or die $!;
    system("tar xf $self->{pkg}") == 0 or die $!;
    chdir( basename( $self->{pkg}, ".tar.gz" ) );
    system("perl Makefile.PL --bootstrap") == 0;
    system("make") == 0;
    system(" make install ") == 0;
}

1;
