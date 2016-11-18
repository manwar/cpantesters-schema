use utf8;
package CPAN::Testers::Schema::Result::ReleaseStat;
our $VERSION = '0.001';
# ABSTRACT: A single test report reduced to a simple pass/fail

=head1 SYNOPSIS

    my $release_stats = $schema->resultset( 'ReleaseStat' )->search({
        dist => 'My-Dist',
        version => '1.001',
    });

=head1 DESCRIPTION

This table contains information about individual reports, reduced to
a pass/fail.

These stats are built from the `cpanstats` table
(L<CPAN::Testers::Schema::Result::Stats>), and collected and combined
into the `release_summary` table
(L<CPAN::Testers::Schema::Result::Release>).

B<XXX>: This intermediate table between a report and the release summary
does not seem necessary and if we can remove it, we should.

=head1 SEE ALSO

=over 4

=item L<DBIx::Class::Row>

=item L<CPAN::Testers::Schema>

=item L<CPAN::Testers::Schema::Result::Release>

These rows are collected into the Release table.

=item L<Labyrinth::Plugin::CPAN::Release>

This module processes the data and writes to this table.

=item L<http://github.com/cpan-testers/cpantesters-project>

For an overview of how the CPANTesters project works, and for
information about project goals and to get involved.

=back

=cut

use CPAN::Testers::Schema::Base;
use base 'DBIx::Class::Core';

__PACKAGE__->table( 'release_data' );

=attr dist

The name of the distribution.

=cut

__PACKAGE__->add_column(
    dist => {
        data_type => 'varchar',
        is_nullable => 0,
    }
);

=attr version

The version of the distribution.

=cut

__PACKAGE__->add_column(
    version => {
        data_type => 'varchar',
        is_nullable => 0,
    }
);

=attr id

The ID of this report from the `cpanstats` table. See
L<CPAN::Testers::Schema::Result::Stats>.

=cut

__PACKAGE__->add_column(
    id => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr guid

The GUID of this report from the `cpanstats` table. See
L<CPAN::Testers::Schema::Result::Stats>.

=cut

__PACKAGE__->add_column(
    guid => {
        data_type => 'char',
        is_nullable => 0,
    }
);

__PACKAGE__->set_primary_key(qw( id guid ));

=attr oncpan

The installability of this release: C<1> if the release is on CPAN. C<2>
if the release has been deleted from CPAN and is only on BackPAN.

=cut

__PACKAGE__->add_column(
    oncpan => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr distmat

The maturity of this release. C<1> if the release is stable and
ostensibly indexed by CPAN. C<2> if the release is a developer release,
unindexed by CPAN.

=cut

__PACKAGE__->add_column(
    distmat => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr perlmat

The maturity of the Perl these reports were sent by: C<1> if the Perl is
a stable release. C<2> if the Perl is a developer release.

=cut

__PACKAGE__->add_column(
    perlmat => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr patched

The patch status of the Perl that sent the report. C<2> if the Perl reports
being patched, C<1> otherwise.

=cut

__PACKAGE__->add_column(
    patched => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr pass

C<1> if this report's C<state> was C<PASS>.

=cut

__PACKAGE__->add_column(
    pass => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr fail

C<1> if this report's C<state> was C<FAIL>.

=cut

__PACKAGE__->add_column(
    fail => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr na

C<1> if this report's C<state> was C<NA>.

=cut

__PACKAGE__->add_column(
    na => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr unknown

C<1> if this report's C<state> was C<UNKNOWN>.

=cut

__PACKAGE__->add_column(
    unknown => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=attr uploadid

The ID of this upload from the `uploads` table.

=cut

__PACKAGE__->add_column(
    uploadid => {
        data_type => 'int',
        is_nullable => 0,
    }
);

=method upload

Get the related row from the `uploads` table. See
L<CPAN::Testers::Schema::Result::Upload>.

=cut

__PACKAGE__->belongs_to(
    upload => 'CPAN::Testers::Schema::Result::Upload' => 'uploadid',
);

1;