package CPAN::Testers::Schema;
our $VERSION = '0.010';
# ABSTRACT: Schema for CPANTesters database processed from test reports

=head1 SYNOPSIS

    my $schema = CPAN::Testers::Schema->connect( $dsn, $user, $pass );
    my $rs = $schema->resultset( 'Stats' )->search( { dist => 'Test-Simple' } );
    for my $row ( $rs->all ) {
        if ( $row->state eq 'fail' ) {
            say sprintf "Fail report from %s: http://cpantesters.org/cpan/report/%s",
                $row->tester, $row->guid;
        }
    }

=head1 DESCRIPTION

This is a L<DBIx::Class> Schema for the CPANTesters statistics database.
This database is generated by processing the incoming data from L<the
CPANTesters Metabase|http://metabase.cpantesters.org>, and extracting
the useful fields like distribution, version, platform, and others (see
L<CPAN::Testers::Schema::Result::Stats> for a full list).

This is its own distribution so that it can be shared by the backend
processing, data APIs, and the frontend web application.

=head1 SEE ALSO

L<CPAN::Testers::Schema::Result::Stats>, L<DBIx::Class>

=cut

use CPAN::Testers::Schema::Base;
use File::Share qw( dist_dir );
use Path::Tiny qw( path );
use List::Util qw( uniq );
use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;
__PACKAGE__->load_components(qw/Schema::Versioned/);
__PACKAGE__->upgrade_directory( dist_dir( 'CPAN-Testers-Schema' ) );

=method connect_from_config

    my $schema = CPAN::Testers::Schema->connect_from_config;

Connect to the MySQL database using a local MySQL configuration file
in C<$HOME/.cpanstats.cnf>. This configuration file should look like:

    [client]
    host     = ""
    database = cpanstats
    user     = my_usr
    password = my_pwd

See L<DBD::mysql/mysql_read_default_file>.

=cut

# Convenience connect method
sub connect_from_config ( $class ) {
    my $schema = $class->connect(
        "DBI:mysql:mysql_read_default_file=$ENV{HOME}/.cpanstats.cnf;".
        "mysql_read_default_group=application;mysql_enable_utf8=1",
        undef,  # user
        undef,  # pass
        {
            AutoCommit => 1,
            RaiseError => 1,
            mysql_enable_utf8 => 1,
            quote_char => '`',
            name_sep   => '.',
        },
    );
    return $schema;
}

=method ordered_schema_versions

Get the available schema versions by reading the files in the share
directory. These versions can then be upgraded to using the
L<cpantesters-schema> script.

=cut

sub ordered_schema_versions( $self ) {
    my @versions =
        uniq sort
        map { /[\d.]+-([\d.]+)/ }
        grep { /CPAN-Testers-Schema-[\d.]+-[\d.]+-MySQL[.]sql/ }
        path( dist_dir( 'CPAN-Testers-Schema' ) )->children;
    return '0.000', @versions;
}

1;
