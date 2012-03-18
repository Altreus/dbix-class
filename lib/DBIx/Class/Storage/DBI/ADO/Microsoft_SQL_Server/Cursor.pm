package DBIx::Class::Storage::DBI::ADO::Microsoft_SQL_Server::Cursor;

use strict;
use warnings;
use base 'DBIx::Class::Storage::DBI::Cursor';
use mro 'c3';

=head1 NAME

DBIx::Class::Storage::DBI::ADO::Microsoft_SQL_Server::Cursor - Remove NULL
padding in binary data and normalize GUIDs for MSSQL over ADO

=head1 DESCRIPTION

This class is for removing C<NULL> padding from binary data and removing braces
from GUIDs retrieved from Microsoft SQL Server over ADO.

You probably don't want to be here, see
L<DBIx::Class::Storage::DBI::ADO::Microsoft_SQL_Server> for information on the
Microsoft SQL Server driver for ADO and L<DBIx::Class::Storage::DBI::MSSQL> for
the Microsoft SQL Server driver base class.

Unfortunately when using L<DBD::ADO>, binary data comes back C<NULL> padded and
GUIDs come back wrapped in braces, the purpose of this class is to remove the
C<NULL>s and braces. L<DBIx::Class::Storage::DBI::ADO::Microsoft_SQL_Server>
sets L<cursor_class|DBIx::Class::Storage::DBI/cursor_class> to this class by
default. It is overridable via your
L<connect_info|DBIx::Class::Storage::DBI/connect_info>.

You can use L<DBIx::Class::Cursor::Cached> safely with this class and not lose
the binary data normalizing functionality,
L<::Cursor::Cached|DBIx::Class::Cursor::Cached> uses the underlying class data
for the inner cursor class.

=cut

sub _dbh_next {
  my ($storage, $dbh, $self) = @_;

  my $next = $self->next::can;

  my @row = $next->(@_);

  my $col_info = $storage->_resolve_column_info($self->args->[0]);

  my $select = $self->args->[1];

  for my $select_idx (0..$#$select) {
    my $selected = $select->[$select_idx];

    next if ref $selected;

    my $data_type = $col_info->{$selected}{data_type};

    if ($data_type =~ /binary|image/i) {
      my $returned = $row[$select_idx]||'';

      $returned =~ s/\00*\z//;

      $row[$select_idx] = $returned;
    }
    elsif ($storage->_is_guid_type($data_type)) {
      my $returned = $row[$select_idx]||'';

      $row[$select_idx] = substr($returned, 1, 36)
        if substr($returned, 0, 1) eq '{';
    }
  }

  return @row;
}

sub _dbh_all {
  my ($storage, $dbh, $self) = @_;

  my $next = $self->next::can;

  my @rows = $next->(@_);

  my $col_info = $storage->_resolve_column_info($self->args->[0]);

  my $select = $self->args->[1];

  for my $row (@rows) {
    for my $select_idx (0..$#$select) {
      my $selected = $select->[$select_idx];

      next if ref $selected;

      my $data_type = $col_info->{$selected}{data_type};

      if ($data_type =~ /binary|image/i) {
        my $returned = $row->[$select_idx]||'';

        $returned =~ s/\00*\z//;

        $row->[$select_idx] = $returned;
      }
      elsif ($storage->_is_guid_type($data_type)) {
        my $returned = $row->[$select_idx]||'';

        $row->[$select_idx] = substr($returned, 1, 36)
          if substr($returned, 0, 1) eq '{';
      }
    }
  }

  return @rows;
}

1;

=head1 AUTHOR

See L<DBIx::Class/AUTHOR> and L<DBIx::Class/CONTRIBUTORS>.

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

# vim:sts=2 sw=2:
