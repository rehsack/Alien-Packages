#!perl

use strict;
use warnings;

use Test::More;

use Cwd qw(realpath);
use Config;

require Alien::Packages;

my $ap = Alien::Packages->new();
ok( $ap, "Instantiating" );

my @packages = $ap->list_packages();
# can't check result: Slackware, Gentoo, OpenBSD, MirBSD, IRIX, HP-UX, ...
ok( 1, "still alive after list_packages" );

if( @packages )
{
    # for the author, to see if there is something
    diag( "[ " . join( ", ", @{$packages[0]} ) . " ]" );
}

my $perl = realpath( $Config{perlpath} );
my %assoc_pkgs = $ap->list_fileowners( $perl );
ok( 1, "still alive after list_fileowners" );
# can't check result, could be unsupported pkg type or wild installation (e.g. blead)
if( keys %assoc_pkgs )
{
    # for the author, to see if there is something
    diag( "$perl is registered in " . $assoc_pkgs{$perl}->[0] );
}

done_testing();
