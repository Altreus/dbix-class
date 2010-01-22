use strict;
use warnings;

use Test::More;
use Test::Exception;

use lib qw(t/lib);
use DBIC::SqlMakerTest;
use DBICTest;


my $schema = DBICTest->init_schema();

my @chain = (
  {
    columns     => [ 'cdid' ],
    '+select'   => [ { lower => 'title' }, 'genreid' ],
    '+as'       => [ qw/title_lc genreid/ ],
  } => 'SELECT me.cdid, LOWER( title ), me.genreid FROM cd me',

  {
    '+columns'  => [ { max_year => { max => 'me.year' }}, ],
    '+select'   => [ { count => 'me.cdid' }, ],
    '+as'       => [ 'cnt' ],
  } => 'SELECT me.cdid, MAX( me.year ), LOWER( title ), me.genreid, COUNT( me.cdid ) FROM cd me',

  {
    select      => [ { min => 'me.cdid' }, ],
    as          => [ 'min_id' ],
  } => 'SELECT MIN( me.cdid ) FROM cd me',

  {
    '+columns' => [ { cnt => { count => 'cdid' } } ],
  } => 'SELECT COUNT ( cdid ), MIN( me.cdid ) FROM cd me',

  {
    columns => [ 'year' ],
  } => 'SELECT me.year FROM cd me',
);

my $rs = $schema->resultset('CD');

my $testno = 1;
while (@chain) {
  my $attrs = shift @chain;
  my $sql = shift @chain;

  $rs = $rs->search ({}, $attrs);

  is_same_sql_bind (
    $rs->as_query,
    "x( $sql )", # the x-es are here until SQLA is fixed
    [],
    "Test $testno of SELECT assembly ok",
  );

  $testno++;
}

done_testing;