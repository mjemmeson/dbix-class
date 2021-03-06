use Config;
BEGIN {
  unless ($Config{useithreads}) {
    print "1..0 # SKIP your perl does not support ithreads\n";
    exit 0;
  }
}
use threads;

use strict;
use warnings;
use Test::More;

plan skip_all => 'DBIC does not actively support threads before perl 5.8.5'
  if $] < '5.008005';

plan skip_all => 'test dangerous on Win32 for < 5.14 set TEST_AUTHOR to run'
  if $^O eq 'MSWin32' && $] < 5.014 && !$ENV{TEST_AUTHOR};

use lib qw(t/lib);
use DBICTest;

# README: If you set the env var to a number greater than 10,
#   we will use that many children
my $num_children = $ENV{DBICTEST_THREAD_STRESS} || 1;
if($num_children !~ /^[0-9]+$/ || $num_children < 10) {
   $num_children = 10;
}

my $schema = DBICTest->init_schema(no_deploy => 1);
isa_ok ($schema, 'DBICTest::Schema');

my @threads;
push @threads, threads->create(sub {
  my $rsrc = $schema->source('Artist');
  undef $schema;
  isa_ok ($rsrc->schema, 'DBICTest::Schema');
  my $s2 = $rsrc->schema->clone;

  sleep 1;  # without this many tasty crashes
}) for (1.. $num_children);
ok(1, "past spawning");

$_->join for @threads;
ok(1, "past joining");

done_testing;
