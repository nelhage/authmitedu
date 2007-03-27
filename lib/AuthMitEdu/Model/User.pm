use strict;
use warnings;

package AuthMitEdu::Model::User;
use Jifty::DBI::Schema;
use URI;
use Data::Dumper;

use AuthMitEdu::Record schema {
    column username => type is 'text';
    column name     => type is 'text';

    column trust_roots =>
        refers_to AuthMitEdu::Model::TrustRootCollection by 'identity',
        since '0.0.2';
};

# Your model-specific methods go here.

sub remote_user {
    my $email = $ENV{SSL_CLIENT_S_DN_Email};
    return unless $email;
    my ($username) = $email =~ /^(.+)@/;
    my $user = AuthMitEdu::Model::User->new;
    my ($ok, $err) = $user->load_or_create(username => $username);
    die $err unless $ok;
    my $realname = $ENV{SSL_CLIENT_S_DN_CN};
    if($realname) {
        my ($ok, $err) = $user->as_superuser->set_name($realname);
        die $err unless $ok;
    }
    return $user;
}

sub is_identity {
    my ($self, $url) = @_;
    $url = URI->new($url);
    if($url->path =~ m{^/group/}) {
      my ($groupname) = $url->path =~ m{^/group/([a-zA-Z_\-0-9]+)};
      my $groupsystem = "system:" . $groupname;
      my $ptsmem = `pts 2>/dev/null membership $groupsystem`;
      my @ptsmem = split(/\n/, $ptsmem);
      unless($ptsmem[0] =~ /^Members of $groupsystem \(id: \S+\) are:$/) {
        return 0;
      }
      my $theuser = $self->username;
      for(my $i = 1; $i < @ptsmem; $i++) {
        if($ptsmem[$i] =~ /\s\Q$theuser\E$/) {
          return 1;
        }
      }
    } else {
      return $url->path eq '/' . $self->username;
    }
}

sub trusts_root {
    my ($self, $root) = @_;
    my $troot = $self->root($root);
    return $troot->id && $troot->trust;
}

sub never_trusts_root {
    my ($self, $root) = @_;
    my $troot = $self->root($root);
    return $troot->id && !$troot->trust;
}

sub root {
    my ($self, $root) = (@_);
    my $troot = AuthMitEdu::Model::TrustRoot->new;
    $troot->load_by_cols(identity => $self, trust_root => $root);
    return $troot;
}

sub current_user_can {
    my $self = shift;
    my $right = shift;

    return 1 if $right eq 'create';
    
    if($right eq 'read') {
        return 1;
    } elsif($right eq 'update' && $self->id eq $self->current_user->id) {
        return 1;
    }
    return $self->SUPER::current_user_can($right, @_);
}

1;

