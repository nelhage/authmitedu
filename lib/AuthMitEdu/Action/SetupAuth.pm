use warnings;
use strict;

=head1 NAME

AuthMitEdu::Action::SetupAuth

=head1 DESCRIPTION

This action is run by a user to set up authentication against a given
trust_root

=cut

package AuthMitEdu::Action::SetupAuth;
use Jifty::Param::Schema;
use Jifty::Action schema {
    param return_to     => render as 'hidden';
    param identity      => render as 'hidden';
    param assoc_handle  => render as 'hidden';
    param trust_root    => render as 'hidden';

    param action => type is 'text',
                    valid are qw(yes no);

};

sub take_action {
    my $self = shift;
    my $action = $self->argument_value('action');

    if($action eq 'yes') {
        my %args;
        $args{$_} = $self->argument_value($_)
                for qw(return_to identity assoc_handle trust_root);
        Jifty->web->_redirect($AuthMitEdu::server->signed_return_url(%args));
    } else {
        Jifty->web->_redirect(
            $AuthMitEdu::server->cancel_return_url(return_to =>
                                                   $self->argument_value('return_to')));
    }
}

1;
