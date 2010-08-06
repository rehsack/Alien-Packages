package Alien::Packages::Dpkg;

use strict;
use warnings;
use vars qw($VERSION @ISA);

=head1 NAME

Alien::Packages::Dpkg - handles packages of Debian's dpkg

=cut

$VERSION = "0.001";

require Alien::Packages::Base;

@ISA = qw(Alien::Packages::Base);

=head1 ISA

    Alien::Packages::Dpkg
    ISA Alien::Packages::Base

=head1 SUBROUTINES/METHODS

=head2 usable

=cut

sub usable
{
    unless ( defined( $INC{'DPKG/Parse.pm'} ) )
    {
        eval { require DPKG::Parse; };
    }

    return $INC{'DPKG/Parse.pm'};
}

=head2 list_packages

=cut

sub list_packages
{
    my $self = $_[0];
    my @packages;

    return @packages;
}

=head2 list_fileowners

=cut

sub list_fileowners
{
    my ( $self, @files ) = @_;
    my %file_owners;

    return %file_owners;
}

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;
