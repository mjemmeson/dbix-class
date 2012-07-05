use warnings;

use Test::More;
use Data::Dumper::Concise;
use lib qw(t/lib);
use DBIC::SqlMakerTest;
use DBICTest;

my $schema = DBICTest->init_schema();

# While this is a rather GIGO case, make sure it behaves as pre-103,
# as it may result in hard-to-track bugs
my $cds = $schema->resultset('Artist')
            ->search_related ('cds')
              ->search ({}, {
                  prefetch => [ 'single_track', { single_track => 'cd' } ],
                });

is_same_sql(
  ${$cds->as_query}->[0],
  '(
    SELECT
      cds.cdid, cds.artist, cds.title, cds.year, cds.genreid, cds.single_track,
      single_track.trackid, single_track.cd, single_track.position, single_track.title, single_track.last_updated_on, single_track.last_updated_at,
      single_track_2.trackid, single_track_2.cd, single_track_2.position, single_track_2.title, single_track_2.last_updated_on, single_track_2.last_updated_at,
      cd.cdid, cd.artist, cd.title, cd.year, cd.genreid, cd.single_track
    FROM artist me
      JOIN cd cds ON cds.artist = me.artistid
      LEFT JOIN track single_track ON single_track.trackid = cds.single_track
      LEFT JOIN track single_track_2 ON single_track_2.trackid = cds.single_track
      LEFT JOIN cd cd ON cd.cdid = single_track_2.cd
  )',
);

my $cds_rs = $schema->resultset('CD')->search(
  [
    {
      'me.title' => "Caterwaulin' Blues",
      'cds.title' => { '!=' => 'Forkful of bees' }
    },
    {
      'me.title' => { '!=', => "Caterwaulin' Blues" },
      'cds.title' => 'Forkful of bees'
    },
  ],
  {
    prefetch => { artist => 'cds' },
    result_class => 'DBIx::Class::ResultClass::HashRefInflator',
  },
);

my $all = [ $cds_rs->all ];

is_deeply $all, [
  {
    'single_track' => undef,
    'cdid' => '1',
    'artist' => {
      'cds' => [
        {
          'single_track' => undef,
          'artist' => '1',
          'cdid' => '2',
          'title' => 'Forkful of bees',
          'genreid' => undef,
          'year' => '2001'
        },
      ],
      'artistid' => '1',   
      'charfield' => undef,
      'name' => 'Caterwauler McCrae',
      'rank' => '13'
    },
    'title' => 'Spoonful of bees',
    'year' => '1999',
    'genreid' => '1'
  },
  {
    'single_track' => undef,
    'cdid' => '2',
    'artist' => {
      'cds' => [
        {
          'single_track' => undef,
          'artist' => '1',
          'cdid' => '2',
          'title' => 'Forkful of bees',
          'genreid' => undef,
          'year' => '2001'
        },
      ],
      'artistid' => '1',   
      'charfield' => undef,
      'name' => 'Caterwauler McCrae',
      'rank' => '13'
    },
    'title' => 'Forkful of bees',
    'year' => '2001',
    'genreid' => undef
  },
  {
    'single_track' => undef,
    'cdid' => '3',
    'artist' => {
      'cds' => [
        {
          'single_track' => undef,
          'artist' => '1',
          'cdid' => '3',
          'title' => 'Caterwaulin\' Blues',
          'genreid' => undef,
          'year' => '1997'
        },
        {
          'single_track' => undef,
          'artist' => '1',
          'cdid' => '1',
          'title' => 'Spoonful of bees',
          'genreid' => '1',
          'year' => '1999'
        }
      ],
      'artistid' => '1',   
      'charfield' => undef,
      'name' => 'Caterwauler McCrae',
      'rank' => '13'
    },
    'title' => 'Caterwaulin\' Blues',  
    'year' => '1997',
    'genreid' => undef
  }
], 'fix for multi-level prefetch bug'
  or diag Dumper($all);

done_testing;
