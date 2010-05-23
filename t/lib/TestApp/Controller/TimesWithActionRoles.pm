package TestApp::Controller::TimesWithActionRoles;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

with 'Catalyst::TraitFor::Controller::ActionRole' => {
    action_roles => ['Shared']
};

sub two  : Local Does('First') {}
sub three  : Local Does('First') Does('Second') {}

1;
