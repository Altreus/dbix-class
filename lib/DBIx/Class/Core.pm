package DBIx::Class::Core;

use strict;
use warnings;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/
  Relationship
  InflateColumn
  PK::Auto
  PK
  Row
  ResultSourceProxy::Table
/);

1;

=head1 NAME

DBIx::Class::Core - Core set of DBIx::Class modules

=head1 SYNOPSIS

  # In your result (table) classes
  use base 'DBIx::Class::Core';

=head1 DESCRIPTION

This class just inherits from the various modules that make up the
L<DBIx::Class> core features.  You almost certainly want these.

The core modules currently are:

=over 4

=item L<DBIx::Class::InflateColumn>

=item L<DBIx::Class::Relationship> (See also L<DBIx::Class::Relationship::Base>)

=item L<DBIx::Class::PK::Auto>

=item L<DBIx::Class::PK>

=item L<DBIx::Class::Row>

=item L<DBIx::Class::ResultSourceProxy::Table> (See also L<DBIx::Class::ResultSource>)

=back

=head1 AUTHORS

Matt S. Trout <mst@shadowcatsystems.co.uk>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
