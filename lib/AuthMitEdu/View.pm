use warnings;
use strict;

=head1 NAME

AuthMitEdu::View

=cut

package AuthMitEdu::View;
use Jifty::View::Declare -base;

template endpoint => sub {
    my $user = get('user');
    outs_raw(qq{<html>
<head>
<link rel="openid.server" href="@{[Jifty->web->url(path => "/_/auth")]}" />
</head>
<body>
</body>
</html>
});

};

template data => sub {
    my ($content_type, $data) = get(qw(content_type data));
    Jifty->handler->apache->content_type($content_type);
    outs_raw($data);
};

template setup => sub {
    my %opts = %{get 'setup_opts'};
    redirect $AuthMitEdu::server->cancel_return_url(return_to => $opts{return_to});
};

1;
