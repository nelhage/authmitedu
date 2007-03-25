use warnings;
use strict;


package AuthMitEdu::CurrentUser;

use base qw/Jifty::CurrentUser/;

=head2 new PARAMHASH

Instantiate a new current user object, loading the user by paramhash:

   my $item = AuthMitEdu::Model::Item->new( AuthMitEdu::CurrentUser->new(email => 'user@site'));

if you give the param 
    _bootstrap => 1

your object will be marked as a bootstrap user. You can use that to do an endrun around acls.

=cut



sub _init {
    my $self = shift;
    my %args = (@_);

    if (delete $args{'_bootstrap'} ) {
        $self->is_bootstrap_user(1);
    } elsif (keys %args) {
        $self->user_object(AuthMitEdu::Model::User->new(current_user => $self));
        $self->user_object->load_by_cols(%args);
    }
    $self->SUPER::_init(%args);
}


1;
