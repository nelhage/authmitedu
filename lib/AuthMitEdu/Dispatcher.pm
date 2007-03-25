package AuthMitEdu::Dispatcher;

use Jifty::Dispatcher -base;

on qr{^/[a-zA-Z][a-zA-Z_0-9]+$} => run {
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

 
        tangent '/_/login' unless $user && $user->is_identity($opts{identity});
        
        show 'setup';
        
    } else {
        set content_type => $type;
        set data => $data;
        show 'data';
    }
};

1;
