package TestAppREST::Controller::FooRole;
use Moose;
use namespace::clean -except => 'meta';

BEGIN { extends 'Catalyst::Controller'; }
with 'Catalyst::TraitFor::Controller::ActionRole';

sub foo  : Local Does('Moo') ActionClass('REST') {}

sub foo_GET {}

1;
