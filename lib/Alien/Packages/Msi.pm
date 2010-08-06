package Alien::Packages::Msi;

use strict;
use warnings;
use vars qw($VERSION @ISA);

=head1 NAME

Alien::Packages::Msi - deals with package information of Microsoft Installer

=cut

$VERSION = "0.001";

require Alien::Packages::Base;

@ISA = qw(Alien::Packages::Base);

=head1 ISA

    Alien::Packages::Msi
    ISA Alien::Packages::Base

=head1 SUBROUTINES/METHODS

=head2 usable

=cut

sub usable
{
    return 0;
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
