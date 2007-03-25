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

template setup => sub {
    my $root = get 'trust_root';
    my $identity = get 'identity';
    my $action = Jifty->web->new_action(class => 'SetupAuth');
    html {
        head {
            title {"Let $root verify your identity?"}
        }
        body {
            p { "The site $root would like you verify your identity ($identity). " .
                "Do you want to allow them?"
            };
            form {
                for (qw(return_to identity assoc_handle trust_root)) {
                    render_param($action => $_, render_as => 'hidden',
                                 default_value => get $_);
                }
                outs_raw($action->button(label => "Yes",
                                         arguments => {action => 'yes'}));
                outs_raw($action->button(label => "No",
                                         arguments => {action => 'no'}));
            }
        }
    };
};

template '/_/login' => sub {
    html {
        body {
            p {
                "You need to login";
            }
        }
    }
};


1;
