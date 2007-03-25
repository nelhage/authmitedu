use warnings;
use strict;

=head1 NAME

AuthMitEdu::View

=cut

package AuthMitEdu::View;
use Jifty::View::Declare -base;

template endpoint => sub {
    my $user = get('user');
    html {
        head {
            link {{rel is "openid.server",
                   href is Jifty->web->url(path => "/_/auth")}}
        }
        body {
            h1 { "OpenID auth page for $user" }
        }
    }
};

template data => sub {
    my ($content_type, $data) = get(qw(content_type data));
    Jifty->handler->apache->content_type($content_type);
    outs_raw($data);
};

template setup => page {
    my $root = get 'trust_root';
    my $identity = get 'identity';
    my $action = Jifty->web->new_action(class => 'SetupAuth');
    p {
        outs("The site ");
        a {{href is "$root"} $root};
        outs("would like you verify your identity ($identity). " .
             "Do you want to allow them?");
    };
    form {
        for (qw(return_to identity assoc_handle trust_root)) {
            render_param(
                $action       => $_,
                render_as     => 'hidden',
                default_value => get $_);
        }

        outs_raw($action->button(
            label     => "Yes",
            arguments => { action => 'yes' }));
        outs_raw($action->button(
            label     => "No",
            arguments => { action => 'no' }));
    }
};

template '/error/no_cert' => page {
    p {
        outs("You do not seem to have an MIT Certificate. See IS&T's ");
        a {{ href is "http://web.mit.edu/ist/topics/certificates/index.html"}
           "certificate information page"};
        outs("for more information about how to obtain one.");
    }
};

template '/error/bad_identity' => page {
    p {
        outs("You are currently authenticated as " . Jifty->web->current_user->username .
            ", but are trying to authenticate as " . get('identity'));
    }
};


1;
