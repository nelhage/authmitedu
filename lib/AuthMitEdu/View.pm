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
    my %args;
    $args{$_} = get $_ for qw(return_to identity assoc_handle trust_root);
    redirect $AuthMitEdu::server->signed_return_url(%args);
};

1;
