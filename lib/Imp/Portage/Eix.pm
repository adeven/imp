package Imp::Portage::Eix;

use strict;
use warnings;
use 5.010;

use Moo;

sub BUILD {
    my $self = shift;
}

sub eix_update {
    my $self = shift;
    system('eix-update -q') == 0
      or say "while eix_update: $!";
}

sub eix_installed {
    my $self      = shift;
    my $pkg       = shift;
    my $installed = $self->_eix_installed;
    my ( $cat, $pkg_name ) = split( '/', $pkg );
    if ( defined($cat) && defined($pkg_name) ) {
        return exists( $$installed{$pkg} );
    }
    else {
        my $result = $self->_eix_search($pkg);
        if ( scalar @{$result} == 1 ) {
            return exists( $$installed{ $$result[0] } );
        }
    }
    return 0;
}

sub _eix_search {
    my $self = shift;
    my $pkg  = shift;
    my $result;
    my @found = `eix --only-names $pkg`;
    foreach my $entry (@found) {
        chomp($entry);
        my ( $cat, $name ) = split( '/', $entry );
        if ( $name eq $pkg ) {
            push( @$result, $entry );
        }
    }
    return $result;
}

sub _eix_installed {
    my $self      = shift;
    my @installed = `eix-installed -a`;
    my %pkgs =
      map {
        my $string = $_;
        my ( $prefix, $suffix ) = split( /-([^-]+)$/, $string );
        if ( $string =~ /-r\d+/ ) {
            my ( $new_prefix, $suffix ) = split( /-([^-]+)$/, $prefix );
            $new_prefix => 1;
        }
        else {
            $prefix => 1;
        }
      } @installed;
    return \%pkgs;
}

1;
