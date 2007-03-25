use strict;
use warnings;

package AuthMitEdu;
use Net::OpenID::Server;


our $server;

sub start {
    $server = Net::OpenID::Server->new(
        get_user    => \&AuthMitEdu::Model::User::remote_user,
        is_identity => sub {0},
        is_trusted  => sub {0},
        setup_url   => Jifty->web->url( path => '/_/setup' ),
    );

    $AuthMitEdu::server->server_secret( Jifty->config->app('ServerSecret') );
}

1;
