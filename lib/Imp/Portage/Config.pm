package Imp::Portage::Config;

use strict;
use warnings;
use 5.010;

use Moo;
use Imp::Template;

has template => ( is => 'rw' );
has output   => ( is => 'rw' );
has data     => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_make_base;
}

sub write {
    my $self = shift;
    my $tt   = Imp::Template->new(
        template => $self->template,
        data     => $self->data,
        output   => $self->output
    );
    $tt->write;
}

sub _make_base {
    my $self         = shift;
    my $portage_dirs = [
        'package.accept_keywords', 'package.mask',
        'package.unmask',          'package.use'
    ];
    foreach my $dir (@$portage_dirs) {
        $dir = '/etc/portage/' . $dir;
        if ( -f $dir ) {
            $self->_create_sub_dir($dir);
        }
        else {
            mkdir $dir;
        }
    }
}

sub _create_sub_dir {
    my $self = shift;
    my $dir  = shift;
    rename $dir, $dir . ".bk";
    mkdir $dir;
    open my $fh, '<', $dir . ".bk"
      or say "while trying to open $dir.bk: $!";

    while (<$fh>) {
        next if $_ =~ /(^#)/;
        my $pkg;
        my $suffix;
        if ( $_ =~ /(^\S+)(\s*)(\S+)(\s*($|\#))/ ) {
            $pkg    = $1;
            $suffix = $3;
        }
        next unless $pkg;
        my $filename = $pkg;
        $filename =~ s/=//;
        $filename =~ s/\//-/;
        open my $wh, '>>', $dir . "/" . $filename;
        print $wh "$pkg $suffix\n";
        close($wh);
    }
    close($fh);
}

1;
