package Alien::Packages::PkgInfo;

use strict;
use warnings;
use vars qw($VERSION @ISA);

=head1 NAME

Alien::Packages::PkgInfo - handles Sun's pkginfo

=cut

$VERSION = "0.001";

require Alien::Packages::Base;

@ISA = qw(Alien::Packages::Base);

=head1 ISA

    Alien::Packages::PkgInfo
    ISA Alien::Packages::Base

=cut

require IPC::Cmd;

=head1 SUBROUTINES/METHODS

=head2 usable

Returns true when the commands C<pkginfo> and C<pkgchk> could be found in
the path.

=cut

my ( $pkginfo, $pkgchk );

sub usable
{
    unless ( defined($pkginfo) )
    {
        $pkginfo = IPC::Cmd::can_run('pkginfo');
    }

    unless ( defined($pkgchk) )
    {
        $pkgchk = IPC::Cmd::can_run('pkgchk');
    }

    return $pkginfo && $pkgchk;
}

=head2 list_packages

Returns the list of installed packages.

=cut

sub list_packages
{
    my $self = $_[0];
    my @packages;

    my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
      IPC::Cmd::run( command => [ $pkginfo, '-x' ],
                     verbose => 0, );

    if ($success)
    {
        while ( $stdout_buf->[0] =~ m/(\w+)\s+([^\s].*)\s+(\(\w+\))\s(\d[\d.]+,REV=[^\s]+)/gx )
        {
            push( @packages, [ $1, $4, $2 ] );
        }
    }

    return @packages;
}

=head2 list_fileowners

Returns the packages which have a registered dependency on specified files.

=cut

sub list_fileowners
{
    my ( $self, @files ) = @_;
    my %file_owners;

    foreach my $file (@files)
    {
        my ( $success, $error_code, $full_buf, $stdout_buf, $stderr_buf ) =
          IPC::Cmd::run(
                         command     => [ $pkgchk, '-i', '-', '-l' ],
                         verbose     => 0,
                         child_stdin => "$file\n",
                       );

        if ($success)
        {
            while ( $stdout_buf->[0] =~ m/Referenced\sby\sthe\sfollowing\spackages:\s+([A-Za-z0-9]+)/x )
            {
                $file_owners{$file} ||= [];
                push( @{ $file_owners{$file} }, $1 );
            }
        }
    }

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
