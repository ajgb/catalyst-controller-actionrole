use strict;
use warnings;
use Test::More tests => 12;

use FindBin;
use lib "$FindBin::Bin/lib";

use Catalyst::Test 'TestApp';

my %roles = (
    _foo  => 'TestApp::ActionRole::Moo',
    _bar  => 'TestApp::ActionRole::Moo',
    _baz  => 'Moo',
    _quux => 'Catalyst::ActionRole::Zoo',
);

while (my ($path, $role) = each %roles) {
    my $resp = request("/actionrolesforprivate/${path}");
    ok($resp->is_success,
        "request to /$path is succesful"
    );
    is($resp->content, $role,
        "role $role applied"
    );
    is($resp->header('X-Affe'), undef,
        "...but not Kooh from action_roles"
    );
}
