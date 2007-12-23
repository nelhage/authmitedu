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
       outs(" provider for members of the MIT Community");
   };

    h2{"What is this thing?"};

    p{ "OpenID is a distributed authentication system for the
    web. Using a single OpenID, you can securely sign on to any
    website that supports OpenID, without ever having to give them a
    password or even create an account. auth.mit.edu gives MIT
    certificate holders an OpenID identity."
    }

    h2{"How do I use it?"};

    p{
        outs("Go to any website that supports OpenID. (e.g. ");
        hyperlink(url   => 'http://livejournal.com',
                  label => 'Livejournal');
        outs(" or ");
        hyperlink(url   => 'http://doxory.com',
                  label => 'Doxory');
        outs(") Enter ");
      
        my $uo = Jifty->web->current_user->user_object;
        if ($uo) {
            tt{"http://auth.mit.edu/" . $u->username};
        } else {
            tt{"http://auth.mit.edu/your_username_here"};
        }

        outs(q{ into the OpenID login box. If your browser has MIT
    certificates installed, you should be prompted if you want to
    allow the other site to authenticate you. Say "yes", and you'll be
    logged in!});

    } };

template endpoint => sub {
    my $user = get('user');
    html {
        head {
            link {{rel is "openid.server",
                   href is Jifty->web->url(path => "/_/auth")}}
        }
        body {
            h1 { "OpenID auth page for $user" };

	    p {
        	outs("This URL is for OpenID authentication and is not meant for human reading. Please see ");
		hyperlink(url => "/", label => "our FAQ");
		outs(" for more information.");
	      };
	    p {
	    	outs("You might be able to find some information about $user in the ");
		hyperlink(url => "http://web.mit.edu/bin/cgicso?options=username&query=$user", label => "MIT Directory");
	      };

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
    div {{id is "verify_page"}
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
        outs("You are currently authenticated as " . Jifty->web->current_user->user_object_username .
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

private template 'salutation' => sub {
    div {{id is 'salutation'}
         if (Jifty->web->current_user->id and Jifty->web->current_user->user_object) {
             my $u = Jifty->web->current_user->user_object;
             outs(_("Hiya, %1.", $u->name));
         } else {
             outs(_("You're not currently signed in."));
         }
     }
};

private template 'menu' => sub {
    # We don't need a menu
};

1;
