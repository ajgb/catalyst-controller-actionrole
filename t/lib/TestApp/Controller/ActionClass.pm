package TestApp::Controller::ActionClass;
use strict; use warnings;
use Moose;

BEGIN { extends 'Catalyst::Controller'; }

with 'Catalyst::TraitFor::Controller::ActionRole';

sub one : Local ActionClass('TestActionClass') {}

1;
