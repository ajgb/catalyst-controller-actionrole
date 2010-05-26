package TestApp::Controller::RolesViaConfig;

use Moose;

BEGIN { extends 'Catalyst::Controller::ActionRole'; }

__PACKAGE__->config(
    action_roles => ['Shared'],
    action => {
        four => {
            Does => 'First'
        },
        five => {
            Does => [qw( First Second )],
        },

    },
);

sub four  : Local {}
sub five  : Local {}

1;
