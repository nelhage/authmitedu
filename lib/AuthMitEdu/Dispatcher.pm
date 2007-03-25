package AuthMitEdu::Dispatcher;

use Jifty::Dispatcher -base;

before '*' => run {
    if(!Jifty->web->current_user->id) {
        my $user = AuthMitEdu::Model::User->remote_user;
        if($user) {
            warn "Doing a login";
            Jifty->web->temporary_current_user(
                AuthMitEdu::CurrentUser->new(username => $user->username));
        }
    }
};

on qr{^/([a-zA-Z][a-zA-Z_0-9]+)$} => run {
    set user => $1;
    show '/endpoint';
};

on qr{^/_/auth/?$} => run {
    my $cgi = Jifty->handler->cgi;
    $AuthMitEdu::server->get_args(scalar $cgi->Vars);
    $AuthMitEdu::server->post_args(scalar $cgi->Vars);
    
    my ($type, $data) = $AuthMitEdu::server->handle_page();
    if ( $type eq "redirect" ) {
        redirect $data;
    } elsif ( $type eq "setup" ) {
        my $user = AuthMitEdu::Model::User->remote_user;
        if(!$user && !$ENV{HTTPS}) {
            redirect 'https://' . $ENV{HTTP_HOST} . $ENV{REQUEST_URI};
        }

        my %opts = %$data;
        tangent '/_/login' unless $user && $user->is_identity($opts{identity});
        
        set $_ => $opts{$_} for keys %opts;
        show 'setup';
        
    } else {
        set content_type => $type;
        set data => $data;
        show 'data';
    }
};

1;
