use warnings;
use strict;

=head1 NAME

AuthMitEdu::View

=cut

package AuthMitEdu::View;
use Jifty::View::Declare -base;

template 'index.html' => page {
    h1 {"Welcome to auth.mit.edu"};
    p {outs("auth.mit.edu is an ");
       hyperlink(url => "http://openid.net", label => "OpenID");
       outs("provider for members of the MIT Community");
   };
};

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
        outs("Would you like to allow");
        div {{id is "trust_root"}
            a {{href is "$root"} $root};
        };
    };
    p {
        outs("to verify your identity ($identity)? ");
    };
    p {
        outs("Doing so will not grant access to any part of your Athena account.  It will only provide confirmation that you are who you claim to be.");
    };
    form {
        for (qw(return_to identity assoc_handle trust_root)) {
            render_param($action => $_, render_as => 'hidden', default_value => get $_);
        }

        outs_raw($action->button(
            label       => "Yes",
            arguments   => { action => 'yes' },
            key_binding => "Y"));
        outs_raw($action->button(
            label       => "No",
            arguments   => { action => 'no' },
            key_binding  => "N"));

	    render_param($action => 'remember');
    }
};

template '/error/no_cert' => page {
    p {
        outs("You do not seem to have an MIT Certificate. See IS&T's ");
        a {{ href is "http://web.mit.edu/ist/topics/certificates/index.html"}
           "certificate information page"};
        outs("for information about how to obtain one.");
    }
};

template '/error/bad_identity' => page {
    p {
        outs("You are currently authenticated as " . Jifty->web->current_user->username .
            ", but are trying to authenticate as " . get('identity'));
    }
};

private template 'header' => sub {
    my ($title) = get_current_attr(qw(title));
    Jifty->handler->apache->content_type('text/html; charset=utf-8');
    head { 
        with(
            'http-equiv' => "content-type",
            content      => "text/html; charset=utf-8"
          ),    
          meta {};
        with( name => 'robots', content => 'all' ), meta {};
        with( rel  => 'shortcut icon',
              href => Jifty->web->url(path => '/static/images/openid.ico'),
              type => 'image/vnd.microsoft.icon'
             ), link {};
        title { _($title) };
        Jifty->web->include_css;
        Jifty->web->include_javascript;
      };

};

1;
