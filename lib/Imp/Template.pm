package Imp::Template;

use strict;
use warnings;

use Moo;
use Imp::System::Path;

has template => ( is => 'ro', required => 1 );
has output   => ( is => 'ro', required => 1 );
has data     => ( is => 'ro', required => 1 );

has user  => ( is => 'rw' );
has group => ( is => 'rw' );
has mode  => ( is => 'rw' );

sub BUILD {
    my $self = shift;
}

sub write {
    my $self = shift;
    my $tt   = Template->new(
        ABSOLUTE => 1,
    );
    $tt->process( $self->template, $self->data, $self->output )
      or die $tt->error;

    #TODO: add logging
    #or $self->logger->fatal_log("writing $self->{output} failed: $tt->error");

    Imp::System::Path->new(
        user  => $self->user,
        group => $self->group,
        mode  => $self->mode,
        fh    => $self->output,
    )->modify;
}

1;
