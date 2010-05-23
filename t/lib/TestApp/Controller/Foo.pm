package TestApp::Controller::Foo;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

with 'Catalyst::TraitFor::Controller::ActionRole' => {
    action_roles => ['~Kooh']
};

sub foo  : Local Does('Moo') {}
sub bar  : Local Does('~Moo') {}
sub baz  : Local Does('+Moo') {}
sub quux : Local Does('Zoo') {}


1;
