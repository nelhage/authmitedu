package AuthMitEdu::Dispatcher;

use Jifty::Dispatcher -base;

on qr{^/[a-zA-Z][a-zA-Z_0-9]+$} => run {
    set user => $1;
    show '/endpoint';
};

before '/_/*' => run {
    if(!$ENV{HTTPS}) {
	redirect 'https://' . $ENV{HTTP_HOST} . $ENV{REQUEST_URI};
    }
};

on qr{^/_/auth$} => run {
    # I know what I am doing is wrong. But N::Server::OpenID croaks if
    # you pass it a CGI::Fast.
    my $cgi = bless(Jifty->handler->cgi, 'CGI');
    $AuthMitEdu::server->get_args($cgi);
    $AuthMitEdu::server->post_args($cgi);
    my ($type, $data) = $AuthMitEdu::server->handle_page();
    if ( $type eq "redirect" ) {
        redirect $data;
    } elsif ( $type eq "setup" ) {
        my %opts = %$data;
        my $user = AuthMitEdu::Model::User->remote_user;

        set $_ => $opts{$_} for keys %opts;
 
        tangent '/_/login' unless $user && $user->is_identity($opts{identity});
        
        show 'setup';
        
    } else {
        set content_type => $type;
        set data => $data;
        show 'data';
    }
};

1;
