package Authen::Pluggable::Passwd;

use Mojo::Base -base, -signatures;

use Authen::Simple::Passwd;

has 'parent' => undef, weak => 1;
has _cfg => sub { return { file => '/etc/passwd' } };

sub authen ( $s, $user, $pass ) {
    my $auth = Authen::Simple::Passwd->new( path => $s->_cfg->{file} );

    return undef unless $auth->authenticate($user, $pass);
    # SU $_ c'è la riga autenticata
    my (undef,undef,$uid, $gid, $cn, $home, $shell) = split /:/;
    return { user => $user, cn => $cn, gid => $gid, uid => $uid };
}

sub cfg ($s, %cfg) {

    if (%cfg) {
        while (my ($k, $v) = each %cfg) {
            $s->_cfg->{$k} = $v;
        }
    }
    return $s->parent;
}

1;

__END__

# ABSTRACT: Authentication via a passwd file
