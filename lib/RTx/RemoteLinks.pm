use strict;
use warnings;
package RTx::RemoteLinks;

our $VERSION = '0.01';

use List::Util 'first';

=head1 NAME

RTx-RemoteLinks - Conviently create links to ticket IDs in other RT instances

=cut

require RT::Config;
$RT::Config::META{RemoteLinks} = { Type => 'HASH' };

sub LookupRemote {
    my $class = shift;
    my $alias = $class->CanonicalizeAlias(shift)
        or return;

    my $remote = (RT->Config->Get("RemoteLinks") || {})->{$alias};
       $remote = "http://$remote" unless $remote =~ m{^https?://}i;

    return wantarray ? ($alias, $remote) : $remote;
}

sub CanonicalizeAlias {
    my $class   = shift;
    my $alias   = shift or return;
    my %remotes = RT->Config->Get("RemoteLinks");
    return first { lc $_ eq lc $alias }
           sort keys %remotes;
}

{
    require RT::URI;
    no warnings 'redefine';

    my $_GetResolver = RT::URI->can("_GetResolver")
        or die "No RT::URI::_GetResolver()?";

    *RT::URI::_GetResolver = sub {
        my $self   = shift;
        my $scheme = shift;

        if (RTx::RemoteLinks->CanonicalizeAlias($scheme)) {
            $scheme = "remote-rt";
        }

        return $_GetResolver->($self, $scheme, @_);
    };
}

=head1 INSTALLATION 

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

Add this line:

    Set(@Plugins, qw(RTx::RemoteLinks));

or add C<RTx::RemoteLinks> to your existing C<@Plugins> line.

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 AUTHOR

Thomas Sibley <trs@bestpractical.com>

=head1 BUGS

All bugs should be reported via email to
L<bug-RTx-RemoteLinks@rt.cpan.org|mailto:bug-RTx-RemoteLinks@rt.cpan.org>
or via the web at
L<rt.cpan.org|http://rt.cpan.org/Public/Dist/Display.html?Name=RTx-RemoteLinks>.


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2013 by Best Practical Solutions

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

1;
