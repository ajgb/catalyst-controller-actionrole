package TestApp::Controller::TimesDoesOnly;

use Moose;

BEGIN { extends 'Catalyst::Controller'; }

with 'Catalyst::TraitFor::Controller::ActionRole';

sub one  : Local Does('First') {}
sub two  : Local Does('First') Does('Second') {}


1;
