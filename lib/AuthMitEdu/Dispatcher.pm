package AuthMitEdu::Dispatcher;

use Jifty::Dispatcher -base;

before '*' => run {
    if(!Jifty->web->current_user->id) {
        my $user = AuthMitEdu::Model::User->remote_user;
        if($user) {
            Jifty->web->temporary_current_user(
                AuthMitEdu::CurrentUser->new(username => $user->username));
        }
    }
};

on '/error/bad_identity/**' => run {
    set identity => $1;
    show '/error/bad_identity';
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
        set $_ => $opts{$_} for keys %opts;

        redirect '/error/no_cert' unless $user;
        redirect '/error/bad_identity/' . $opts{identity} unless $user->is_identity($opts{identity});
        
        show 'setup';
        
    } else {
        set content_type => $type;
        set data => $data;
        show 'data';
    }
};

1;
