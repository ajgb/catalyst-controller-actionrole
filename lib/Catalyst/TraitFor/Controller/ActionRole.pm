package Catalyst::TraitFor::Controller::ActionRole;
# ABSTRACT: Apply roles to action instances


use MooseX::Role::Parameterized;
use Class::MOP;
use Moose::Meta::Class;
use String::RewritePrefix;
use MooseX::Types::Moose qw/ArrayRef Str RoleName/;
use List::Util qw(first);

use namespace::autoclean;

our $VERSION = '0.01';

=encoding utf8

=head1 SYNOPSIS

    package MyApp::Controller::Foo;

    BEGIN { extends 'Catalyst::Controller'; }

    with qw/Catalyst::TraitFor::Controller::ActionRole/;

    sub bar : Local Does('Moo') { ... }

=head1 DESCRIPTION

This module allows to apply roles to the C<Catalyst::Action>s for different
controller methods.

For that a C<Does> attribute is provided. That attribute takes an argument,
that determines the role, which is going to be applied. If that argument is
prefixed with C<+>, it is assumed to be the full name of the role. If it's
prefixed with C<~>, the name of your application followed by
C<::ActionRole::> is prepended. If it isn't prefixed with C<+> or C<~>,
the role name will be searched for in C<@INC> according to the rules for
L<role prefix searching|/ROLE PREFIX SEARCHING>.

It's possible to apply roles to B<all> actions of a controller
without specifying the C<Does> keyword in every action definition:

    package MyApp::Controller::Bar;

    BEGIN { extends 'Catalyst::Controller'; }

    with 'Catalyst::TraitFor::Controller::ActionRole' => {
        action_roles => ['Foo', '~Bar'],
    };

    # has Catalyst::ActionRole::Foo and MyApp::ActionRole::Bar applied
    # if MyApp::ActionRole::Foo exists and is loadable, it will take
    # precedence over Catalyst::ActionRole::Foo
    sub moo : Local { ... }

Additionally roles could be applied to selected actions without specifying
C<Does> using L<Catalyst::Controller/action> and configured with
L<Catalyst::Controller/action_args>:

    package MyApp::Controller::Baz;

    BEGIN { extends 'Catalyst::Controller'; }

    with 'Catalyst::TraitFor::Controller::ActionRole';

    __PACKAGE__->config(
        action_roles => [qw( Foo )],
        action => {
            some_action => { Does => [qw( ~Bar )] },
            another_action => { Does => [qw( +MyActionRole::Baz )] },
        },
        action_args => {
            another_action => { customarg => 'arg1' },
        }
    );

    # has Catalyst::ActionRole::Foo and MyApp::ActionRole::Bar applied
    sub some_action : Local { ... }

    # has Catalyst::ActionRole::Foo and MyActionRole::Baz applied
    # and associated action class would get additional arguments passed
    sub another_action : Local { ... }

Please note that above example shows C<action_roles> specified with
C<__PACKAGE__-E<gt>config()>.

=head1 PARAMETERS

This module can be configured with following parameters.

=head2 action_role_prefix

This class attribute stores an array reference of role prefixes to search for
role names in if they aren't prefixed with C<+> or C<~>. It defaults to
C<[ 'Catalyst::ActionRole::' ]>.  See L</role prefix searching>.

=head2 action_roles

This attribute stores an array reference of role names that will be applied to
every action of this controller. It can be set by passing an C<action_roles>
argument as the role parameter or via C<__PACKAGE__-E<gt>config()>.
The same expansions as for C<Does> will be performed.

Please note that roles specified with action_roles are not applied to methods
with names starting with underscore.

=head1 ATTRIBUTES

=head2 _action_role_prefix

Returns the value of L</action_role_prefix> role parameter.

=head2 _action_roles

Returns the value of L</action_roles> role parameter.

=cut

parameter action_role_prefix => (
    is         => 'rw',
    isa        => ArrayRef[Str],
    default    => sub { ['Catalyst::ActionRole::'] },
);

parameter action_roles => (
    is         => 'rw',
    isa        => ArrayRef[Str],
    default    => sub { [] },
);

=head1 ROLE PREFIX SEARCHING

Roles specified with no prefix are looked up under a set of role prefixes.  The
first prefix is always C<MyApp::ActionRole::> (with C<MyApp> replaced as
appropriate for your application); the following prefixes are taken from the
L</action_role_prefix> parameter.

=cut

role {
    my $p = shift;
    my %args = @_;
    my $consumer = $args{consumer};

    has _action_roles => (
        traits      => [qw(Array)],
        isa         => ArrayRef[RoleName],
        lazy_build  => 1,
        handles     => {
            _action_roles => 'elements',
        },
    );

    has _action_role_prefix => (
        is          => 'rw',
        isa         => ArrayRef[Str],
        default     => sub { $p->action_role_prefix },
    );

    method '_build__action_roles' => sub {
        my $self = shift;

        my @roles = $self->_expand_role_shortname( @{ $p->action_roles } );

        if ( my $config = $self->config ) {
            if ( my $action_roles = $config->{action_roles} ) {
                push @roles, $self->_expand_role_shortname(@$action_roles);
            }
        }

        Class::MOP::load_class($_) for @roles;

        return \@roles; 
    };

    # load all action_roles at object creation time
    sub BUILD {
        shift->_action_roles;
    };

    around 'create_action' => sub {
        my $orig = shift;
        my $self = shift;
        my %args = @_;

        my $action = $self->$orig(%args);

        my @roles = (
            # don't apply "global" action_roles to private actions
            ( $action->name =~ /^_/ ? () : $self->_action_roles ),
            # roles set by Does are applied as requested
            @{ $action->attributes->{Does} || [] }
        );

        if (@roles) {
            my $meta = $action->meta->create_anon_class(
                superclasses => [ref $action],
                roles        => \@roles,
                cache        => 1,
            );
            $meta->add_method(meta => sub { $meta });
            my $sub_class = $meta->name;

            $action = $sub_class->new( \%args );
        }

        return $action;
    };

    method '_expand_role_shortname' => sub {
        my ($self, @shortnames) = @_;
        my $app = $self->_application;

        my @prefixes = (qq{${app}::ActionRole::}, @{ $self->_action_role_prefix });

        return String::RewritePrefix->rewrite(
            { ''  => sub {
                my $loaded = Class::MOP::load_first_existing_class(
                    map { "$_$_[0]" } @prefixes
                );
                return first { $loaded =~ /^$_/ }
                  sort { length $b <=> length $a } @prefixes;
              },
              '~' => $prefixes[0],
              '+' => '' },
            @shortnames,
        );
    };

    method '_parse_Does_attr' => sub {
        my ($self, $app, $name, $value) = @_;
        return Does => $self->_expand_role_shortname($value);
    };
};

=begin Pod::Coverage

  BUILD

=end Pod::Coverage

=head1 AUTHOR

Alex J. G. Burzyński, C<< <ajgb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-catalyst-traitfor-controller-actionrole at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-TraitFor-Controller-ActionRole>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

This module wouldn't exists without L<Catalyst::Controller::ActionRole>
upon which it is heavily based.

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alex J. G. Burzyński.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Catalyst::TraitFor::Controller::ActionRole
