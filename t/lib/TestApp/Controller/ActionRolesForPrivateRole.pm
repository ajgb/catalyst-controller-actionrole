package TestApp::Controller::ActionRolesForPrivateRole;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

with 'Catalyst::TraitFor::Controller::ActionRole' => {
    action_roles => ['~Kooh']
};

sub _foo  : Local Does('Moo') {}
sub _bar  : Local Does('~Moo') {}
sub _baz  : Local Does('+Moo') {}
sub _quux : Local Does('Zoo') {}
sub _AUTO : Private { return 1 }


1;
