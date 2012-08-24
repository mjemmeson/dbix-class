package DBIx::Class::ResultClass;

use warnings;
use strict;

# This is technically a module, but its SOLE purpose is documentation.
# It's a *.pm file so that Pod::Inherit can acquire the parent modules
# listed below.

use base qw/DBIx::Class::Core/;

### TODO: Ream the user if they actually try to use this, but don't yell at
### Pod::Inherit.


=head1 NAME

DBIx::Class::ResultClass - How to declare a proper Result Class

=head1 SYNOPSIS

  package My::Schema::Result::Track;

  use base 'DBIx::Class::Core';

  __PACKAGE__->table('tracks');

  __PACKAGE__->add_columns({
    id => {
      data_type => 'int',
      is_auto_increment => 1,
    },
    cd_id => {
      data_type => 'int',
    },
    title => {
      data_type => 'varchar',
      size => 50,
    },
    rank => {
      data_type => 'int',
      is_nullable => 1,
    },
  });

  __PACKAGE__->set_primary_key('id');
  __PACKAGE__->add_unique_constraint(u_title => ['cd_id', 'title']);

=head1 DESCRIPTION

In L<DBIx::Class> a user normally receives query results as instances of a
certain C<Result Class>, depending on the main query source. Besides being
the primary "toolset" for interaction with your data, a C<Result Class> also
serves to establish source metadata which is then used during initialization
of your <DBIx::Class::Schema> instance.

Because of these multiple seemingly conflicting purposes, it is hard to
aggregate the documentation of various methods available on a typical
C<Result Class>. This document serves as a general overview of C<Result Class>
declaration best practices, and offers an index of the available methods
(and the Components/Roles which provide them).

=head1 INITIALIZATION METHODS

=head2 table_class

  __PACKAGE__->table_class('DBIx::Class::ResultSource::View')

The accessor holds the class name from which the result source instance of
this result class will be derived. If not specified defaults to
L<DBIx::Class::ResultSource::Table>.

=head2 table

  __PACKAGE__->table('artists');

Instantiates a result source instance and sets its
L<name|DBIx::Class::ResultSource/name> to the supplied argument. If called
without arguments proxies to L<name|DBIx::Class::ResultSource/name>.

=for todo
=head1 RESULTSOURCE METADATA METHODS

=for todo
=head1 DATA INSTANCE MANIPULATION METHODS

=head1 AUTHORS

See L<DBIx::Class/CONTRIBUTORS>.

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;