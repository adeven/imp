package Imp::Cpan;

use strict;
use warnings;

use Moo;
use Template;
use Imp::System::Path;
use autodie;

has user => ( is => 'ro', required => 1 );
has homedir => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_set_env;
    $self->_make_base;
    $self->_write_config;
}

sub _set_env {
    my $self = shift;
    my $user = $self->user;
    $ENV{'HOME'}                = $self->{homedir};
    $ENV{'PERL5LIB'}            = "$self->{homedir}/perl5/lib/perl5";
    $ENV{'PERL_MB_OPT'}         = "--install_base $self->{homedir}/perl5";
    $ENV{'PERL_LOCAL_LIB_ROOT'} = ":$self->{homedir}/perl5";
    $ENV{'PERL_MM_OPT'}         = "INSTALL_BASE=$self->{homedir}/perl5";
    $ENV{'PERL_MM_USE_DEFAULT'} = 1;
}

sub _make_base {
    my $self = shift;
    Imp::System::Path->new(
        user  => $self->{user},
        group => $self->{user},
        dir   => "$self->{homedir}/.cpan",
        mode  => '0755',
    )->create;
    Imp::System::Path->new(
        user  => $self->{user},
        group => $self->{user},
        dir   => "$self->{homedir}/.cpan/CPAN",
        mode  => '0755',
    )->create;
}

sub _write_config {
    my $self = shift;
    my $user = $self->user;
    my $tt   = Template->new;
    chdir '/home/imp/app/current';
    $tt->process(
        "templates/perl/MyConfig.pm.tt",
        {
            user => $user,
            home => $self->{homedir},
        },
        "$self->{homedir}/.cpan/CPAN/MyConfig.pm"
    ) or die $!;
}

sub install {
    my $self     = shift;
    my $pkg      = shift;
    my $userhome = $self->{homedir};
    ##TODO: replace this with inline cpan?
    system("eval \$(perl -I$userhome/perl5/lib/perl5 -Mlocal::lib=$userhome/perl5) && cpan -j $userhome/.cpan/CPAN/MyConfig.pm  -f $pkg") == 0 or die $!;
}

1;
