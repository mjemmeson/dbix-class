use strict;
use warnings;

use Test::More;
use Test::Exception;
use Try::Tiny;

use lib qw(t/lib);

use DBICTest;
my $schema = DBICTest->init_schema;

throws_ok (sub {
  $schema->txn_do (sub { die 'lol' } );
}, 'DBIx::Class::Exception', 'a DBIC::Exception object thrown');

throws_ok (sub {
  $schema->txn_do (sub { die [qw/lol wut/] });
}, qr/ARRAY\(0x/, 'An arrayref thrown');

is_deeply (
  $@,
  [qw/ lol wut /],
  'Exception-arrayref contents preserved',
);

try {
  $schema->txn_do(sub {
    die bless ({ msg => 'foobar' }, 'DBICTest::Custom::Exception');
  });
} catch {
  isa_ok ($_, 'DBICTest::Custom::Exception');
  is_deeply( $_, { msg => 'foobar' });
};

done_testing;
