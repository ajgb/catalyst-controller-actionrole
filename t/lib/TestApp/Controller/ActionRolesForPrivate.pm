package TestApp::Controller::ActionRolesForPrivate;

use Moose;

BEGIN { extends 'Catalyst::Controller::ActionRole'; }

__PACKAGE__->config(
    action_roles => ['~Kooh']
);

sub _foo  : Local Does('Moo') {}
sub _bar  : Local Does('~Moo') {}
sub _baz  : Local Does('+Moo') {}
sub _quux : Local Does('Zoo') {}
sub _AUTO : Private { return 1 }


1;
