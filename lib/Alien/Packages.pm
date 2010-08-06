package Alien::Packages;

use warnings;
use strict;

require 5.008;
require Module::Pluggable::Object;

=head1 NAME

Alien::Packages - Find information of installed packages

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

    my $ap = Alien::Packages->new();

    my @packages = $ap->list_packages();
    foreach my $pkg (@packages)
    {
	print "$pkg->[0] version $pkg->[1]: $pkg->[2]\n";
    }

    my %perl_owners = $ap->list_fileowners( File::Spec->rel2abs( $^X ) );
    while( my ($fn, $pkg) = each( %perl_owners ) )
    {
	print "$fn is provided by ", join( ", ", @$pkg ), "\n";
    }

=head1 SUBROUTINES/METHODS

=head2 new

Instantiates new Alien::Packages object. Attributes can be specified
for used finder (of type L<Module::Pluggable::Object>). Additionally,

=over 4

=item C<only_loaded>

Use only plugins which are still loaded.

=back

can be specified with a true value. This forces to grep C<%INC> instead
of using Module::Pluggable.

=cut

sub new
{
    my ( $class, %attrs ) = @_;
    my $self = bless( { plugins => [], }, $class );

    my $only_loaded = delete $attrs{only_loaded};

    if ($only_loaded)
    {
        my @search_path = __PACKAGE__ eq $class ? (__PACKAGE__) : ( __PACKAGE__, $class );
        foreach my $path (@search_path)
        {
            $path =~ s|::|/|g;
            $path .= "/";
            my @loadedModules = grep { 0 == index( $_, $path ) } keys %INC;
            foreach my $module (@loadedModules)
            {
                $module =~ s|/|::|;
                $module =~ s/\.pm$//;
                next unless ( $module->can('usable') && $module->usable() );
                push( @{ $self->{plugins} }, $module->new() );
            }
        }
    }
    else
    {
        %attrs = (
                   require     => 1,
                   search_path => [ __PACKAGE__ eq $class ? __PACKAGE__ : ( __PACKAGE__, $class ) ],
                   inner       => 0,
                   %attrs,
                 );
        my $finder     = Module::Pluggable::Object->new(%attrs);
        my @pkgClasses = $finder->plugins();
        foreach my $pkgClass (@pkgClasses)
        {
            next unless ( $pkgClass->can('usable') && $pkgClass->usable() );
            push( @{ $self->{plugins} }, $pkgClass->new() );
        }
    }

    return $self;
}

=head2 list_packages

Lists the installed packages on the system (if the caller has the
permission to do).

Results in a list of array references, whereby each item contains:

  [ type, name, version, summary ]

C<type> is the packager type, e.g. I<rpm>, I<lpp> or I<pkgsrc>.

=cut

sub list_packages
{
    my $self = $_[0];
    my @packages;

    foreach my $plugin ( @{ $self->{plugins} } )
    {
        my @ppkgs = $plugin->list_packages();
	my $pkgtype = $plugin->pkgtype();
	foreach my $pkg (@ppkgs)
	{
	    push( @packages, [ $pkgtype, @$pkg ] );
	}
    }

    return @packages;
}

=head2 list_fileowners

Provides an association between files on the system and the package which
reference it (has presumably installed it).

Returns a hash with the files names as key and a list of referencing
package names as value.

=cut

my $haveHashMerge;

sub list_fileowners
{
    my ( $self, @files ) = @_;
    my %file_owners;

    unless ( defined($haveHashMerge) )
    {
        $haveHashMerge = 0;
        eval { require Hash::Merge; Hash::Merge->VERSION() ge "0.12" and $haveHashMerge = 1; };
        $haveHashMerge and $self->{hashmerge} = Hash::Merge->new('LEFT_PRECEDENT');
    }

    foreach my $plugin ( @{ $self->{plugins} } )
    {
        my %pfos = $plugin->list_fileowners(@files);
        if ( $self->{hashmerge} )
        {
            %file_owners = %{ $self->{hashmerge}->merge( \%file_owners, \%pfos ) };
        }
        else
        {
            while ( my ( $fn, $pkg ) = each %pfos )
            {
                if ( defined( $file_owners{$fn} ) )
                {
                    push( @{ $file_owners{$fn} }, @{$pkg} );
                }
                else
                {
                    $file_owners{$fn} = $pkg;
                }
            }
        }
    }

    return %file_owners;
}

=head1 AUTHOR

Jens Rehsack, C<< <rehsack at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-alien-packages at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Alien-Packages>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Alien::Packages

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Alien-Packages>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Alien-Packages>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Alien-Packages>

=item * Search CPAN

L<http://search.cpan.org/dist/Alien-Packages/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Jens Rehsack.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;    # End of Alien::Packages
