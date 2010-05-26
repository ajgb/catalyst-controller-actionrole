package Catalyst::Controller::ActionRole;
# ABSTRACT: Apply roles to action instances

use Moose;

use namespace::clean -except => 'meta';

extends 'Catalyst::Controller';

our $VERSION = '0.15';

with 'Catalyst::TraitFor::Controller::ActionRole';

=head1 SYNOPSIS

    package MyApp::Controller::Foo;

    use parent qw/Catalyst::Controller::ActionRole/;

    sub bar : Local Does('Moo') { ... }

=head1 DESCRIPTION

B<DEPRECATED> Please use L<Catalyst::TraitFor::Controller::ActionRole>
instead.

=cut

1;
