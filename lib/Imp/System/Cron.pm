package Imp::System::Cron;

use strict;
use warnings;

use Moo;
use Imp::System::Path;

has user    => ( is => 'rw' );
has command => ( is => 'rw' );
has day     => ( is => 'rw' );
has hour    => ( is => 'rw' );
has minute  => ( is => 'rw' );
has month   => ( is => 'rw' );
has weekday => ( is => 'rw' );
has line    => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_set_default;
}

sub add {
    my $self = shift;
    die "no user"    unless $self->user;
    die "no command" unless $self->command;
    $self->_create_line;
    $self->_cron_group_user;
    $self->_parse_crontab;
    $self->_clear;
}

sub _create_line {
    my $self = shift;
    $self->_sanity_check;
    my $line =
"$self->{minute} $self->{hour} $self->{day} $self->{month} $self->{weekday} $self->{command}";
    $self->line($line);
}

sub _cron_group_user {
    my $self = shift;
    system("usermod -aG cron $self->{user}");
}

sub _parse_crontab {
    my $self     = shift;
    my $crontab  = "/var/spool/cron/crontabs/$self->{user}";
    my $cronfile = "";
    if ( -f $crontab ) {
        open my $rh, '<', $crontab;
        while (<$rh>) {
            $cronfile .= $_;
        }
        close($rh);
    }
    my $qm = quotemeta $self->{line};
    if ( $cronfile =~ /$qm/ ) {
        return;
    }
    $cronfile .= $self->{line} . "\n";
    open my $wh, '>', $crontab;
    print $wh $cronfile;
    close($wh);
    Imp::System::Path->new(
        user  => $self->{user},
        group => 'crontab',
        dir   => $crontab,
    )->modify;
    system("crontab -u $self->{user} /var/spool/cron/crontabs/$self->{user}");
}

sub _clear {
    my $self = shift;
    $self->day('*');
    $self->hour('*');
    $self->minute('*');
    $self->month('*');
    $self->weekday('*');
    $self->command(undef);
    $self->line(undef);
}

sub _set_default {
    my $self = shift;
    $self->day('*')     if !defined( $self->day );
    $self->hour('*')    if !defined( $self->hour );
    $self->minute('*')  if !defined( $self->minute );
    $self->month('*')   if !defined( $self->month );
    $self->weekday('*') if !defined( $self->weekday );
}

sub _sanity_check {
}

1;
