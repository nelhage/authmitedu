use strict;
use warnings;

package AuthMitEdu::Model::User;
use Jifty::DBI::Schema;
use URI;
use Email::Address;

use AuthMitEdu::Record schema {
    column username =>
        type is 'text';
};

# Your model-specific methods go here.

sub remote_user {
    my $email = $ENV{SSL_CLIENT_S_DN_Email};
    return unless $email;
    my ($username) = $email =~ /^(.+)@/;
    my $user = AuthMitEdu::Model::User->new;
    my ($ok, $err) = $user->load_or_create(username => $username);
    die $err unless $ok;
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

sub current_user_can {1};

1;

