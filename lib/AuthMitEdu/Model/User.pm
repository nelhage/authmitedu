use strict;
use warnings;

package AuthMitEdu::Model::User;
use Jifty::DBI::Schema;
use URI;

use AuthMitEdu::Record schema {
    column username =>
        type is 'text';
};

# Your model-specific methods go here.

sub remote_user {
    my $username = $ENV{REMOTE_USER};
    return unless $username;
    my $user = AuthMitEdu::Model::User->new;
    $user->load_or_create(username => $username);
    return $user;
}


sub is_identity {
    my ($self, $url) = @_;
    return 0 unless $self;
    $url = URI->new($url);
    return $url->path eq '/' . $self->username;
}

sub is_trusted {
    my ($self, $root) = @_;
    return 0;
}

1;

