use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Catalyst::TraitFor::Controller::ActionRole',
    license             => 'perl',
    dist_author         => q{Alex J. G. Burzyński <ajgb@cpan.org>},
    dist_version_from   => 'lib/Catalyst/TraitFor/Controller/ActionRole.pm',
    dist_abstract       => 'Apply roles to action instances',
    add_to_cleanup      => [ 'Catalyst-TraitFor-Controller-ActionRole-*' ],
    create_makefile_pl  => 'traditional',
    create_license      => 1,
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'MooseX::Role::Parameterized' => '0.18', 
        'Class::MOP' => '0.80',
        'Moose' => '0.90',
        'String::RewritePrefix' => '0.004',
        'MooseX::Types::Moose' => '0',
        'List::Util' => '0',
        'namespace::clean' => '0',
        'Catalyst::Runtime' => '5.71001',
    },
);

$builder->create_build_script();
